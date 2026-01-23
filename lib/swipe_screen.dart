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
      appBar: AppBar(title: const Text("Find Gym Buddies")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // 🔥 Profile Card
            Expanded(
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 🔹 Profile Info
                      Column(
                        children: [
                          const Icon(Icons.person, size: 100),
                          const SizedBox(height: 20),

                          Text(
                            user["name"]!,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text("Gym: ${user["gym"]}"),
                          Text("Goal: ${user["goal"]}"),
                        ],
                      ),

                      // 🔹 Buttons INSIDE card
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(20),
                            ),
                            onPressed: nextUser,
                            child: const Icon(Icons.close, size: 30),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(20),
                            ),
                            onPressed: nextUser,
                            child: const Icon(Icons.favorite, size: 30),
                          ),
                        ],
                      ),
                    ],
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
