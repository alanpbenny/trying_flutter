import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OpenedMessagesScreen extends StatefulWidget {
  final String matchId;
  final String userId; // the other person's uid

  const OpenedMessagesScreen({
    super.key,
    required this.matchId,
    required this.userId,
  });

  @override
  State<OpenedMessagesScreen> createState() => _OpenedMessagesScreenState();
}

class _OpenedMessagesScreenState extends State<OpenedMessagesScreen> {
  final TextEditingController _controller = TextEditingController();
  final myUid = FirebaseAuth.instance.currentUser?.uid;
  String? _otherUserName;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();
      if (!mounted) return;
      setState(() => _otherUserName = doc.data()?['name'] ?? 'Unknown');
    } catch (e) {
      debugPrint('fetchUserName failed for ${widget.userId}: $e');
      if (mounted) setState(() => _otherUserName = 'Unknown');
    }
  }

  CollectionReference<Map<String, dynamic>> get _messagesRef =>
      FirebaseFirestore.instance
          .collection('matches')
          .doc(widget.matchId)
          .collection('messages');

  Future<void> sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || myUid == null) return;

    _controller.clear();
    try {
      await _messagesRef.add({
        'senderId': myUid,
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('sendMessage failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Message couldn't be sent.")),
        );
      }
    }
  }

  Widget buildMessageBubble(String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(text, style: TextStyle(color: isMe ? Colors.white : Colors.black)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_otherUserName ?? 'Unknown')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _messagesRef.orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Could not load messages.'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(child: Text('Say hi 👋'));
                }
                return ListView.builder(
                  reverse: true,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data();
                    return buildMessageBubble(data['text'] ?? '', data['senderId'] == myUid);
                  },
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              color: Colors.grey[100],
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "Type a message...",
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => sendMessage(),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.send), onPressed: sendMessage),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}