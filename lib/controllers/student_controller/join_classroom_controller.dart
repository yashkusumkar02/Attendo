import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JoinClassroomController extends GetxController {
  TextEditingController searchController = TextEditingController();
  TextEditingController classCodeController = TextEditingController();

  var classrooms = <Map<String, dynamic>>[].obs;
  var filteredClassrooms = <Map<String, dynamic>>[].obs;

  String? studentSemester;
  String? studentYear;
  String? studentBranch;
  String? studentId;
  Map<String, dynamic>? studentData;

  @override
  void onInit() {
    super.onInit();
    _fetchStudentDetails();
  }

  // ✅ Fetch Student Details
  Future<void> _fetchStudentDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar("Error", "User not logged in!", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    studentId = user.uid;

    try {
      DocumentSnapshot studentDoc =
      await FirebaseFirestore.instance.collection("students").doc(user.uid).get();

      if (studentDoc.exists) {
        studentData = studentDoc.data() as Map<String, dynamic>;
        studentSemester = studentData?["semester"];
        studentYear = studentData?["year"];
        studentBranch = studentData?["branch"];

        _fetchClassrooms();
      } else {
        Get.snackbar("Error", "Student details not found!", snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch student details: $e", snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ✅ Fetch Classrooms
  Future<void> _fetchClassrooms() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("classrooms")
          .where("semester", isEqualTo: studentSemester ?? "")
          .where("year", isEqualTo: studentYear ?? "")
          .where("branch", isEqualTo: studentBranch ?? "")
          .get();

      if (querySnapshot.docs.isEmpty) {
        Get.snackbar("Info", "No classrooms found for your semester, year, and branch.",
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      classrooms.assignAll(
          await Future.wait(querySnapshot.docs.map((doc) async {
            var data = doc.data() as Map<String, dynamic>;

            String teacherName = "Unknown Teacher";
            if (data["teacherId"] != null) {
              teacherName = await _fetchTeacherName(data["teacherId"]);
            }

            return {
              "classId": data["classId"], // ✅ Fixed key name for classCode
              "name": data["name"] ?? "Unknown Class",
              "teacher": teacherName,
              "semester": data["semester"] ?? "",
              "year": data["year"] ?? "",
              "branch": data["branch"] ?? "",
            };
          }).toList()));

      filteredClassrooms.assignAll(classrooms);
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch classrooms: $e", snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ✅ Fetch Teacher Name
  Future<String> _fetchTeacherName(String teacherId) async {
    try {
      DocumentSnapshot teacherDoc =
      await FirebaseFirestore.instance.collection("users").doc(teacherId).get();
      if (teacherDoc.exists) {
        return teacherDoc["name"] ?? "Unknown Teacher";
      }
    } catch (e) {
      print("Error fetching teacher name: $e");
    }
    return "Unknown Teacher";
  }

  // ✅ Filter Classrooms Based on Search Query
  void filterClassrooms(String query) {
    if (query.isEmpty) {
      filteredClassrooms.assignAll(classrooms);
    } else {
      filteredClassrooms.assignAll(
        classrooms
            .where((classroom) =>
        (classroom['name'] as String?)?.toLowerCase().contains(query.toLowerCase()) ??
            false)
            .toList(),
      );
    }
  }

  // ✅ Validate Class Code (Checks if it's a 6-digit number)
  Future<bool> validateClassCode(String enteredCode) async {
    if (!_isValidClassCode(enteredCode)) {
      Get.snackbar("Error", "Class code must be exactly 6 digits!",
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    try {
      DocumentSnapshot classSnapshot = await FirebaseFirestore.instance
          .collection("classrooms")
          .doc(enteredCode)
          .get();

      if (!classSnapshot.exists) {
        Get.snackbar("Error", "Classroom does not exist!", snackPosition: SnackPosition.BOTTOM);
        return false;
      }

      return true;
    } catch (e) {
      Get.snackbar("Error", "Failed to validate class code: $e", snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }

  // ✅ Join Classroom and Save Student Data
  Future<void> joinClassroom(String classCode) async {
    if (studentId == null) {
      Get.snackbar("Error", "User ID not found!", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (studentData == null) {
      Get.snackbar("Error", "Student data not loaded!", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (!(await validateClassCode(classCode))) {
      return;
    }

    try {
      DocumentReference classRef =
      FirebaseFirestore.instance.collection("classrooms").doc(classCode);
      DocumentSnapshot classSnapshot = await classRef.get();

      if (!classSnapshot.exists) {
        Get.snackbar("Error", "Classroom does not exist!", snackPosition: SnackPosition.BOTTOM);
        return;
      }

      // ✅ Convert Firestore Object? to Map<String, dynamic>
      Map<String, dynamic>? classData = classSnapshot.data() as Map<String, dynamic>?;

      List<dynamic> students = [];
      if (classData != null && classData.containsKey("students")) {
        students = classData["students"];
      }

      if (students.contains(studentId)) {
        Get.snackbar("Info", "You are already in this class!", snackPosition: SnackPosition.BOTTOM);
        return;
      }

      // ✅ Add student ID to `students` list
      await classRef.update({
        "students": FieldValue.arrayUnion([studentId])
      });

      // ✅ Create `students` collection under `attendance`
      DocumentReference studentRef =
      classRef.collection("attendance").doc("students").collection("studentList").doc(studentId);

      await studentRef.set({
        "name": studentData?["name"],
        "email": studentData?["email"],
        "joinedAt": FieldValue.serverTimestamp(),
      });

      // ✅ Store joined classroom in student's dashboard
      DocumentReference studentDashboardRef = FirebaseFirestore.instance
          .collection("students")
          .doc(studentId)
          .collection("joinedClasses")
          .doc(classCode);

      await studentDashboardRef.set({
        "classId": classCode,
        "className": classData?["name"],
        "teacher": classData?["teacherId"],
        "joinedAt": FieldValue.serverTimestamp(),
      });

      Get.snackbar("Success", "You have joined the classroom!", snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar("Error", "Failed to join classroom: $e", snackPosition: SnackPosition.BOTTOM);
    }
  }


  // ✅ Helper: Checks if the class code is valid (Only 6 digits allowed)
  bool _isValidClassCode(String code) {
    return RegExp(r'^\d{6}$').hasMatch(code);
  }
}
