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
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {

        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ❌ Not logged in
        if (!authSnapshot.hasData) {
          return const LoginScreen();
        }

        // ✅ Logged in → now check Firestore
        final user = authSnapshot.data!;

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get(),
          builder: (context, userSnapshot) {

            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              // Edge case: user exists in Auth but not Firestore
              return const LoginScreen(); // or onboarding
            }

            final data = userSnapshot.data!.data() as Map<String, dynamic>;

            final onboardingComplete = data['onboardingComplete'] ?? false;

            if (!onboardingComplete) {
              return const ProfileSetupScreen(); // 👈 YOU NEED THIS
            }

            return const HomeScreen();
          },
        );
      },
    );
  }
}