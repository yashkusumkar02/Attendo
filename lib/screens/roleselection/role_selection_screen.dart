import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';  // Import the animated_text_kit package

import '../../routes/app_routes.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFE),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Logo and App Name in Horizontal Alignment
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png', // Replace with your logo image
                    height: 80, // Adjust size as needed
                  ),
                  const SizedBox(width: 10), // Space between logo and text
                  // Typing animation for the "Attendo" text
                  DefaultTextStyle(
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    child: AnimatedTextKit(
                      animatedTexts: [
                        TypewriterAnimatedText(
                          'Attendo',
                          speed: const Duration(milliseconds: 100), // Adjust typing speed here
                        ),
                      ],
                      repeatForever: false, // Set to false if you only want it to animate once
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Welcome Message and Description
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome to Attendo',
                    style: GoogleFonts.poppins(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Please select your login option:',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Buttons for Teacher and Student Login
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // Teacher Login Action
                      Get.offNamed(AppRoutes.teacherLogin);
                    },
                    icon: Image.asset(
                      'assets/images/teacher_logo.png', // Replace with your teacher logo image
                      height: 25,
                      width: 25,
                    ),
                    label: Text(
                      'Login with Teacher',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                          color: Colors.white
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton.icon(
                    onPressed: () {
                      Get.offNamed(AppRoutes.studentLogin);
                    },
                    icon: Image.asset(
                      'assets/images/student_logo.png', // Replace with your student logo image
                      height: 25,
                      width: 25,
                    ),
                    label: Text(
                      'Login with Student',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                          color: Colors.white
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
