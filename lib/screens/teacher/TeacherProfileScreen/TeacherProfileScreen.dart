import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TeacherProfileScreen extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser; // ✅ Get logged-in user info

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Teacher Profile",
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(), // ✅ Go back to the previous screen
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage("assets/images/teacher_profile.png"), // Replace with real image if needed
              ),
            ),
            SizedBox(height: 15),
            Text(
              user?.displayName ?? "Teacher Name",
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              user?.email ?? "teacher@example.com",
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 30),
            Divider(thickness: 1, color: Colors.grey[300]),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Get.offAllNamed('/teacher-login'); // ✅ Redirect to login after logout
              },
              icon: Icon(Icons.logout, color: Colors.white),
              label: Text(
                "Logout",
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
