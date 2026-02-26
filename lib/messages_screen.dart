import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'models/user.dart';
=======
import 'messages.dart';
import 'otherProfile_scree.dart';
import 'altOtherProfileScreen.dart';
>>>>>>> AlanUI

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<String> pendingMatches = ["User 1", "User 2", "User 3", "User 4"];
  List<String> activeMessages = ["Alex", "Jamie", "Chris"];

  bool selectionMode = false;
  Set<String> selectedMessages = {};

   void openFullProfile(String user) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OtherProfileScreen(user: user)),
    );

    if (result == "Liked") {
      debugPrint("Moving to next user");

      acceptMatch(user); // For demo, we just accept "User 1". In real app, pass the actual user.
    }

    if (result == "Passed") {
      removeMatch(user); // For demo, we just remove "User 1". In real app, pass the actual user.
    }
  }

  void acceptMatch(String user) {
    setState(() {
      pendingMatches.remove(user);
      activeMessages.insert(0, user);
    });
  }

  void removeMatch(String user) {
    setState(() {
      pendingMatches.remove(user);
      //activeMessages.insert(0, user);
    });
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
      // TODO: Navigate to chat screen
      Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OpenedMessagesScreen(user: user),
                    ),
                  );
      debugPrint("Open chat with $user");
    }
  }

  void deleteSelected() {
    setState(() {
      activeMessages
          .removeWhere((user) => selectedMessages.contains(user));
      selectedMessages.clear();
      selectionMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
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
=======
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
          // 🔝 Top Section – Pending Matches
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey[200],
              padding: const EdgeInsets.only(top: 16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: pendingMatches.map((user) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () {
                       openFullProfile(user);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircleAvatar(
                            radius: 30,
                            child: Icon(Icons.person),
                          ),
                          const SizedBox(height: 6),
                          Text(user),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // 🔽 Bottom Section – Active Messages
          Expanded(
            flex: 4,
            child: ListView.builder(
              itemCount: activeMessages.length,
              itemBuilder: (context, index) {
                final user = activeMessages[index];
                final isSelected = selectedMessages.contains(user);

                return ListTile(
                  onTap: () => onTapMessage(user),
                  onLongPress: () => onLongPressMessage(user),
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(user),
                  subtitle: const Text("Say hi 👋"),
                  selected: isSelected,
                  selectedTileColor: Colors.blue.withOpacity(0.2),
                );
              },
            ),
          ),
        ],
      ),
>>>>>>> AlanUI
    );
  }
}
