import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_screen.dart';
import 'services/supabase_service.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController gymController = TextEditingController();

  String selectedGoal = 'Muscle Gain';
  String selectedFrequency = '3-4 times/week';
  bool _isLoading = false;

  Future<void> _saveProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      await SupabaseService.updateProfile(
        userId: user.id,
        name: nameController.text.trim(),
        gym: gymController.text.trim(),
        goal: selectedGoal,
        frequency: selectedFrequency,
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error saving profile'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Profile")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: gymController,
                decoration: const InputDecoration(labelText: "Gym"),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedGoal,
                decoration: const InputDecoration(labelText: "Fitness Goal"),
                items: const [
                  DropdownMenuItem(value: 'Muscle Gain', child: Text('Muscle Gain')),
                  DropdownMenuItem(value: 'Weight Loss', child: Text('Weight Loss')),
                  DropdownMenuItem(value: 'Cardio', child: Text('Cardio')),
                  DropdownMenuItem(value: 'General Fitness', child: Text('General Fitness')),
                ],
                onChanged: (value) => setState(() => selectedGoal = value!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedFrequency,
                decoration: const InputDecoration(labelText: "Workout Frequency"),
                items: const [
                  DropdownMenuItem(value: '1-2 times/week', child: Text('1-2 times/week')),
                  DropdownMenuItem(value: '3-4 times/week', child: Text('3-4 times/week')),
                  DropdownMenuItem(value: '5+ times/week', child: Text('5+ times/week')),
                ],
                onChanged: (value) => setState(() => selectedFrequency = value!),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Continue", style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
