import 'package:attendo/models/classroom_model.dart';
import 'package:attendo/routes/app_routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TeacherDashboardController extends GetxController {
  var classrooms = <ClassroomModel>[].obs; // Observable list of classrooms
  var isLoading = false.obs; // Loading state

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    listenToClassrooms(); // ✅ Set up real-time listener
  }

  void listenToClassrooms() {
    isLoading(true);

    try {
      String teacherId = _auth.currentUser!.uid;

      _db.collection("classrooms")
          .where("teacherId", isEqualTo: teacherId)
          .snapshots()
          .listen((snapshot) {
        classrooms.value = snapshot.docs.map((doc) {
          var data = doc.data();
          return ClassroomModel(
            id: doc.id,
            name: data["name"] ?? "Unknown",
            college: data["college"] ?? "Unknown",
            branch: data["branch"] ?? "Unknown",
            semester: data["semester"].toString(), // ✅ Ensure it's a String
            year: data["year"].toString(), // ✅ Ensure it's a String
          );
        }).toList();
      });

    } catch (e) {
      Get.snackbar("Error", "Failed to fetch classrooms: $e",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    } finally {
      isLoading(false);
    }
  }


  void openClassroom(ClassroomModel classroom) {
    print("📌 DEBUG: Navigating to Classroom Details with data: ${classroom.toJson()}");

    Get.toNamed(
      AppRoutes.classsroomDetails, // ✅ Correct path
      arguments: {
        "classId": classroom.id,
        "name": classroom.name,
        "college": classroom.college,
        "branch": classroom.branch,
        "semester": classroom.semester.toString(), // ✅ Ensure String
        "year": classroom.year.toString(), // ✅ Ensure String
      },
    );
  }


}
