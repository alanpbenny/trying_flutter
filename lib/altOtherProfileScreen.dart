











import 'package:flutter/material.dart';
import '../models/current_user.dart';

class altotherprofilescreen extends StatelessWidget {
  final String name = "Alex";
  final String age = "22";
  final String gym = "Western Gym";
  final String goal = "Muscle Gain";

  const altotherprofilescreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name), centerTitle: true),
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
                      "$name, $age", // replace 22 with real age later
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text("Introduction", 
              style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              )),

            ),
            const SizedBox(height: 24),
             Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text("lnlasdnoodans asdpjpajpsdpajspd amsdpmapsdjpapdsjpa apsdpjmapdsjpasjdp pamsdpapdspdp pasjdpjpadpasjpd pjaspdjpadpas", 
              style: TextStyle(
              fontSize: 20,
              color: const Color.fromARGB(255, 0, 0, 0),
              )),

            ),
          ],
        ),
      ),
    );
  }
}



























































































































