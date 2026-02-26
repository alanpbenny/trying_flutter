import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'models/user.dart';
import 'services/mock_data.dart';
=======
import 'package:trying_flutter/otherProfile_scree.dart';
>>>>>>> AlanUI

class SwipeScreen extends StatefulWidget {
  const SwipeScreen({super.key});

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> {
<<<<<<< HEAD
=======
  final List<Map<String, String>> users = [
    {"name": "Alex", "age": "22", "gym": "Western Gym", "goal": "Muscle Gain"},
    {
      "name": "Jamie",
      "age": "30",
      "gym": "Downtown Fitness",
      "goal": "Weight Loss",
    },
    {"name": "Chris", "age": "27", "gym": "City Gym", "goal": "Endurance"},
  ];

>>>>>>> AlanUI
  int currentIndex = 0;

  void nextUser() {
    debugPrint("Moving to next user");
    setState(() {
<<<<<<< HEAD
      if (currentIndex < mockProfiles.length - 1) {
        currentIndex++;
      } else {
        currentIndex = 0; // loop back for now
      }
    });
  }

  void likeUser() {
    matches.add(mockProfiles[currentIndex]);
    nextUser();
=======
      currentIndex = (currentIndex + 1) % users.length;
    });
  }

  void openFullProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OtherProfileScreen(user: users[currentIndex]["name"]!)),
    );

    if (result == "Liked") {
      debugPrint("Moving to next user");

      nextUser();
    }

    if (result == "Passed") {
      nextUser();
    }
>>>>>>> AlanUI
  }

  @override
  Widget build(BuildContext context) {
    final user = mockProfiles[currentIndex];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text("Find Gym Buddies"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // 🔥 Profile Card
            Expanded(
              child: Dismissible(
                key: ValueKey("${user["name"]}-$currentIndex"),
                direction: DismissDirection.horizontal,
                onDismissed: (direction) {
                  if (direction == DismissDirection.startToEnd) {
                    debugPrint("Liked ${user["name"]}");
                  } else {
                    debugPrint("Passed ${user["name"]}");
                  }
                  nextUser();
                },
                background: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 20),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                secondaryBackground: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 40),
                ),
                // ✅ GestureDetector goes INSIDE child
                child: GestureDetector(
                  onTap: () {
                    openFullProfile();
                  },

                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Stack(
                      children: [
                        // 🔥 Full background image (placeholder for now)
                        Positioned.fill(
                          child: Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.person,
                              size: 120,
                              color: Colors.grey,
                            ),
                          ),
                        ),

                        // 🌫️ Gradient for text readability
                        Positioned.fill(
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.transparent, Colors.black87],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
<<<<<<< HEAD
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(20),
                            ),
                            onPressed: likeUser,
                            child: const Icon(Icons.favorite, size: 30),
=======
                        ),

                        // 📝 Text + buttons overlay
                        Positioned(
                          left: 20,
                          right: 20,
                          bottom: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${user["name"]}, ${user["age"]}",
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Gym: ${user["gym"]}",
                                style: const TextStyle(color: Colors.white),
                              ),
                              Text(
                                "Goal: ${user["goal"]}",
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 12),

                              // ❤️ ❌ Buttons
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      shape: const CircleBorder(),
                                      padding: const EdgeInsets.all(18),
                                    ),
                                    onPressed: () {
                                      nextUser();
                                      debugPrint("Passed ${user["name"]}");
                                    },
                                    child: const Icon(Icons.close, size: 28),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      shape: const CircleBorder(),
                                      padding: const EdgeInsets.all(18),
                                    ),
                                    onPressed: () {
                                      nextUser();

                                      debugPrint("Liked ${user["name"]}");
                                    },
                                    child: const Icon(Icons.favorite, size: 28),
                                  ),
                                ],
                              ),
                            ],
>>>>>>> AlanUI
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
