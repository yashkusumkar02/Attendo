import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../controllers/splashscreen_controller/splash_controller.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({super.key});

  // Initialize the controller
  final SplashController _controller = Get.put(SplashController());

  @override
  Widget build(BuildContext context) {
    // Delayed navigation to the next screen (after 3 seconds)
    Future.delayed(Duration(seconds: 5), () {
      _controller.navigateToNextScreen(); // No error now
    });


    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'assets/images/splash_background.png', // Replace with your background image
            fit: BoxFit.cover,
          ),

          // Logo and Text in a Column
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Center items vertically
              children: [
                // Logo and Text in a Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo
                    Image.asset(
                      'assets/images/logo.png', // Replace with your logo
                      height: 100, // Adjust height for proper alignment
                    ),
                    const SizedBox(width: 5), // Spacing between logo and text

                    // App Name Text
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

                SizedBox(height: 60), // Space between logo and loader

                // Animated Loader (DotsTriangle)
                LoadingAnimationWidget.dotsTriangle(
                  color: Colors.blue, // Set color for animation
                  size: 50, // Adjust size of animation
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
