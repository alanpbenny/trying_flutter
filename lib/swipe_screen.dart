import 'package:flutter/material.dart';

class SwipeScreen extends StatefulWidget {
  const SwipeScreen({super.key});

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> {
  final List<Map<String, String>> users = [
    {"name": "Alex", "age": "22", "gym": "Western Gym", "goal": "Muscle Gain"},
    {"name": "Jamie", "age": "30", "gym": "Downtown Fitness", "goal": "Weight Loss"},
    {"name": "Chris", "age": "27", "gym": "City Gym", "goal": "Endurance"},
  ];

  int currentIndex = 0;

  void nextUser() {
    setState(() {
      currentIndex = (currentIndex + 1) % users.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = users[currentIndex];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Find Gym Buddies"),
        centerTitle: true,
      ),
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
                  child: const Icon(Icons.favorite, color: Colors.white, size: 40),
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
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // 🔼 Flexible header (fills space, no overflow)
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                            child: Container(
                              width: double.infinity,
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(
                                  Icons.person,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // 👤 Name + Age
                        Text(
                          "${user["name"]}, ${user["age"]}",
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // 🏋️ Gym
                        Text(
                          "Gym: ${user["gym"]}",
                          style: const TextStyle(fontSize: 16),
                        ),

                        // 🎯 Goal
                        Text(
                          "Goal: ${user["goal"]}",
                          style: const TextStyle(fontSize: 16),
                        ),

                        const SizedBox(height: 16),

                        // ❤️ / ❌ Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(18),
                              ),
                              onPressed: nextUser,
                              child: const Icon(Icons.close, size: 28),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(18),
                              ),
                              onPressed: nextUser,
                              child: const Icon(Icons.favorite, size: 28),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
