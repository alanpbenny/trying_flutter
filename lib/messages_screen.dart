import 'package:flutter/material.dart';
import 'messages.dart';
import 'altOtherProfileScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  // Pending matches are now purely driven by incomingLikes from Firestore
  List<String> activeMessages = ["Alex", "Jamie", "Chris"];
  bool selectionMode = false;
  Set<String> selectedMessages = {};
  final user = FirebaseAuth.instance.currentUser;

  List<String> incomingLikes = [];
  Map<String, String> userNames = {};

  Future<void> fetchUserName(String uid) async {
  if (userNames.containsKey(uid)) return; // already fetched
  
  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .get();
  
  setState(() {
    userNames[uid] = doc.data()?['name'] ?? 'Unknown';
  });
}


  @override
  void initState() {
    super.initState();
    listenToIncomingLikes();
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
      .doc(otherUserId)  // direct delete by doc ID, no query needed
      .delete();

    // 3. Update local active messages list
    setState(() {
      activeMessages.insert(0, otherUserId);
    });
  }

  Future<void> removeMatch(String otherUserId) async {
  final myUid = user?.uid;
  if (myUid == null) return;

  await FirebaseFirestore.instance
      .collection('users')
      .doc(myUid)
      .collection('likedUsers')
      .doc(otherUserId)  // direct delete by doc ID, no query needed
      .delete();
}

  void onLongPressMessage(String user) {
    setState(() {
      selectionMode = true;
      selectedMessages.add(user);
    });
  }

  void onTapMessage(String user) {
    if (selectionMode) {
      setState(() {
        if (selectedMessages.contains(user)) {
          selectedMessages.remove(user);
        } else {
          selectedMessages.add(user);
        }
        if (selectedMessages.isEmpty) {
          selectionMode = false;
        }
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OpenedMessagesScreen(user: user),
        ),
      );
    }
  }

  void deleteSelected() {
    setState(() {
      activeMessages.removeWhere((user) => selectedMessages.contains(user));
      selectedMessages.clear();
      selectionMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                )
              ]
            : [],
      ),
      body: Column(
        children: [
          // 🔝 Top Section – Pending Matches (incoming likes)
          if (incomingLikes.isNotEmpty)
            SizedBox(
              height: 110,
              child: Container(
                color: Colors.grey[200],
                padding: const EdgeInsets.only(top: 12),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: incomingLikes.length,
                  itemBuilder: (context, index) {
                    final likerId = incomingLikes[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () => openFullProfile(likerId),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                              children: [
                                const CircleAvatar(
                                  radius: 30,
                                  child: Icon(Icons.person),
                                ),
                                // 🔴 New-like badge
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    width: 14,
                                    height: 14,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            SizedBox(
                              width: 64,
                              child: Text(
                                userNames[likerId] ?? 'Loading...',  // instead of just likerId,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12),
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

          // 🔽 Bottom Section – Active Messages
          Expanded(
            child: activeMessages.isEmpty
                ? const Center(child: Text("No messages yet"))
                : ListView.builder(
                    itemCount: activeMessages.length,
                    itemBuilder: (context, index) {
                      final u = activeMessages[index];
                      final isSelected = selectedMessages.contains(u);
                      return ListTile(
                        onTap: () => onTapMessage(u),
                        onLongPress: () => onLongPressMessage(u),
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(u),
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