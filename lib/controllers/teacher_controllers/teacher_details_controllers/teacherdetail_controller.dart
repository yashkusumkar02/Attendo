import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../routes/app_routes.dart';

class TeacherDetailController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var name = ''.obs;
  var college = ''.obs;

  final nameController = TextEditingController();
  final collegeController = TextEditingController();

  void submitRegistration() async {
    String teacherId = _auth.currentUser?.uid ?? "";

    if (teacherId.isEmpty) {
      Get.snackbar("Error", "User not found! Please log in again.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
      return;
    }

    if (nameController.text.trim().isEmpty || collegeController.text.trim().isEmpty) {
      Get.snackbar("Error", "All fields are required!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
      return;
    }

    try {
      // Update Firestore with Name & College
      await _db.collection("users").doc(teacherId).update({
        "name": nameController.text.trim(),
        "college": collegeController.text.trim(),
      });

      Get.snackbar("Success", "Teacher details updated!");
      Get.offNamed(AppRoutes.teacherDashboard); // Navigate to Teacher Dashboard

    } catch (e) {
      print("Error Updating Teacher Details: $e");
      Get.snackbar("Error", "Failed to update details.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    }
  }
}
