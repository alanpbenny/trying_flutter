import 'dart:typed_data';
import 'package:flutter/material.dart';
//import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../services/user_service.dart';
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
  bool _isLoading = false;

  Uint8List? _pickedImageBytes;
  bool _isUploadingPhoto = false;

  Future<void> pickProfilePhoto() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );

    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    setState(() {
      _pickedImageBytes = bytes;
    });
  }

  /// Uploads the picked photo (if any) to Firebase Storage and returns its
  /// download URL. Returns null if the user never picked a photo.
  Future<String?> _uploadProfilePhotoIfNeeded(String uid) async {
    if (_pickedImageBytes == null) return null;

    setState(() => _isUploadingPhoto = true);
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_photos')
          .child('$uid.jpg');

      await ref.putData(
        _pickedImageBytes!,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      return await ref.getDownloadURL();
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }
  /*
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
  */
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

  void handleContinue() async {
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

    debugPrint("Name: ${nameController.text}");
    debugPrint("Gym: $selectedGym");
    debugPrint("Goal: $selectedGoal");
    debugPrint("Frequency: $selectedFrequency");
    debugPrint("DOB: $selectedDOB");
    debugPrint("Age: $age");

    setState(() => _isLoading = true);

    String uid = FirebaseAuth.instance.currentUser!.uid;

  String? photoUrl;
    try {
      photoUrl = await _uploadProfilePhotoIfNeeded(uid);
    } catch (e) {
      debugPrint("Photo upload failed: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Couldn't upload photo: $e"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'name': nameController.text.trim(),
      'gym': selectedGym,
      'goal': selectedGoal, // ✅ consistent
      'frequency': selectedFrequency, // ✅ consistent
      'age': age, // ✅ int, NOT string
      'onboardingComplete': true,
      'seenUsers': [], // 👈 ADD THIS
      'likedUsers': [],
      if (photoUrl != null) 'photoUrl': photoUrl,
    });

    await UserService.loadCurrentUser();

    if (mounted) setState(() => _isLoading = false);

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
              child: GestureDetector(
                onTap: pickProfilePhoto,
                child: Stack(
                  children: [
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(16),
                        image: _pickedImageBytes != null
                            ? DecorationImage(
                                image: MemoryImage(_pickedImageBytes!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _pickedImageBytes == null
                          ? const Icon(
                              Icons.person,
                              size: 80,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    if (_isUploadingPhoto)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          ),
                        ),
                      ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: pickProfilePhoto,
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

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _isLoading ? null : handleContinue,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text("Continue"),
            ),
          ],
        ),
      ),
    );
  }
}