import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../routes/app_routes.dart';

class TeacherLoginController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ✅ Text Controllers for Input Fields
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // ✅ Password Visibility Toggle
  var isPasswordHidden = true.obs;

  // ✅ Function to Toggle Password Visibility
  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  // ✅ Function to Validate Email Format
  bool isValidEmail(String email) {
    return GetUtils.isEmail(email);
  }

  // ✅ Function to Login Teacher
  void login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    print("📌 DEBUG: Entered Email: $email");
    print("📌 DEBUG: Entered Password: $password");

    if (email.isEmpty || password.isEmpty) {
      print("❌ ERROR: Fields are empty!");
      Get.snackbar("Error", "Please fill in all fields!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
      return;
    }

    if (!isValidEmail(email)) {
      print("❌ ERROR: Invalid Email Format!");
      Get.snackbar("Error", "Invalid Email Format!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
      return;
    }

    try {
      // Firebase Authentication Login
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;
      print("✅ Firebase Authentication Successful. UID: $uid");

      // Fetch user role from Firestore
      DocumentSnapshot userDoc = await _db.collection("users").doc(uid).get();

      if (userDoc.exists) {
        String role = userDoc.get("role") ?? "";
        print("✅ Role fetched from Firestore: $role");

        if (role == "teacher") {
          print("🚀 Navigating to Teacher Dashboard...");
          Get.snackbar("Success", "Login successful!",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white);
          Get.offAllNamed(AppRoutes.teacherDashboard); // ✅ Redirect to Teacher Dashboard
        } else {
          print("❌ ERROR: User is not a Teacher.");
          Get.snackbar("Access Denied", "You are not registered as a Teacher.",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.redAccent,
              colorText: Colors.white);
        }
      } else {
        print("❌ ERROR: Firestore User Document Not Found.");
        Get.snackbar("Error", "User Not Found in Database!",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white);
      }
    } on FirebaseAuthException catch (e) {
      catchFirebaseAuthError(e); // Handle Authentication Errors
    } catch (e) {
      print("❌ Unknown Error: $e");
      Get.snackbar("Error", "An unexpected error occurred. Please try again.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    }
  }

  // ✅ Function for Password Reset
  void resetPassword() async {
    String email = emailController.text.trim();

    if (email.isEmpty) {
      Get.snackbar("Error", "Please enter a valid email address.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      Get.snackbar('Success', 'Password reset link sent to $email',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to send password reset email: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    }
  }

  // ✅ Function to Handle Firebase Authentication Errors
  void catchFirebaseAuthError(FirebaseAuthException e) {
    if (e.code == 'user-not-found') {
      print("❌ ERROR: No User Found with this Email.");
      Get.snackbar("Error", "No user found with this email.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    } else if (e.code == 'wrong-password') {
      print("❌ ERROR: Incorrect Password.");
      Get.snackbar("Error", "Incorrect password. Please try again.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    } else if (e.code == 'too-many-requests') {
      print("❌ ERROR: Too Many Requests. Account Temporarily Blocked.");
      Get.snackbar("Error", "Too many failed attempts. Try again later.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white);
    } else {
      print("❌ ERROR: ${e.message}");
      Get.snackbar("Authentication Error", e.message ?? "Login failed.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    }
  }
}
