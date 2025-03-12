import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:attendo/routes/app_routes.dart';
import 'package:attendo/screens/student/camera_profile/Camera_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class StudentProfilePage extends StatefulWidget {
  final String studentId;

  StudentProfilePage({required this.studentId});

  @override
  _StudentProfilePageState createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  String? uploadedImageBase64;

  @override
  void initState() {
    super.initState();

    if (widget.studentId.isEmpty) {
      Future.delayed(Duration.zero, () {
        Get.snackbar("Error", "Invalid Student ID. Returning to login.");
        Get.offNamed(AppRoutes.roleSelection);
      });
      return;
    }

    _checkStudentExists();
  }

  Future<void> _checkStudentExists() async {
    try {
      DocumentSnapshot studentDoc = await FirebaseFirestore.instance
          .collection("students")
          .doc(widget.studentId)
          .get();

      if (!studentDoc.exists) {
        Get.snackbar("Error", "Student record not found. Returning to login.");
        Get.offNamed(AppRoutes.roleSelection);
      } else {
        _fetchProfileImage();
      }
    } catch (e) {
      Get.snackbar("Error", "Database error: $e");
      Get.offNamed(AppRoutes.roleSelection);
    }
  }

  Future<void> _fetchProfileImage() async {
    try {
      DocumentSnapshot studentDoc = await FirebaseFirestore.instance
          .collection("students")
          .doc(widget.studentId)
          .get();

      if (studentDoc.exists && studentDoc["faceImageBase64"] != null) {
        setState(() {
          uploadedImageBase64 = studentDoc["faceImageBase64"];
        });
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load profile image: $e");
    }
  }

  Future<void> _startFaceScan() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      Get.snackbar("Error", "No camera available.");
      return;
    }

    final File? capturedImage = await Get.to(() => CameraPage(
      cameras: cameras,
      studentId: widget.studentId,
    ));

    if (capturedImage != null) {
      await _convertAndSaveImage(capturedImage);
    }
  }

  Future<void> _convertAndSaveImage(File imageFile) async {
    try {
      if (widget.studentId.isEmpty) {
        Get.snackbar("Error", "Invalid Student ID. Please try again.");
        return;
      }

      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      await FirebaseFirestore.instance
          .collection("students")
          .doc(widget.studentId)
          .update({"faceImageBase64": base64Image});

      setState(() {
        uploadedImageBase64 = base64Image;
      });

      Get.snackbar("Success", "Face image saved successfully!");
    } catch (e) {
      Get.snackbar("Error", "Failed to save image: $e");
    }
  }

  void _submitAndProceed() {
    if (uploadedImageBase64 != null) {
      Get.offNamed(AppRoutes.studentDashboard,
          arguments: {"studentId": widget.studentId});
    } else {
      Get.snackbar("Error", "Please scan your face before proceeding.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.offNamed(AppRoutes.studentDashboard,
            arguments: {"studentId": widget.studentId});
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF6FAFE),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Spacer(),
                    Text(
                      "Student Profile",
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Spacer(),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  "Please provide your personal details to proceed.",
                  textAlign: TextAlign.center,
                  style:
                  GoogleFonts.poppins(fontSize: 16, color: Colors.black54),
                ),
                SizedBox(height: 40),
                Center(
                  child: Column(
                    children: [
                      Container(
                        height: 300,
                        width: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border:
                          Border.all(color: Colors.grey.shade400, width: 2),
                        ),
                        child: uploadedImageBase64 != null
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.memory(
                            base64Decode(uploadedImageBase64!),
                            fit: BoxFit.cover,
                          ),
                        )
                            : Image.asset(
                          'assets/images/profile_image.png',
                          height: 300,
                          width: 300,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _startFaceScan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    "Face Scan",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (uploadedImageBase64 != null) ...[
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitAndProceed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      "Submit & Proceed",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}