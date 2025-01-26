import 'package:attendo/screens/student/student_details/student_details.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../routes/app_routes.dart';

class StudentRegistrationController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  var email = ''.obs;
  var password = ''.obs;
  var confirmPassword = ''.obs;
  var name = ''.obs;
  var collegeName = ''.obs;
  var branch = ''.obs;
  var semester = ''.obs;
  var year = ''.obs;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  final collegeNameController = TextEditingController();

  // ✅ Validate Email Format
  bool isValidEmail(String email) {
    return GetUtils.isEmail(email);
  }

  // ✅ Validate Password Strength
  bool isValidPassword(String password) {
    return password.length >= 6; // Minimum 6 characters
  }

  // ✅ Register Student
  Future<void> submitRegistration() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();
    String name = nameController.text.trim();
    String college = collegeNameController.text.trim();
    String selectedBranch = branch.value;
    String selectedSemester = semester.value;
    String selectedYear = year.value;

    if (email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        name.isEmpty ||
        college.isEmpty ||
        selectedBranch.isEmpty ||
        selectedSemester.isEmpty ||
        selectedYear.isEmpty) {
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
      // Check if student is already registered
      var existingUser = await _db.collection("students").where("email", isEqualTo: email).get();
      if (existingUser.docs.isNotEmpty) {
        Get.snackbar("Error", "Email is already registered!",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white);
        return;
      }

      // ✅ Register Student in Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      // ✅ Store Student Data in Firestore
      await _db.collection("students").doc(uid).set({
        "uid": uid,
        "email": email,
        "name": name,
        "collegeName": college,
        "branch": selectedBranch,
        "semester": selectedSemester,
        "year": selectedYear,
        "role": "student", // ✅ Role-Based Storage
        "createdAt": FieldValue.serverTimestamp(),
      });

      Get.snackbar("Success", "Student registered successfully!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);

      // ✅ Navigate to StudentProfilePage **with studentId**
      Get.to(() => StudentProfilePage(studentId: uid));

    } catch (e) {
      Get.snackbar("Error", "Signup failed: $e",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    }
  }
}
