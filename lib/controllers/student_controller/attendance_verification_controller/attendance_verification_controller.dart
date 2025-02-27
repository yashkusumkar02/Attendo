import 'package:attendo/routes/app_routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class AttendanceVerificationController extends GetxController {
  var classId = "".obs;
  var className = "".obs;
  var faceScanned = false.obs;
  var locationVerified = false.obs;
  var studentLocation = Rx<LatLng?>(null);
  var teacherLocation = Rx<LatLng?>(null);
  var correctClassCode = "".obs;
  var classFetched = false.obs;
  var endTime = "".obs;
  var isAttendanceMarked = false.obs;

  TextEditingController classCodeController = TextEditingController();

  /// ✅ **Fetch Class Details**
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
        endTime.value = data["endTime"]; // ✅ Store End Time
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

    if (!isWithinAllowedDistance()) {
      _showLocationErrorDialog();
    }
  }

  /// ✅ **Check if Student is within 50m**
  bool isWithinAllowedDistance() {
    if (studentLocation.value == null || teacherLocation.value == null) return false;

    double distance = Geolocator.distanceBetween(
      studentLocation.value!.latitude, studentLocation.value!.longitude,
      teacherLocation.value!.latitude, teacherLocation.value!.longitude,
    );

    print("📏 Student is $distance meters away from the teacher.");
    return distance <= 50;
  }

  /// ✅ **Scan & Verify Face**
  Future<void> scanFace() async {
    if (!isWithinAllowedDistance()) {
      _showLocationErrorDialog();
      return;
    }

    await Future.delayed(Duration(seconds: 2)); // Simulating face scan
    faceScanned.value = true;
    Get.snackbar("Success", "Face successfully verified.");
  }

  /// ✅ **Verify Attendance**
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

    if (_isAttendanceTimeOver()) {
      Get.snackbar("Error", "Attendance time is over!");
      return;
    }

    await markAttendance();
    isAttendanceMarked.value = true;
  }

  /// ✅ **Check if Attendance Time is Over**
  bool _isAttendanceTimeOver() {
    if (endTime.value.isEmpty) return false;

    DateTime now = DateTime.now();
    DateTime classEndTime = DateTime.parse(endTime.value);

    return now.isAfter(classEndTime);
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

  /// ✅ **Mark Absent Students**
  Future<void> markAbsentees() async {
    QuerySnapshot studentSnapshot = await FirebaseFirestore.instance
        .collection("classrooms")
        .doc(classId.value)
        .collection("students")
        .get();

    for (var doc in studentSnapshot.docs) {
      String studentId = doc.id;
      DocumentSnapshot attendanceDoc = await FirebaseFirestore.instance
          .collection("classrooms")
          .doc(classId.value)
          .collection("attendance")
          .doc(correctClassCode.value)
          .collection("students")
          .doc(studentId)
          .get();

      if (!attendanceDoc.exists) {
        await FirebaseFirestore.instance.collection("classrooms").doc(classId.value).collection("attendance").doc(correctClassCode.value).collection("students").doc(studentId).set({
          "studentId": studentId,
          "attendanceStatus": "Absent",
          "timestamp": FieldValue.serverTimestamp(),
        });
      }
    }
  }

  /// ✅ **Show Location Error**
  void _showLocationErrorDialog() {
    Get.defaultDialog(
      title: "Location Error",
      content: Column(
        children: [
          Icon(Icons.location_off, color: Colors.red, size: 50),
          SizedBox(height: 10),
          Text(
            "You are too far from the teacher's location!\nAttendance access is restricted.",
            textAlign: TextAlign.center,
          ),
        ],
      ),
      barrierDismissible: false,
      confirm: ElevatedButton(
        onPressed: () => Get.back(),
        child: Text("OK"),
      ),
    );
  }
}
