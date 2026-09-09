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

  // 🔽 Active matches now come from Firestore, not a static list.
  // matchId -> other user's uid
  Map<String, String> activeMatches = {};

  Future<void> fetchUserName(String uid) async {
    if (userNames.containsKey(uid)) return; // already fetched

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    setState(() {
      userNames[uid] = doc.data()?['name'] ?? 'Unknown';
      userPhotos[uid] = doc.data()?['photoUrl'] as String?;
    });
  }

  @override
  void initState() {
    super.initState();
    listenToIncomingLikes();
    listenToActiveMatches();
  }

  void listenToIncomingLikes() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('likedUsers') // fixed typo: was 'likescReceived'
        .snapshots()
        .listen((snapshot) {
          final users = snapshot.docs
              .map((doc) => doc['fromUserId'] as String)
              .toList();
          setState(() {
            incomingLikes = users;
          });

          for (final uid in users) {
            fetchUserName(uid);
          }
        });
  }

  void listenToActiveMatches() {
    final myUid = user?.uid;
    if (myUid == null) return;

    FirebaseFirestore.instance
        .collection('matches')
        .where('users', arrayContains: myUid)
        .snapshots()
        .listen((snapshot) {
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
        });
  }

  void openFullProfile(String likerUserId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Altotherprofilescreen(userId: likerUserId),
      ),
    );

    if (result == "Liked") {
      acceptMatch(likerUserId);
    } else if (result == "Passed") {
      removeMatch(likerUserId);
    }
  }

  Future<void> acceptMatch(String otherUserId) async {
    final myUid = user?.uid;
    if (myUid == null) return;

    final db = FirebaseFirestore.instance;

    // 1. Create a match document for both users
    final matchId = myUid.compareTo(otherUserId) < 0
        ? '${myUid}_$otherUserId'
        : '${otherUserId}_$myUid';

    await db.collection('matches').doc(matchId).set({
      'users': [myUid, otherUserId],
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 2. Remove from likesReceived so the bubble disappears
    await db
        .collection('users')
        .doc(myUid)
        .collection('likedUsers')
        .doc(otherUserId) // direct delete by doc ID, no query needed
        .delete();

    // Active matches list updates automatically via listenToActiveMatches
    // since it's a live snapshot listener — no manual setState needed here.
  }

  Future<void> removeMatch(String otherUserId) async {
    final myUid = user?.uid;
    if (myUid == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(myUid)
        .collection('likedUsers')
        .doc(otherUserId) // direct delete by doc ID, no query needed
        .delete();
  }

  void onLongPressMessage(String matchId) {
    setState(() {
      selectionMode = true;
      selectedMessages.add(matchId);
    });
  }

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

  void deleteSelected() {
    // Deletes the match doc(s) for whatever's selected — removes the chat for both users.
    for (final matchId in selectedMessages) {
      FirebaseFirestore.instance.collection('matches').doc(matchId).delete();
    }
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
          // 🔝 Top Section – Pending Matches (incoming likes)
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

          // 🔽 Bottom Section – Active Messages (real matches from Firestore)
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