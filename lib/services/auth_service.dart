import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  signInWithGoogle() async {
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

      final GoogleSignInAccount? googleUser = await _googleSignIn
          .authenticate();

      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

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
