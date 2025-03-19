import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:attendo/routes/app_routes.dart';
import 'package:attendo/screens/student/camera_screen/camera_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'dart:io';

class AttendanceVerificationController extends GetxController {
  var classId = "".obs;
  var className = "".obs;
  var faceScanned = false.obs;
  var studentLocation = Rx<LatLng?>(null);
  var teacherLocation = Rx<LatLng?>(null);
  var correctClassCode = "".obs;
  var classFetched = false.obs;
  var endTime = "".obs;
  var isAttendanceMarked = false.obs;

  TextEditingController classCodeController = TextEditingController();

  /// ✅ **Fetch Class Details**
  Future<void> fetchClassDetails() async {
    if (classId.value.isEmpty) {
      Get.snackbar("Error", "Class ID is missing!");
      return;
    }

    QuerySnapshot attendanceSnapshot = await FirebaseFirestore.instance
        .collection("classrooms")
        .doc(classId.value)
        .collection("attendance")
        .orderBy("createdAt", descending: true)
        .limit(1)
        .get();

    if (attendanceSnapshot.docs.isNotEmpty) {
      var data = attendanceSnapshot.docs.first.data() as Map<String, dynamic>;

      teacherLocation.value = LatLng(
        data["teacherLocation"]["latitude"],
        data["teacherLocation"]["longitude"],
      );

      correctClassCode.value = data["classCode"].toString().trim();
      endTime.value = data["endTime"];
      classFetched.value = true;
    } else {
      Get.snackbar("Error", "No active attendance session found!");
    }
  }

  /// ✅ **Get Student's Current Location**
  Future<void> getStudentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition();
    studentLocation.value = LatLng(position.latitude, position.longitude);
  }

  /// ✅ **Check if Student is within 50m**
  bool isWithinAllowedDistance() {
    if (studentLocation.value == null || teacherLocation.value == null) return false;
    double distance = Geolocator.distanceBetween(
      studentLocation.value!.latitude, studentLocation.value!.longitude,
      teacherLocation.value!.latitude, teacherLocation.value!.longitude,
    );
    return distance <= 50;
  }

  /// ✅ **Scan Face and Verify**
  Future<void> scanFace() async {
    if (!isWithinAllowedDistance()) {
      Get.snackbar("Error", "You are too far from the teacher’s location!");
      return;
    }

    // ✅ Open Camera and Capture Image
    String? imagePath = await Get.to(() => CameraScreen());

    if (imagePath == null) {
      Get.snackbar("Error", "Face scan failed. Please try again.");
      return;
    }

    // ✅ Verify Face with Image Processing
    bool isFaceMatched = await verifyFace(imagePath);

    if (isFaceMatched) {
      faceScanned.value = true;
      Get.snackbar("Success", "Face successfully verified.");
    } else {
      Get.snackbar("Error", "Face mismatch! Please try again.");
    }
  }

  /// ✅ **Verify Attendance**
  Future<void> verifyAttendance() async {
    if (!classFetched.value) {
      Get.snackbar("Error", "Class details are not loaded!");
      return;
    }

    if (!isWithinAllowedDistance()) {
      Get.snackbar("Error", "You are too far from the teacher’s location!");
      return;
    }

    if (!faceScanned.value) {
      Get.snackbar("Error", "Please scan your face first!");
      return;
    }

    if (classCodeController.text.trim() != correctClassCode.value.trim()) {
      Get.snackbar("Error", "Invalid Class Code!");
      return;
    }

    if (_isAttendanceTimeOver()) {
      Get.snackbar("Error", "Attendance time is over!");
      return;
    }

    // ✅ If all conditions pass, then mark attendance
    await markAttendance();
  }

  /// ✅ **Check if Attendance Time is Over**
  bool _isAttendanceTimeOver() {
    if (endTime.value.isEmpty) return false;

    DateTime now = DateTime.now();
    DateTime classEndTime = DateFormat("h:mm a").parse(endTime.value);
    classEndTime = DateTime(now.year, now.month, now.day, classEndTime.hour, classEndTime.minute);

    return now.isAfter(classEndTime);
  }

  /// ✅ **Mark Attendance**
  Future<void> markAttendance() async {
    String studentId = FirebaseAuth.instance.currentUser!.uid;

    // ✅ Storing attendance inside the latest session
    await FirebaseFirestore.instance
        .collection("classrooms")
        .doc(classId.value)
        .collection("attendance")
        .doc(correctClassCode.value) // ✅ Uses latest attendance session
        .collection("students")
        .doc(studentId)
        .set({
      "studentId": studentId,
      "attendanceStatus": "Present",
      "timestamp": FieldValue.serverTimestamp(),
    });

    Get.snackbar("Success", "Attendance marked successfully!");
    Get.offNamed(AppRoutes.studentClassDetails, arguments: {"classId": classId.value});
  }


  /// ✅ **Verify Face Using Image Processing**
  Future<bool> verifyFace(String capturedImagePath) async {
    try {
      String studentId = FirebaseAuth.instance.currentUser!.uid;

      // ✅ Fetch Registered Face from Firestore
      DocumentSnapshot studentDoc = await FirebaseFirestore.instance
          .collection("students")
          .doc(studentId)
          .get();

      if (!studentDoc.exists || !studentDoc.data().toString().contains("profileImageBase64")) {
        print("❌ ERROR: No registered face found in Firestore.");
        return false;
      }

      String base64RegisteredFace = studentDoc["profileImageBase64"];

      // ✅ Convert Registered Face to Image
      Uint8List registeredFaceBytes = base64Decode(base64RegisteredFace);
      img.Image? registeredFaceImage = img.decodeImage(registeredFaceBytes);
      if (registeredFaceImage == null) return false;

      // ✅ Convert Captured Face to Image
      File capturedFile = File(capturedImagePath);
      Uint8List capturedFaceBytes = await capturedFile.readAsBytes();
      img.Image? capturedFaceImage = img.decodeImage(capturedFaceBytes);
      if (capturedFaceImage == null) return false;

      // ✅ Resize Captured Image to Match Registered Face
      img.Image resizedCapturedFace = img.copyResize(capturedFaceImage, width: registeredFaceImage.width, height: registeredFaceImage.height);

      // ✅ Convert Both Images to Grayscale
      img.Image grayRegistered = img.grayscale(registeredFaceImage);
      img.Image grayCaptured = img.grayscale(resizedCapturedFace);

      // ✅ Compare Faces
      bool isMatched = compareFaces(grayRegistered, grayCaptured);

      print("✅ Face Match Result: $isMatched");
      return isMatched;
    } catch (e) {
      print("🔥 ERROR: Face Verification Failed - $e");
      return false;
    }
  }

  /// ✅ **Compare Faces with Adjusted Similarity Check**
  bool compareFaces(img.Image img1, img.Image img2) {
    if (img1.width != img2.width || img1.height != img2.height) {
      img2 = img.copyResize(img2, width: img1.width, height: img1.height);
    }

    int totalPixels = img1.width * img1.height;
    int matchedPixels = 0;

    for (int y = 0; y < img1.height; y++) {
      for (int x = 0; x < img1.width; x++) {
        img.Pixel pixel1 = img1.getPixel(x, y);
        img.Pixel pixel2 = img2.getPixel(x, y);

        int r1 = pixel1.r.toInt(), g1 = pixel1.g.toInt(), b1 = pixel1.b.toInt();
        int r2 = pixel2.r.toInt(), g2 = pixel2.g.toInt(), b2 = pixel2.b.toInt();

        // ✅ Compute Euclidean distance in RGB space
        double diff = sqrt(pow(r1 - r2, 2) + pow(g1 - g2, 2) + pow(b1 - b2, 2));

        if (diff < 50) { // ✅ Allow small differences due to lighting variations
          matchedPixels++;
        }
      }
    }

    double similarity = (matchedPixels / totalPixels) * 100;
    print("🔹 Similarity Score: $similarity%");

    return similarity >= 25; // ✅ Adjust threshold if needed
  }
}
