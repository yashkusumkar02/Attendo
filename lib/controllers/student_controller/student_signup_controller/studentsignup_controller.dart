import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StudentRegistrationController extends GetxController {
  // Reactive variables for fields
  var name = ''.obs;
  var collegeName = ''.obs;
  var branch = ''.obs;
  var semester = ''.obs;
  var year = ''.obs;

  // Text editing controllers
  final nameController = TextEditingController();
  final collegeNameController = TextEditingController();
  final branchController = TextEditingController();
  final semesterController = TextEditingController();
  final yearController = TextEditingController();

  // Submit the registration form
  void submitRegistration() {
    if (nameController.text.isEmpty ||
        collegeNameController.text.isEmpty ||
        branchController.text.isEmpty ||
        semesterController.text.isEmpty ||
        yearController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill in all fields');
      return;
    }

    // Proceed with the registration logic (e.g., API call)
    Get.snackbar('Success', 'Student registration completed successfully!');
    // Navigate to the next screen or dashboard
    // Get.offNamed('/student-dashboard');
  }
}
