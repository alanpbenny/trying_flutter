import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../login_screen.dart';
import '../home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../profile_setup_screen.dart';


class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), // ✅ FIXED
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!authSnapshot.hasData) {
          return const LoginScreen();
        }

        return _OnboardingGate(uid: authSnapshot.data!.uid);
      },
    );
  }
}

class _OnboardingGate extends StatelessWidget {
  final String uid;
  const _OnboardingGate({required this.uid});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!userSnapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 🔥 FIXED: no redirect to login
        if (!userSnapshot.data!.exists) {
          return const ProfileSetupScreen();
        }

        final data =
            userSnapshot.data!.data() as Map<String, dynamic>? ?? {};

        final onboardingComplete =
            data['onboardingComplete'] ?? false;

        if (!onboardingComplete) {
          return const ProfileSetupScreen();
        }

        return const HomeScreen();
      },
    );
  }
}