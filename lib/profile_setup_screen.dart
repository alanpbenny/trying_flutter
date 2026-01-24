import 'package:flutter/material.dart';
import 'home_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController gymController = TextEditingController();

  String selectedGoal = 'Muscle Gain';
  String selectedGym = 'Western Rec Centre';
  String selectedFrequency = '3-4 times/week';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Please fill in basic information")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "So we can match you with the right gym buddy",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color.fromARGB(255, 83, 81, 81),
              ),
            ),

            const SizedBox(height: 24),
            // Name
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),

            const SizedBox(height: 16),

            // Goal dropdown
            DropdownButtonFormField<String>(
              value: selectedGym,
              decoration: const InputDecoration(labelText: "Gym name"),
              items: const [
                DropdownMenuItem(
                  value: 'Western Rec Centre',
                  child: Text('Western Rec Centre'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  selectedGym = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Goal dropdown
            DropdownButtonFormField<String>(
              value: selectedGoal,
              decoration: const InputDecoration(labelText: "Fitness Goal"),
              items: const [
                DropdownMenuItem(
                  value: 'Muscle Gain',
                  child: Text('Muscle Gain'),
                ),
                DropdownMenuItem(
                  value: 'Weight Loss',
                  child: Text('Weight Loss'),
                ),
                DropdownMenuItem(value: 'Cardio', child: Text('Cardio')),
                DropdownMenuItem(
                  value: 'General Fitness',
                  child: Text('General Fitness'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  selectedGoal = value!;
                });
              },
            ),

            const SizedBox(height: 16),

            // Frequency dropdown
            DropdownButtonFormField<String>(
              value: selectedFrequency,
              decoration: const InputDecoration(labelText: "Workout Frequency"),
              items: const [
                DropdownMenuItem(
                  value: '1-2 times/week',
                  child: Text('1-2 times/week'),
                ),
                DropdownMenuItem(
                  value: '3-4 times/week',
                  child: Text('3-4 times/week'),
                ),
                DropdownMenuItem(
                  value: '5+ times/week',
                  child: Text('5+ times/week'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  selectedFrequency = value!;
                });
              },
            ),

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: () {
                // For now, just print values
                debugPrint("Name: ${nameController.text}");
                debugPrint("Gym: ${gymController.text}");
                debugPrint("Goal: $selectedGoal");
                debugPrint("Frequency: $selectedFrequency");
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );

                // Later: navigate to swipe screen
              },
              child: const Text("Continue"),
            ),
          ],
        ),
      ),
    );
  }
}
