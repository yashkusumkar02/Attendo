import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

class CreateClassController extends GetxController {
  TextEditingController classCodeController = TextEditingController();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String classId;

  RxString selectedClassTiming = "Morning".obs;
  RxString selectedStartTime = "8:30 AM".obs;
  RxString selectedEndTime = "9:30 AM".obs;

  RxString teacherLocationText = "Location not fetched".obs; // ✅ Show live location text
  Position? teacherLocation;

  CreateClassController({required this.classId});

  @override
  void onInit() {
    super.onInit();
    generateClassCode();
  }

  // ✅ Generate a Unique Class Code
  void generateClassCode() {
    String generatedCode = (100000 + Random().nextInt(900000)).toString();
    classCodeController.text = generatedCode;
  }

  // ✅ Fetch Teacher Location
  Future<void> getTeacherLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar("Error", "Location services are disabled!", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar("Error", "Location permission denied!", snackPosition: SnackPosition.BOTTOM);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar("Error", "Location permission permanently denied!", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    teacherLocation = await Geolocator.getCurrentPosition(locationSettings: LocationSettings(accuracy: LocationAccuracy.high));
    teacherLocationText.value = "Lat: ${teacherLocation!.latitude}, Lng: ${teacherLocation!.longitude}"; // ✅ Update location text

    Get.snackbar("Success", "Location fetched successfully!", snackPosition: SnackPosition.BOTTOM);
  }

  // ✅ Create Attendance and Save Under the Correct Classroom
  void createAttendance() async {
    if (teacherLocation == null) {
      Get.snackbar("Error", "Please fetch your location before creating attendance!", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // ✅ Generate Unique Attendance ID
    String attendanceId = "${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(999999)}-$classId";

    // ✅ Save to Firestore under the current `classId`
    DocumentReference attendanceRef = _db.collection("classrooms").doc(classId).collection("attendance").doc(attendanceId);

    await attendanceRef.set({
      "attendanceId": attendanceId,
      "classId": classId,
      "classTiming": selectedClassTiming.value, // ✅ Morning/Afternoon/Evening
      "startTime": selectedStartTime.value,
      "endTime": selectedEndTime.value,
      "classCode": classCodeController.text, // ✅ Auto-generated Code
      "status": "live",
      "teacherLocation": {
        "latitude": teacherLocation!.latitude,
        "longitude": teacherLocation!.longitude,
      },
      "createdAt": FieldValue.serverTimestamp(),
    });

    // ✅ Navigate back to Classroom Details
    Get.snackbar("Success", "Attendance Created Successfully!",
        snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);

    Get.offNamed('/classroom-details', arguments: {"classId": classId});
  }
}
