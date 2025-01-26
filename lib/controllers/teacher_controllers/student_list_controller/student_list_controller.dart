import 'package:get/get.dart';
import 'package:flutter/material.dart';

class StudentListController extends GetxController {
  // Search Controller
  TextEditingController searchController = TextEditingController();

  // List of Students (Previously in StudentDataController)
  var students = [
    {
      "id": 1,
      "name": "Atharva Avinash Jain",
      "details": "Pune, Data Science, 4 Year, 8 Semester",
      "status": "Absent",
      "total_classes": 10,
      "attended_classes": 8,
    },
    {
      "id": 2,
      "name": "Jay Agrawal",
      "details": "Pune, Data Science, 4 Year, 8 Semester",
      "status": "Absent",
      "total_classes": 10,
      "attended_classes": 7,
    },
    {
      "id": 3,
      "name": "Shruti Patil",
      "details": "Pune, Data Science, 4 Year, 8 Semester",
      "status": "Absent",
      "total_classes": 10,
      "attended_classes": 6,
    },
  ].obs;

  // Filtered Student List
  var filteredStudents = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    filteredStudents.assignAll(students);

    // Listen to search input
    searchController.addListener(() {
      filterStudents(searchController.text);
    });
  }

  // Function to Filter Students by Name
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

  // Function to Update Student Status & Attendance
  void updateStudentStatus(int studentId, String status) {
    int index = students.indexWhere((student) => student["id"] == studentId);
    if (index != -1) {
      students[index]["status"] = status;

      int attendedClasses = (students[index]["attended_classes"] ?? 0) as int;

      if (status == "Present") {
        students[index]["attended_classes"] = attendedClasses + 1;
      } else {
        if (attendedClasses > 0) {
          students[index]["attended_classes"] = attendedClasses - 1;
        }
      }

      students.refresh(); // ✅ Refresh UI immediately
    }
  }


  // Navigate to Student Attendance Details
  void goToStudentDetails(int studentId) {
    Get.toNamed('/student-attendance-details', arguments: studentId);
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
