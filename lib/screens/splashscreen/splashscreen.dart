import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/splashscreen_controller/splash_controller.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({super.key});

  // Initialize the controller
  final SplashController _controller = Get.put(SplashController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'assets/images/splash_background.png', // Replace with your background image
            fit: BoxFit.cover,
          ),

          // Logo and Text in a Row
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center, // Center horizontally
              crossAxisAlignment: CrossAxisAlignment.center, // Align items in the center vertically
              children: [
                // Logo
                Image.asset(
                  'assets/images/logo.png', // Replace with your logo
                  height: 100, // Adjust height for proper alignment
                ),
                const SizedBox(width: 5), // Add some spacing between logo and text
                // Text
                Text(
                  'Attendo',
                  style: GoogleFonts.poppins(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
