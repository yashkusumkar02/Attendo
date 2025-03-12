import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class StudentListController extends GetxController {
  // Search Controller
  TextEditingController searchController = TextEditingController();

  // Live List of Students from Firestore
  var students = <Map<String, dynamic>>[].obs;
  var filteredStudents = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchStudentsFromFirestore();  // ✅ Fetch students from Firestore
    filteredStudents.assignAll(students);

    // Listen to search input
    searchController.addListener(() {
      filterStudents(searchController.text);
    });
  }

  /// ✅ Fetch students from Firestore
  Future<void> fetchStudentsFromFirestore() async {
    try {
      QuerySnapshot studentSnapshot =
      await FirebaseFirestore.instance.collection("students").get();

      students.assignAll(studentSnapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return {
          "id": doc.id.toString(),  // ✅ Convert Firestore document ID to String
          "name": data["name"] ?? "Unknown Student",
          "details": "${data["college"] ?? "Unknown College"}, ${data["branch"] ?? "Unknown Branch"}, ${data["year"] ?? "Unknown Year"}, ${data["semester"] ?? "Unknown Semester"}",
          "status": data["status"] ?? "Absent",
          "total_classes": (data["total_classes"] ?? 0).toString(),  // ✅ Convert to String
          "attended_classes": (data["attended_classes"] ?? 0).toString(),  // ✅ Convert to String
        };
      }).toList());

      filteredStudents.assignAll(students);  // ✅ Ensure UI updates with data
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch student data: $e");
    }
  }

  /// ✅ Function to Filter Students by Name
  void filterStudents(String query) {
    if (query.isEmpty) {
      filteredStudents.assignAll(students);
    } else {
      filteredStudents.assignAll(
        students.where((student) =>
            (student["name"] as String).toLowerCase().contains(query.toLowerCase()))
            .toList(),
      );
    }
  }

  /// ✅ Function to Update Student Status
  void updateStudentStatus(String studentId, String status) {
    int index = students.indexWhere((student) => student["id"] == studentId);
    if (index != -1) {
      students[index]["status"] = status;

      int attendedClasses = int.tryParse(students[index]["attended_classes"]) ?? 0;

      if (status == "Present") {
        students[index]["attended_classes"] = (attendedClasses + 1).toString();
      } else {
        if (attendedClasses > 0) {
          students[index]["attended_classes"] = (attendedClasses - 1).toString();
        }
      }

      students.refresh();  // ✅ Refresh UI immediately
    }
  }

  /// ✅ Navigate to Student Attendance Details
  void goToStudentDetails(String studentId) {
    Get.toNamed('/student-attendance-details', arguments: {"studentId": studentId});
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
