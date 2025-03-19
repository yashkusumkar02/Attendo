import 'dart:convert';
import 'dart:typed_data';
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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStudentDetails();
  }

  // ✅ Fetch Student Data from Firestore
  Future<void> _fetchStudentDetails() async {
    if (user == null) return;

    try {
      DocumentSnapshot studentDoc = await FirebaseFirestore.instance
          .collection("students")
          .doc(user!.uid)
          .get();

      if (studentDoc.exists) {
        setState(() {
          studentData = studentDoc.data() as Map<String, dynamic>;
          isLoading = false;
        });
      } else {
        Get.snackbar("Error", "Student details not found.");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load profile details: $e");
      setState(() {
        isLoading = false;
      });
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
          onPressed: () => Get.back(),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // ✅ Show Loading Indicator
          : SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),

              // ✅ Profile Picture (Fetch from Firestore)
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: studentData?["profileImageBase64"] != null
                      ? MemoryImage(Uint8List.fromList(
                      base64Decode(studentData!["profileImageBase64"])))
                      : AssetImage("assets/images/teacher_profile.png")
                  as ImageProvider,
                ),
              ),

              SizedBox(height: 15),

              // ✅ Profile Details
              _profileInfo("Name", studentData?["name"] ?? "N/A"),
              _profileInfo("Email", studentData?["email"] ?? "N/A"),
              _profileInfo("College", studentData?["collegeName"] ?? "N/A"),
              _profileInfo("Branch", studentData?["branch"] ?? "N/A"),
              _profileInfo("Semester", studentData?["semester"] ?? "N/A"),
              _profileInfo("Year", studentData?["year"] ?? "N/A"),

              SizedBox(height: 30),
              Divider(thickness: 1, color: Colors.grey[300]),
              SizedBox(height: 30),

              // ✅ Logout Button
              ElevatedButton.icon(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Get.offAllNamed('/student-login');
                },
                icon: Icon(Icons.logout, color: Colors.white),
                label: Text(
                  "Logout",
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Helper Widget for Profile Information
  Widget _profileInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Text(
                label,
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              flex: 5,
              child: Text(
                value,
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                softWrap: true,
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
