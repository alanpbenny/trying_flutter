import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OpenedMessagesScreen extends StatefulWidget {
  final String userId;

  const OpenedMessagesScreen({super.key, required this.userId});

  @override
  State<OpenedMessagesScreen> createState() => _OpenedMessagesScreenState();
}

class _OpenedMessagesScreenState extends State<OpenedMessagesScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _otherUserName; // null while loading

  List<Map<String, dynamic>> messages = [
    {"text": "Hey!", "isMe": false},
    {"text": "You training today?", "isMe": false},
  ];

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

      setState(() {
        _otherUserName = doc.data()?['name'] ?? 'Unknown';
      });
    } catch (e) {
      debugPrint('fetchUserName failed for ${widget.userId}: $e');
      if (mounted) setState(() => _otherUserName = 'Unknown');
    }
  }

  void sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      messages.add({
        "text": _controller.text.trim(),
        "isMe": true,
      });
    });

    _controller.clear();
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
        child: Text(
          text,
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_otherUserName ?? 'Unknown'),
      ),
      body: Column(
        children: [
          // 🔼 Messages list
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return buildMessageBubble(msg["text"], msg["isMe"]);
              },
            ),
          ),

          // 🔽 Input bar
          Container(
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
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
