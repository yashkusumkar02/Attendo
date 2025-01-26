import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentProfileScreen extends StatefulWidget {
  @override
  _StudentProfileScreenState createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? studentData;

  @override
  void initState() {
    super.initState();
    _fetchStudentDetails(); // ✅ Fetch details from Firestore
  }

  // ✅ Fetch Student Data from Firestore
  // ✅ Ensure we fetch from "students" collection instead of "users"
  Future<void> _fetchStudentDetails() async {
    if (user == null) return;

    try {
      DocumentSnapshot studentDoc =
      await FirebaseFirestore.instance.collection("students").doc(user!.uid).get();

      if (studentDoc.exists) {
        setState(() {
          studentData = studentDoc.data() as Map<String, dynamic>;
        });
      } else {
        Get.snackbar("Error", "Student details not found.");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load profile details: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Student Profile",
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
        child: studentData == null
            ? Center(child: CircularProgressIndicator()) // ✅ Show loading indicator while fetching
            : Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage("assets/images/teacher_profile.png"),
              ),
            ),
            SizedBox(height: 15),
            _profileInfo("Name", studentData?["name"] ?? "N/A"),
            _profileInfo("Email", studentData?["email"] ?? "N/A"),
            _profileInfo("College", studentData?["collegeName"] ?? "N/A"),
            _profileInfo("Branch", studentData?["branch"] ?? "N/A"),
            _profileInfo("Semester", studentData?["semester"] ?? "N/A"),
            _profileInfo("Year", studentData?["year"] ?? "N/A"),
            SizedBox(height: 30),
            Divider(thickness: 1, color: Colors.grey[300]),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Get.offAllNamed('/student-login'); // ✅ Redirect to login after logout
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

  // ✅ Helper Widget for Profile Information
  // ✅ Helper Widget for Profile Information
  Widget _profileInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // ✅ Align text properly
      children: [
        SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start, // ✅ Align top in case of wrapping
          children: [
            Expanded(
              flex: 3, // ✅ Adjust label width
              child: Text(
                label,
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(width: 10), // ✅ Provide spacing between label and value
            Expanded(
              flex: 5, // ✅ Give more space for value
              child: Text(
                value,
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                overflow: TextOverflow.ellipsis, // ✅ Trim long text
                maxLines: 2, // ✅ Limit to 2 lines
                softWrap: true, // ✅ Allow wrapping if needed
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Divider(thickness: 1, color: Colors.grey[300]),
      ],
    );
  }
}
