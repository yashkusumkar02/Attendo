import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../routes/app_routes.dart';

class TeacherSignUpController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  var email = ''.obs;
  var password = ''.obs;
  var confirmPassword = ''.obs;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Function to Validate Email Format
  bool isValidEmail(String email) {
    return GetUtils.isEmail(email);
  }

  // Function to Validate Password Strength
  bool isValidPassword(String password) {
    return password.length >= 6; // Minimum 6 characters
  }

  // Function to Sign Up Teacher
  void signUp() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      Get.snackbar("Error", "All fields are required!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
      return;
    }

    if (!isValidEmail(email)) {
      Get.snackbar("Error", "Invalid Email Format!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
      return;
    }

    if (!isValidPassword(password)) {
      Get.snackbar("Error", "Password must be at least 6 characters!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
      return;
    }

    if (password != confirmPassword) {
      Get.snackbar("Error", "Passwords do not match!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
      return;
    }

    try {
      // Check if the email is already registered
      var existingUser = await _db.collection("users").where("email", isEqualTo: email).get();
      if (existingUser.docs.isNotEmpty) {
        Get.snackbar("Error", "Email is already registered!",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white);
        return;
      }

      // Register in Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      // Store Teacher Data in Firestore (Temporary Name/College)
      await _db.collection("users").doc(uid).set({
        "uid": uid,
        "email": email,
        "role": "teacher",
        "name": "",  // Placeholder for next step
        "college": "", // Placeholder for next step
        "createdAt": DateTime.now(),
      });

      Get.toNamed(AppRoutes.teacherDetails); // Navigate to Teacher Details Page

    } catch (e) {
      Get.snackbar("Error", "Signup failed: $e",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    }
  }
}
