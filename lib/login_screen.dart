import 'package:flutter/material.dart';
import 'package:trying_flutter/services/auth_service.dart';
//import 'package:supabase_flutter/supabase_flutter.dart';
import 'profile_setup_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './models/user_model.dart';
import 'package:trying_flutter/services/user_service.dart';
import 'package:trying_flutter/models/current_user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  Future<void> flow() async {
    debugPrint("In flow rn!");

    if (!mounted) return;

    setState(() => _isLoading = true);

    final user = await AuthService().signInWithGoogle();

    if (!mounted) return; // 🔥 critical

    setState(() => _isLoading = false);

    if (user == null) return;

    debugPrint("Doing the decision!");

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!mounted) return; // 🔥 critical again

    final data = userDoc.data();
    bool onboardingComplete = data?['onboardingComplete'] ?? false;

    if (onboardingComplete) {
      await UserService.loadCurrentUser();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // App Title
              const Text(
                "Spottr",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              const Text(
                "Find your workout partner",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),

              const Spacer(),

              // Google Sign-In Button
              ElevatedButton.icon(
                onPressed: () async {
                  debugPrint("Clicked on Login!");

                  flow();
                },
                icon: Image.asset('assets/google_logo.png', height: 20),
                label: const Text(
                  "Continue with Google",
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: const BorderSide(color: Colors.grey),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                "By continuing, you agree to our Terms & Privacy Policy",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
