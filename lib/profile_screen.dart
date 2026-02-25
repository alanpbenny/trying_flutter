import 'package:flutter/material.dart';
//import 'edit_profile_screen.dart';
import 'profile_setup_screen.dart';
import 'settings.dart';
import '../models/current_user.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Profile"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: CircleAvatar(
                radius: 80,
                child: Icon(Icons.person, size: 80),
              ),
            ),
            Center(child: Text(currentUser?.name ?? 'Guest', style: TextStyle(fontSize: 28))),
            //Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileSetupScreen(),
                    ),
                  );
                },
                child: const Text("Edit Profile"),
              ),
            ),

            const SizedBox(height: 24),

            //const Text("Name: Alex", style: TextStyle(fontSize: 18)),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min, // prevents taking full height
                children: [
                  Text(
                    "${currentUser?.gym}",
                    style: TextStyle(fontSize: 18),
                  ),
                  Text("${currentUser?.goal ?? 'None'}", style: TextStyle(fontSize: 18)),
                  Text(
                    "Frequency: ${currentUser?.frequency ?? 'None'}",
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                children:  [
                  ListTile(
                    title: Text('FAQ'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                  ListTile(
                    title: Text('Updates'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                  ListTile(
                    title: Text('Settings'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
