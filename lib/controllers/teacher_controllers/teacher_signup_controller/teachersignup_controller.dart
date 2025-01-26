import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TeacherSignUpController extends GetxController {
  var email = ''.obs;
  var password = ''.obs;
  var confirmPassword = ''.obs;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void signUp() {
    if (passwordController.text == confirmPasswordController.text) {
      // Add sign-up logic here
      Get.snackbar(
        'Success',
        'Account created successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.greenAccent,
        colorText: Colors.black,
      );
    } else {
      Get.snackbar(
        'Error',
        'Passwords do not match',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }
}
