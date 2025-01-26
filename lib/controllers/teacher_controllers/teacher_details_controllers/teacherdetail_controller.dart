import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TeacherDetailController extends GetxController {
  var name = ''.obs;
  var college = ''.obs;

  // Text editing controllers
  final nameController = TextEditingController();
  final collegeController = TextEditingController();

  void submitRegistration() {
    if (nameController.text.isEmpty || collegeController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill in all fields');
      return;
    }

    // Registration logic here (e.g., API call)
    Get.snackbar('Success', 'Registration completed successfully!');
    // Navigate to the next screen or dashboard
    // Get.offNamed('/dashboard');
  }
}
