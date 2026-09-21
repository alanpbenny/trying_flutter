import 'package:flutter/material.dart';
import 'package:trying_flutter/services/auth_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
              // TODO: Navigate to profile edit screen
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
                        // Captured once, before any await. This stays valid
                        // even if AuthGate swaps LoginScreen in underneath
                        // us mid-flight (user.delete() signs the user out,
                        // which triggers that swap) — unlike `context`,
                        // which can go stale the moment that happens.
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
            value: true,
            onChanged: (val) {
              // TODO: Toggle notifications
            },
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