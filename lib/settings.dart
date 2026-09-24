import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trying_flutter/services/auth_service.dart';
import 'profile_setup_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _loadingPreference = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
  }

  Future<void> _loadNotificationPreference() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (mounted) setState(() => _loadingPreference = false);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (mounted) {
        setState(() {
          // Defaults to true if the field has never been set (e.g. accounts
          // created before this toggle existed).
          _notificationsEnabled = doc.data()?['notificationsEnabled'] ?? true;
          _loadingPreference = false;
        });
      }
    } catch (e) {
      debugPrint('Failed to load notification preference: $e');
      if (mounted) setState(() => _loadingPreference = false);
    }
  }

  Future<void> _setNotificationsEnabled(bool val) async {
    final previous = _notificationsEnabled;
    setState(() => _notificationsEnabled = val); // optimistic UI update

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({'notificationsEnabled': val}, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Failed to save notification preference: $e');
      if (mounted) {
        setState(() => _notificationsEnabled = previous); // revert on failure
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't save that — try again.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          // 🔹 Account Section
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              "Account",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Edit Profile"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileSetupScreen(isEditing: true),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text("Delete Account"),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Delete Account"),
                  content: const Text(
                    "This permanently deletes your profile, matches, and messages. This can't be undone. Are you sure?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () async {
                        final navigator = Navigator.of(
                          context,
                          rootNavigator: true,
                        );
                        navigator.pop(); // close confirmation dialog

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) =>
                              const Center(child: CircularProgressIndicator()),
                        );

                        bool success = false;
                        try {
                          success = await AuthService().deleteAccount(context);
                        } finally {
                          navigator.pop(); // close loading spinner
                        }

                        if (success) {
                          navigator.popUntil((route) => route.isFirst);
                        }
                      },
                      child: const Text("Delete"),
                    ),
                  ],
                ),
              );
            },
          ),

          const Divider(),

          // 🔹 Notifications Section
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              "Notifications",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            title: const Text("Push Notifications"),
            value: _notificationsEnabled,
            onChanged: _loadingPreference ? null : _setNotificationsEnabled,
          ),

          const Divider(),

          // 🔹 Legal Section
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              "Legal",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text("Terms of Service"),
            onTap: () {
              // TODO: Open terms screen or URL
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text("Privacy Policy"),
            onTap: () {
              // TODO: Open privacy policy
            },
          ),

          const Divider(),

          // 🔹 App Version
          const ListTile(title: Text("App Version"), subtitle: Text("1.0.0")),

          const Divider(),

          // 🔹 Logout Button
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () async {
              await AuthService().signOut();
              debugPrint("Logged out");
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
    );
  }
}