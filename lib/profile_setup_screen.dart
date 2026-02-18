import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../models/current_user.dart';
import '../models/user_model.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController nameController = TextEditingController();

  String selectedGoal = 'Muscle Gain';
  String selectedGym = 'Western Rec Centre';
  String selectedFrequency = '3-4 times/week';

  DateTime? selectedDOB;

  Future<void> pickDOB() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedDOB = picked;
      });
    }
  }

  int calculateAge(DateTime dob) {
    final today = DateTime.now();
    int age = today.year - dob.year;

    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }

    return age;
  }

  void handleContinue() {
    if (nameController.text.trim().isEmpty || selectedDOB == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    final age = calculateAge(selectedDOB!);

    if (age < 16) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must be at least 16 years old")),
      );
      return;
    }
    currentUser = UserModel(
      name: nameController.text.trim(),
      gym: selectedGym,
      goal: selectedGoal,
      frequency: selectedFrequency,
      dob: selectedDOB!,
    );

    debugPrint("Name: ${nameController.text}");
    debugPrint("Gym: $selectedGym");
    debugPrint("Goal: $selectedGoal");
    debugPrint("Frequency: $selectedFrequency");
    debugPrint("DOB: $selectedDOB");
    debugPrint("Age: $age");

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Please fill in basic information"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple[200],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🔵 Profile Picture
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 100,
                    backgroundColor: Colors.grey[300],
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        debugPrint("Add photo tapped");
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Center(
              child: Text(
                "So we can match you with the right gym buddy",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color.fromARGB(255, 83, 81, 81),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Name
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),

            const SizedBox(height: 16),

            // Gym dropdown
            DropdownButtonFormField<String>(
              initialValue: selectedGym,
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
              initialValue: selectedGoal,
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
              initialValue: selectedFrequency,
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

            const SizedBox(height: 16),

            // DOB Picker
            GestureDetector(
              onTap: pickDOB,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: "Date of Birth",
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  selectedDOB == null
                      ? "Select your date of birth"
                      : "${selectedDOB!.day.toString().padLeft(2, '0')}/"
                            "${selectedDOB!.month.toString().padLeft(2, '0')}/"
                            "${selectedDOB!.year}",
                  style: TextStyle(
                    color: selectedDOB == null ? Colors.grey : Colors.black,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: handleContinue,
              child: const Text("Continue"),
            ),
          ],
        ),
      ),
    );
  }
}
