import 'package:flutter/material.dart';
//import 'models/user.dart';
//import 'edit_profile_screen.dart';
import 'profile_setup_screen.dart';
import 'settings.dart';
import './models/user_model.dart';
import 'package:trying_flutter/services/user_service.dart';
import 'package:trying_flutter/models/current_user.dart';
//currentUser = UserModel();

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    await UserService.loadCurrentUser();
    debugPrint("After load: ${UserService.currentUser?.name}"); // ADD THIS
    debugPrint("After load: ${UserService.currentUser?.age}"); // ADD THIS

    debugPrint("After load: ${UserService.currentUser?.goal}"); // ADD THIS

    debugPrint("After load: ${UserService.currentUser?.gym}"); // ADD THIS

    debugPrint("After load: ${UserService.currentUser?.frequency}"); // ADD THIS

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    //final currentUser = UserService.currentUser;
    final user = UserService.currentUser;
    debugPrint("Current User in ProfileScreen: ${user?.name}");

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
            Center(
              child: Text(
                '${user?.name ?? 'Guest'}, ${user?.age ?? ''}',
                style: TextStyle(fontSize: 28),
              ),
            ),
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
                  Text("${user?.gym}", style: TextStyle(fontSize: 18)),
                  // ignore: unnecessary_string_interpolations
                  Text("${user?.goal}", style: TextStyle(fontSize: 18)),
                  Text("${user?.frequency}", style: TextStyle(fontSize: 18)),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                children: [
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
