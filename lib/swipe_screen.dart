import 'package:flutter/material.dart';

class SwipeScreen extends StatefulWidget {
  const SwipeScreen({super.key});

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> {
  // 🔥 Fake users (mock data for now)
  final List<Map<String, String>> users = [
    {"name": "Alex", "gym": "GoodLife", "goal": "Muscle Gain"},
    {"name": "Jordan", "gym": "Fit4Less", "goal": "Weight Loss"},
    {"name": "Taylor", "gym": "YMCA", "goal": "Cardio"},
  ];

  int currentIndex = 0;

  void nextUser() {
    setState(() {
      if (currentIndex < users.length - 1) {
        currentIndex++;
      } else {
        currentIndex = 0; // loop back for now
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = users[currentIndex];

    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(title: const Text("Find Gym Buddies"),
        centerTitle: true
      ),
   
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // 🔥 Profile Card
            Expanded(
              child: Dismissible(
                key: ValueKey(user["name"]),
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
                    borderRadius: BorderRadius.circular(20),
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
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 40),
                ),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 👤 Profile info
                        Column(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.grey[300],
                              child: const Icon(Icons.person, size: 60),
                            ),
                            const SizedBox(height: 20),

                            Text(
                              user["name"]!,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              "Gym: ${user["gym"]}",
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              "Goal: ${user["goal"]}",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),

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

            const SizedBox(height: 24),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
