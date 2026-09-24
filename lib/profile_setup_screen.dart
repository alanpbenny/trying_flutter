import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../services/user_service.dart';

class ProfileSetupScreen extends StatefulWidget {
  final bool isEditing;

  const ProfileSetupScreen({super.key, this.isEditing = false});

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

  DateTime? selectedDOB;

  // Set from the existing profile when editing. Used as fallbacks so an
  // edit doesn't force re-entering data that's already on file.
  int? _existingAge;
  String? _existingPhotoUrl;

  @override
  void initState() {
    super.initState();
    final current = UserService.currentUser;
    if (current != null) {
      nameController.text = current.name;
      if (current.gym.isNotEmpty) selectedGym = current.gym;
      if (current.goal.isNotEmpty) selectedGoal = current.goal;
      if (current.frequency.isNotEmpty) selectedFrequency = current.frequency;
      selectedDOB = current.dob; // null for accounts created before dob was tracked
      _existingAge = current.age;
      _existingPhotoUrl = current.photoUrl;
    }
  }

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
  /// download URL. Returns null if the user never picked a new photo.
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

  Future<void> pickDOB() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDOB ?? DateTime(2000),
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
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your name")),
      );
      return;
    }

    // Accounts created before dob was tracked won't have one to fall back
    // on — for those, only force a DOB pick on first-time setup, not on
    // every edit of an otherwise-complete profile.
    if (selectedDOB == null && _existingAge == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select your date of birth")),
      );
      return;
    }

    final age = selectedDOB != null ? calculateAge(selectedDOB!) : _existingAge!;

    if (age < 16) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must be at least 16 years old")),
      );
      return;
    }

    setState(() => _isLoading = true);

    String uid = FirebaseAuth.instance.currentUser!.uid;

    String? newPhotoUrl;
    try {
      newPhotoUrl = await _uploadProfilePhotoIfNeeded(uid);
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

    final data = <String, dynamic>{
      'name': nameController.text.trim(),
      'gym': selectedGym,
      'goal': selectedGoal,
      'frequency': selectedFrequency,
      'age': age,
      'onboardingComplete': true,
    };

    if (selectedDOB != null) {
      data['dob'] = Timestamp.fromDate(selectedDOB!);
    }

    // Always resolve to *something* if a photo exists — either the newly
    // uploaded one or whatever was already there. Never omit this key
    // when a photo exists; with merge:true that's harmless either way,
    // but being explicit avoids relying on that safety net.
    final resolvedPhotoUrl = newPhotoUrl ?? _existingPhotoUrl;
    if (resolvedPhotoUrl != null) {
      data['photoUrl'] = resolvedPhotoUrl;
    }

    // merge:true means fields not included here — notably seenUsers and
    // likedUsers, which this screen has no business touching — are left
    // exactly as they were, instead of being wiped back to empty arrays.
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set(data, SetOptions(merge: true));

    await UserService.loadCurrentUser();

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (widget.isEditing) {
      Navigator.pop(context);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasExistingPhoto = _pickedImageBytes == null && _existingPhotoUrl != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? "Edit Profile" : "Please fill in basic information"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple[200],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                            : hasExistingPhoto
                                ? DecorationImage(
                                    image: NetworkImage(_existingPhotoUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                      ),
                      child: (_pickedImageBytes == null && !hasExistingPhoto)
                          ? const Icon(Icons.person, size: 80, color: Colors.white)
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
                          child: const Icon(Icons.add, size: 40, color: Colors.white),
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

            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),

            const SizedBox(height: 16),

            GestureDetector(
              onTap: pickDOB,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: "Date of Birth",
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  selectedDOB == null
                      ? (_existingAge != null
                          ? "Not set — tap to add"
                          : "Select your date of birth")
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

            DropdownButtonFormField<String>(
              initialValue: selectedGoal,
              decoration: const InputDecoration(labelText: "Fitness Goal"),
              items: const [
                DropdownMenuItem(value: 'Muscle Gain', child: Text('Muscle Gain')),
                DropdownMenuItem(value: 'Weight Loss', child: Text('Weight Loss')),
                DropdownMenuItem(value: 'Cardio', child: Text('Cardio')),
                DropdownMenuItem(value: 'General Fitness', child: Text('General Fitness')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedGoal = value!;
                });
              },
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: selectedFrequency,
              decoration: const InputDecoration(labelText: "Workout Frequency"),
              items: const [
                DropdownMenuItem(value: '1-2 times/week', child: Text('1-2 times/week')),
                DropdownMenuItem(value: '3-4 times/week', child: Text('3-4 times/week')),
                DropdownMenuItem(value: '5+ times/week', child: Text('5+ times/week')),
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
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(widget.isEditing ? "Save" : "Continue"),
            ),
          ],
        ),
      ),
    );
  }
}