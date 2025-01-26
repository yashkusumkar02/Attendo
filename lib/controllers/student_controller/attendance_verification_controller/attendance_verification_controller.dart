import 'package:attendo/routes/app_routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class AttendanceVerificationController extends GetxController {
  var classId = "".obs;  // ✅ Fixed: Added missing classId
  var className = "".obs;  // ✅ Fixed: Added missing className
  var faceScanned = false.obs;
  var locationVerified = false.obs;
  var studentLocation = Rx<LatLng?>(null);
  var teacherLocation = Rx<LatLng?>(null);
  var correctClassCode = "".obs;
  var classFetched = false.obs;

  var isAttendanceMarked = false.obs; // ✅ Track attendance status

  TextEditingController classCodeController = TextEditingController();

  /// ✅ **Fetch Teacher's Location & Class Code**
  Future<void> fetchClassDetails() async {
    try {
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

        correctClassCode.value = data["classCode"];
        classFetched.value = true;

        Get.snackbar("Success", "Class details fetched successfully!");
      } else {
        Get.snackbar("Error", "No active attendance session found!");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch class details.");
    }
  }

  /// ✅ **Get Student's Current Location**
  /// ✅ **Get Student's Current Location & Check Distance Automatically**
  Future<void> getStudentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar("Error", "Enable Location Services");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar("Permission Denied", "Location access is required.");
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    studentLocation.value = LatLng(position.latitude, position.longitude);

    print("✅ Student Location: ${position.latitude}, ${position.longitude}");

    // ✅ Automatically check distance and show alert if needed
    if (!isWithinAllowedDistance()) {
      _showLocationErrorDialog();
    }
  }
  /// ✅ **Auto-check Student Distance Every 5 Seconds**
  void startDistanceCheck() {
    ever(studentLocation, (_) {
      if (!isWithinAllowedDistance()) {
        _showLocationErrorDialog();
      }
    });

    // Periodically check the distance every 5 seconds
    Future.delayed(Duration(seconds: 5), startDistanceCheck);
  }


  /// ✅ **Check if Student is within 50m Circular Radius**
  bool isWithinAllowedDistance() {
    if (studentLocation.value == null || teacherLocation.value == null) return false;

    double distance = Geolocator.distanceBetween(
      studentLocation.value!.latitude, studentLocation.value!.longitude,
      teacherLocation.value!.latitude, teacherLocation.value!.longitude,
    );

    print("📏 Student is $distance meters away from the teacher.");

    return distance <= 50; // ✅ Returns true if within 50m, false otherwise
  }


  /// ✅ **Scan & Verify Face**
  Future<void> scanFace() async {
    // Check if student is within 50 meters before scanning
    if (!isWithinAllowedDistance()) {
      _showLocationErrorDialog(); // ✅ Show alert if too far
      return;
    }

    await Future.delayed(Duration(seconds: 2)); // Simulating face scan
    faceScanned.value = true;
    Get.snackbar("Success", "Face successfully verified.");
  }


  /// ✅ **Verify Attendance**
  /// ✅ **Verify Attendance**
  /// ✅ **Verify Attendance**
  /// ✅ **Verify Attendance**
  /// ✅ **Verify & Mark Attendance**
  Future<void> verifyAttendance() async {
    if (!classFetched.value || !isWithinAllowedDistance()) {
      Get.snackbar("Error", "You are too far from the teacher’s location!");
      return;
    }

    if (!faceScanned.value) {
      Get.snackbar("Error", "Please scan your face first!");
      return;
    }

    if (classCodeController.text.trim() != correctClassCode.value) {
      Get.snackbar("Error", "Invalid Class Code!");
      return;
    }

    await markAttendance();

    isAttendanceMarked.value = true; // ✅ Update UI to disable button

    // ✅ Move class from Live to Previous
    previousClasses.add(liveClasses.first);
    liveClasses.removeAt(0);
  }


  /// ✅ **Show Alert if Student is Too Far**
  void _showLocationErrorDialog() {
    Get.defaultDialog(
      title: "Location Error",
      content: const Column(
        children: [
          Icon(Icons.location_off, color: Colors.red, size: 50),
          SizedBox(height: 10),
          Text(
            "You are too far from the teacher's location!\nAttendance access is restricted.",
            textAlign: TextAlign.center,
          ),
        ],
      ),
      barrierDismissible: false, // Prevent user from closing manually
      confirm: ElevatedButton(
        onPressed: () => Get.back(),
        child: Text("OK"),
      ),
    );
  }


  /// ✅ **Mark Attendance**
  Future<void> markAttendance() async {
    String studentId = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection("classrooms").doc(classId.value).collection("attendance").doc(correctClassCode.value).collection("students").doc(studentId).set({
      "studentId": studentId,
      "attendanceStatus": "Present",
      "timestamp": FieldValue.serverTimestamp(),
    });

    Get.snackbar("Success", "Attendance marked successfully!");
    Get.offNamed(AppRoutes.studentDashboard);
  }
}
