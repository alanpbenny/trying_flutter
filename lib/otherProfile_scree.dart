import 'package:flutter/material.dart';
import '../models/current_user.dart';
import '../models/user_model.dart';
class OtherProfileScreen extends StatelessWidget {
  final UserModel user;

  OtherProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(user.name), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 4 / 5,
              child: Stack(
                children: [
                  // 🔽 Image layer
                  Container(
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.person, size: 120, color: Colors.white),
                    ),
                  ),

                  // 🔽 Gradient overlay (makes text readable)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.center,
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 🔽 Name + Age overlay
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 20,
                    child: Text(
                      "${user.name}, ${user.age}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: Row(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(18),
                        ),
                        onPressed: () {
                          Navigator.pop(context, "Passed");
                        },
                        child: const Icon(Icons.close, size: 28, color: Colors.black),
                      ),
                       ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(18),
                        ),
                        onPressed: () {
                          Navigator.pop(context, "Liked");
                        },
                        child: const Icon(Icons.check, size: 28, color: Colors.black),
                      ),
                    ],
                  ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "Introduction",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "lnlasdnoodans asdpjpajpsdpajspd amsdpmapsdjpapdsjpa apsdpjmapdsjpasjdp pamsdpapdspdp pasjdpjpadpasjpd pjaspdjpadpas",
                style: TextStyle(
                  fontSize: 20,
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
