import 'package:flutter/material.dart';
import 'models/user.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Matches")),
      body: matches.isEmpty
          ? const Center(
              child: Text(
                "No matches yet. Start swiping!",
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: matches.length,
              itemBuilder: (context, index) {
                final match = matches[index];
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(match["name"]!),
                  subtitle: Text("${match["gym"]} - ${match["goal"]}"),
                );
              },
            ),
    );
  }
}
