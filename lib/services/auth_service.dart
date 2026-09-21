import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<void> _reauthenticateWithGoogle(User user) async {
    if (kIsWeb) {
      GoogleAuthProvider googleProvider = GoogleAuthProvider()
        ..setCustomParameters({'prompt': 'select_account'});
      await user.reauthenticateWithPopup(googleProvider);
    } else {
      debugPrint('reauth: calling authenticate()...');
      final googleUser = await _googleSignIn.authenticate();
      debugPrint('reauth: got google user, getting tokens...');
      final googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(idToken: googleAuth.idToken);
      debugPrint('reauth: calling reauthenticateWithCredential...');
      await user.reauthenticateWithCredential(credential);
      debugPrint('reauth: done.');
    }
  }

  /// Deletes the current user's account and all their data. Returns true
  /// on success, false if anything failed (the caller shows the message).
  Future<bool> deleteAccount(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      await _reauthenticateWithGoogle(user);
    } catch (e) {
      debugPrint('Reauthentication failed: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please sign in again, then try deleting your account.',
            ),
          ),
        );
      }
      return false;
    }

    final uid = user.uid;
    final db = FirebaseFirestore.instance;

    try {
      debugPrint('deleteAccount: fetching matches...');
      final matches = await db
          .collection('matches')
          .where('users', arrayContains: uid)
          .get();

      debugPrint(
        'deleteAccount: found ${matches.docs.length} matches, deleting...',
      );
      for (final matchDoc in matches.docs) {
        final messages = await matchDoc.reference.collection('messages').get();
        final batch = db.batch();
        for (final m in messages.docs) {
          batch.delete(m.reference);
        }
        batch.delete(matchDoc.reference);
        await batch.commit();
      }

      // Replaces the old collectionGroup('likedUsers') query, which kept
      // hitting permission-denied no matter how the rules were shaped.
      // sentLikes is a per-user record of who I've liked, so this is now
      // a plain, single-document-scoped read + delete — no collection
      // group involved, no special rules needed beyond owner-only access.
      debugPrint('deleteAccount: fetching sent likes...');
      final sentLikes = await db
          .collection('users')
          .doc(uid)
          .collection('sentLikes')
          .get();
      debugPrint(
        'deleteAccount: found ${sentLikes.docs.length} sent likes, deleting...',
      );
      for (final doc in sentLikes.docs) {
        final otherUserId = doc.id;
        // Remove the like from the other user's likedUsers, then remove
        // my own record of having sent it. Deleting a doc that's already
        // gone (e.g. already matched/declined) is a silent no-op, not
        // an error, so this is safe even for stale entries.
        await db
            .collection('users')
            .doc(otherUserId)
            .collection('likedUsers')
            .doc(uid)
            .delete();
        await doc.reference.delete();
      }

      debugPrint('deleteAccount: fetching incoming likes...');
      final incomingLikes = await db
          .collection('users')
          .doc(uid)
          .collection('likedUsers')
          .get();
      debugPrint(
        'deleteAccount: found ${incomingLikes.docs.length} incoming likes, deleting...',
      );
      for (final like in incomingLikes.docs) {
        await like.reference.delete();
      }

      debugPrint('deleteAccount: deleting profile photo...');
      try {
        await FirebaseStorage.instance.ref('profile_photos/$uid.jpg').delete();
      } catch (e) {
        debugPrint('No profile photo to delete or delete failed: $e');
      }

      debugPrint('deleteAccount: deleting user doc...');
      await db.collection('users').doc(uid).delete();

      debugPrint('deleteAccount: deleting auth account...');
      await user.delete();

      debugPrint('deleteAccount: done.');
    } catch (e) {
      debugPrint('deleteAccount failed: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Something went wrong deleting your account. Please try again.",
            ),
          ),
        );
      }
      return false;
    }

    if (!kIsWeb) {
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
    }

    return true;
  }

  Future<User?>? signInWithGoogle() async {
    try {
      if (kIsWeb) {
        debugPrint("In Web AUTH!");

        GoogleAuthProvider googleProvider = GoogleAuthProvider()
          ..setCustomParameters({'prompt': 'select_account'});

        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithPopup(googleProvider);

        User? user = userCredential.user;

        if (user != null) {
          await createUserDocument(user);
        }

        return userCredential.user;
      } else {
        await _googleSignIn.initialize(
          serverClientId:
              "921950633809-vv0fb3g850ncql8guarm0rkjjmalva2m.apps.googleusercontent.com",
        );
      }

      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      User? user = userCredential.user;

      if (user != null) {
        await createUserDocument(user);
      }

      return userCredential.user;
    } catch (e) {
      print("Google Sign-In error: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    debugPrint("Signing out...");
    try {
      if (!kIsWeb) {
        await _googleSignIn.signOut();
      }
    } catch (e) {
      debugPrint("Google sign out error: $e");
    }

    await FirebaseAuth.instance.signOut();
    debugPrint("Firebase signed out");
    debugPrint(
      "Current user after signout: ${FirebaseAuth.instance.currentUser}",
    );
  }

  Future<void> createUserDocument(User user) async {
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);
    final doc = await userRef.get();
    if (!doc.exists) {
      await userRef.set({
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'profileImage': user.photoURL ?? '',
        'createdAt': Timestamp.now(),
        'onboardingComplete': false,
        'seenUsers': [],
        'likedUsers': [],
      });
    }
  }
}