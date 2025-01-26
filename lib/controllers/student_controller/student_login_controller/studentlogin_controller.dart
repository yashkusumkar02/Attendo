import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class StudentLoginController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var isLoading = false.obs;

  void login() async {
    if (emailController.text.trim().isEmpty || passwordController.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter both email and password.");
      return;
    }

    try {
      isLoading.value = true; // ✅ Show loading state

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      String uid = userCredential.user!.uid;

      // ✅ Fetch student details
      DocumentSnapshot studentDoc = await _db.collection("students").doc(uid).get();
      if (studentDoc.exists) {
        Get.offNamed('/student-dashboard', arguments: {"studentId": uid}); // ✅ Redirect to dashboard
      } else {
        Get.snackbar("Error", "Student details not found.");
      }
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } catch (e) {
      Get.snackbar("Login Failed", "Unexpected error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void resetPassword() async {
    if (emailController.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter your email to reset password.");
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: emailController.text.trim());
      Get.snackbar("Success", "Password reset link sent!");
    } catch (e) {
      Get.snackbar("Error", "Failed to send reset email: $e");
    }
  }

  // ✅ Error Handling for Firebase Authentication
  void _handleAuthError(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case "user-not-found":
        message = "No account found with this email.";
        break;
      case "wrong-password":
        message = "Incorrect password. Please try again.";
        break;
      case "invalid-email":
        message = "Invalid email format.";
        break;
      default:
        message = "Login failed: ${e.message}";
    }
    Get.snackbar("Error", message);
  }
}
