import 'package:attendo/controllers/teacher_controllers/teacher_home_controller/teacher_home_controller.dart';
import 'package:attendo/models/classroom_model.dart';
import 'package:attendo/routes/app_routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';

class CreateClassroomController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  var name = ''.obs;
  var selectedCollege = ''.obs;
  var branch = ''.obs;
  var year = ''.obs;
  var semester = ''.obs;
  var classId = ''.obs;

  var collegeList = <String>[].obs; // ✅ List to store colleges

  @override
  void onInit() {
    super.onInit();
    _fetchColleges(); // ✅ Fetch all colleges from database
    _generateClassId(); // ✅ Generate unique class ID
  }

  // ✅ Fetch List of Colleges from Firestore
  Future<void> _fetchColleges() async {
    try {
      var snapshot = await _db.collection("colleges").get();
      collegeList.value =
          snapshot.docs.map((doc) => doc["name"] as String).toList();
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch colleges: $e",
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ✅ Generate Unique Class ID
  void _generateClassId() {
    String generatedId = Random().nextInt(1000000).toString().padLeft(6, '0');
    classId.value = generatedId;
  }

  Future<void> createClassroom() async {
    if (name.value.isEmpty || selectedCollege.value.isEmpty ||
        branch.value.isEmpty || year.value.isEmpty || semester.value.isEmpty) {
      Get.snackbar("Error", "All fields are required!",
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    String teacherId = _auth.currentUser!.uid;
    String classIdGenerated = Random().nextInt(1000000).toString().padLeft(
        6, '0');

    try {
      await _db.collection("classrooms").doc(classIdGenerated).set({
        "teacherId": teacherId,
        "name": name.value,
        "college": selectedCollege.value,
        "branch": branch.value,
        "semester": semester.value, // ✅ Store as String
        "year": year.value, // ✅ Store as String
        "classId": classIdGenerated,
        "createdAt": FieldValue.serverTimestamp(),
      });

      Get.snackbar("Success", "Classroom Created Successfully!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);

      Get.offAllNamed(
          AppRoutes.teacherDashboard); // ✅ Redirect to Teacher Dashboard

    } catch (e) {
      Get.snackbar("Error", "Failed to create classroom: $e",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    }
  }
}

