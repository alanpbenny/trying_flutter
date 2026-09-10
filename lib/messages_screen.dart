import 'dart:async';
import 'package:flutter/material.dart';
import 'messages.dart';
import 'altOtherProfileScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  bool selectionMode = false;
  Set<String> selectedMessages = {};
  final user = FirebaseAuth.instance.currentUser;

  List<String> incomingLikes = [];
  Map<String, String> userNames = {};
  Map<String, String?> userPhotos = {};

  // matchId -> other user's uid, populated live from Firestore.
  Map<String, String> activeMatches = {};

  // Fix #1: hold onto the stream subscriptions so we can cancel them in
  // dispose(). Without this, both listeners keep firing after the user
  // navigates away and setState() gets called on an unmounted widget.
  StreamSubscription<QuerySnapshot>? _likesSub;
  StreamSubscription<QuerySnapshot>? _matchesSub;

  // Fetches and caches a user's display name + photo the first time we see
  // their uid (as an incoming like or as the other side of a match).
  // Cheap no-op on repeat calls since it checks userNames first.
  Future<void> fetchUserName(String uid) async {
    if (userNames.containsKey(uid)) return; // already fetched

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!mounted) return; // widget could've been disposed while awaiting

      setState(() {
        userNames[uid] = doc.data()?['name'] ?? 'Unknown';
        userPhotos[uid] = doc.data()?['photoUrl'] as String?;
      });
    } catch (e) {
      debugPrint('fetchUserName failed for $uid: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    listenToIncomingLikes();
    listenToActiveMatches();
  }

  // Fix #1: cancel both listeners when this screen is disposed.
  @override
  void dispose() {
    _likesSub?.cancel();
    _matchesSub?.cancel();
    super.dispose();
  }

  // Listens for people who have liked the current user (the "likedUsers"
  // subcollection under my own doc holds INCOMING likes — doc ID is the
  // liker's uid). Drives the horizontal "pending matches" bubble row.
  void listenToIncomingLikes() {
    final myUid = user?.uid;
    // Fix #2: this guard was missing before — calling .doc(null) if auth
    // state hasn't resolved yet would throw.
    if (myUid == null) return;

    _likesSub = FirebaseFirestore.instance
        .collection('users')
        .doc(myUid)
        .collection('likedUsers')
        .snapshots()
        .listen(
          (snapshot) {
            if (!mounted) return;

            final users = snapshot.docs
                .map((doc) => doc['fromUserId'] as String)
                .toList();
            setState(() {
              incomingLikes = users;
            });

            for (final uid in users) {
              fetchUserName(uid);
            }
          },
          onError: (e) => debugPrint('listenToIncomingLikes error: $e'),
        );
  }

  // Listens for match documents that contain the current user, and derives
  // a matchId -> otherUserId map for the "active messages" list below.
  void listenToActiveMatches() {
    final myUid = user?.uid;
    if (myUid == null) return;

    _matchesSub = FirebaseFirestore.instance
        .collection('matches')
        .where('users', arrayContains: myUid)
        .snapshots()
        .listen(
          (snapshot) {
            if (!mounted) return;

            final matches = <String, String>{};

            for (final doc in snapshot.docs) {
              final users = List<String>.from(doc.data()['users'] ?? []);
              // The other person is whichever uid in the array isn't me.
              final otherUserId = users.firstWhere(
                (id) => id != myUid,
                orElse: () => '',
              );
              if (otherUserId.isEmpty) continue; // shouldn't happen, but guard

              matches[doc.id] = otherUserId;
            }

            setState(() {
              activeMatches = matches;
            });

            for (final otherUserId in matches.values) {
              fetchUserName(otherUserId);
            }
          },
          onError: (e) => debugPrint('listenToActiveMatches error: $e'),
        );
  }

  // Opens the full profile screen for someone who liked you, and applies
  // whatever decision (like/pass) they made when they come back.
  void openFullProfile(String likerUserId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Altotherprofilescreen(userId: likerUserId),
      ),
    );

    if (!mounted) return;

    if (result == "Liked") {
      acceptMatch(likerUserId);
    } else if (result == "Passed") {
      removeMatch(likerUserId);
    }
  }

  // Turns an incoming like into a real match: creates the shared match doc
  // and removes the like so its bubble disappears from the top row.
  Future<void> acceptMatch(String otherUserId) async {
    final myUid = user?.uid;
    if (myUid == null) return;

    final db = FirebaseFirestore.instance;

    // Deterministic match ID regardless of who accepts whom, so both users
    // land on the same document.
    final matchId = myUid.compareTo(otherUserId) < 0
        ? '${myUid}_$otherUserId'
        : '${otherUserId}_$myUid';

    // Fix #3: both writes now go through a single batch so they either both
    // succeed or both fail — no more risk of a match existing while the
    // "incoming like" bubble is still stuck on screen (or vice versa).
    final batch = db.batch();

    batch.set(db.collection('matches').doc(matchId), {
      'users': [myUid, otherUserId],
      'createdAt': FieldValue.serverTimestamp(),
    });

    batch.delete(
      db
          .collection('users')
          .doc(myUid)
          .collection('likedUsers')
          .doc(otherUserId), // direct delete by doc ID, no query needed
    );

    // Fix #4: wrap in try/catch so a failed commit doesn't throw unhandled
    // and silently leave the UI out of sync with Firestore.
    try {
      await batch.commit();
      // No manual setState needed here — listenToActiveMatches and
      // listenToIncomingLikes both pick up the change live.
    } catch (e) {
      debugPrint('acceptMatch failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not accept match. Try again.')),
        );
      }
    }
  }

  // Declines an incoming like: just removes it, no match doc is created.
  Future<void> removeMatch(String otherUserId) async {
    final myUid = user?.uid;
    if (myUid == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(myUid)
          .collection('likedUsers')
          .doc(otherUserId)
          .delete();
    } catch (e) {
      debugPrint('removeMatch failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not remove like. Try again.')),
        );
      }
    }
  }

  // Long-pressing a match row enters multi-select mode for deletion.
  void onLongPressMessage(String matchId) {
    setState(() {
      selectionMode = true;
      selectedMessages.add(matchId);
    });
  }

  // Tapping a match row either toggles its selection (in selection mode)
  // or opens the chat with that match.
  void onTapMessage(String matchId, String otherUserId) {
    if (selectionMode) {
      setState(() {
        if (selectedMessages.contains(matchId)) {
          selectedMessages.remove(matchId);
        } else {
          selectedMessages.add(matchId);
        }
        if (selectedMessages.isEmpty) {
          selectionMode = false;
        }
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OpenedMessagesScreen(user: otherUserId),
        ),
      );
    }
  }

  // Deletes every match doc currently selected, removing the chat for both
  // users on each match.
  //
  // Fix #5: the deletes are now awaited together via Future.wait, and we
  // only clear selection state / exit selection mode after they've all
  // settled. Errors are caught and surfaced instead of failing silently
  // while the UI optimistically clears itself regardless of outcome.
  Future<void> deleteSelected() async {
    final idsToDelete = selectedMessages.toList();

    try {
      await Future.wait(
        idsToDelete.map(
          (matchId) =>
              FirebaseFirestore.instance.collection('matches').doc(matchId).delete(),
        ),
      );
    } catch (e) {
      debugPrint('deleteSelected failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Some chats could not be deleted.')),
        );
      }
    }

    if (!mounted) return;
    setState(() {
      selectedMessages.clear();
      selectionMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final matchIds = activeMatches.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: selectionMode
            ? Text("${selectedMessages.length} selected")
            : const Text("Messages"),
        actions: selectionMode
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: deleteSelected,
                ),
              ]
            : [],
      ),
      body: Column(
        children: [
          // Top section: horizontal row of incoming likes (pending matches).
          if (incomingLikes.isNotEmpty)
            SizedBox(
              height: 120,
              child: Container(
                color: Colors.grey[200],
                padding: const EdgeInsets.only(top: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: incomingLikes.length,
                  itemBuilder: (context, index) {
                    final likerId = incomingLikes[index];
                    final likerName = userNames[likerId];
                    final likerPhotoUrl = userPhotos[likerId];

                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () => openFullProfile(likerId),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(40),
                              child: SizedBox(
                                width: 80,
                                height: 80,
                                child: likerPhotoUrl != null
                                    ? Image.network(
                                        likerPhotoUrl,
                                        fit: BoxFit.cover,
                                        loadingBuilder:
                                            (context, child, progress) {
                                              if (progress == null) {
                                                return child;
                                              }
                                              return Container(
                                                color: Colors.grey[300],
                                                child: const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                              );
                                            },
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Container(
                                                color: Colors.grey[300],
                                                child: const Icon(
                                                  Icons.person,
                                                  size: 40,
                                                  color: Colors.grey,
                                                ),
                                              );
                                            },
                                      )
                                    : Container(
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.person,
                                          size: 40,
                                          color: Colors.grey,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            SizedBox(
                              width: 80,
                              child: Text(
                                likerName ?? '...',
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

          // Bottom section: list of active matches (real chats).
          Expanded(
            child: matchIds.isEmpty
                ? const Center(child: Text("No messages yet"))
                : ListView.builder(
                    itemCount: matchIds.length,
                    itemBuilder: (context, index) {
                      final matchId = matchIds[index];
                      final otherUserId = activeMatches[matchId]!;
                      final otherUserName =
                          userNames[otherUserId] ?? 'Loading...';
                      final otherUserPhoto = userPhotos[otherUserId];
                      final isSelected = selectedMessages.contains(matchId);

                      return ListTile(
                        onTap: () => onTapMessage(matchId, otherUserId),
                        onLongPress: () => onLongPressMessage(matchId),
                        leading: CircleAvatar(
                          backgroundImage: otherUserPhoto != null
                              ? NetworkImage(otherUserPhoto)
                              : null,
                          child: otherUserPhoto == null
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        title: Text(otherUserName),
                        subtitle: const Text("Say hi 👋"),
                        selected: isSelected,
                        // Note: withOpacity is deprecated in current Flutter;
                        // withValues(alpha: 0.2) is the modern replacement.
                        // Left as-is since it's cosmetic, not a bug.
                        selectedTileColor: Colors.blue.withOpacity(0.2),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}