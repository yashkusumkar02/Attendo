import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class StudentAttendanceController extends GetxController {
  var studentDetails = <String, dynamic>{}.obs;
  var isLoading = false.obs;

  String? studentId;
  String? classId;

  @override
  void onInit() {
    super.onInit();
    var args = Get.arguments;
    if (args != null) {
      classId = args["classId"];
      studentId = FirebaseAuth.instance.currentUser?.uid;

      if (studentId != null && classId != null) {
        fetchStudentAttendance();
      }
    }
  }

  Future<void> fetchStudentAttendance() async {
    try {
      if (classId == null || studentId == null) {
        Get.snackbar("Error", "Missing class or student ID");
        return;
      }

      isLoading.value = true;

      // ✅ Fetch student's attendance data
      DocumentSnapshot studentAttendanceDoc = await FirebaseFirestore.instance
          .collection("classrooms")
          .doc(classId)
          .collection("attendance")
          .doc("students") // Assuming students are stored under "students"
          .collection("studentList")
          .doc(studentId)
          .get();

      if (studentAttendanceDoc.exists) {
        var data = studentAttendanceDoc.data() as Map<String, dynamic>;
        studentDetails.value = {
          "name": data["name"] ?? "Unknown Student",
          "status": data["status"] ?? "Absent",
          "attended_classes": data["attended_classes"] ?? 0,
          "total_classes": data["total_classes"] ?? 0,
          "attendance_percentage": calculateAttendancePercentage(
              data["attended_classes"] ?? 0, data["total_classes"] ?? 0),
        };
      } else {
        Get.snackbar("Error", "Attendance record not found");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch attendance: $e");
    } finally {
      isLoading.value = false;
    }
  }

  double calculateAttendancePercentage(int attended, int total) {
    if (total == 0) return 0.0;
    return ((attended / total) * 100).toDouble();
  }

  // ✅ Mark Present
  Future<void> markPresent() async {
    await _updateAttendance(status: "Present", increase: true);
  }

  // ✅ Mark Absent
  Future<void> markAbsent() async {
    await _updateAttendance(status: "Absent", increase: false);
  }

  Future<void> _updateAttendance({required String status, required bool increase}) async {
    if (classId == null || studentId == null) return;

    try {
      DocumentReference studentRef = FirebaseFirestore.instance
          .collection("classrooms")
          .doc(classId)
          .collection("attendance")
          .doc("students")
          .collection("studentList")
          .doc(studentId);

      DocumentSnapshot studentDoc = await studentRef.get();

      if (!studentDoc.exists) {
        Get.snackbar("Error", "Student record not found");
        return;
      }

      int attended = studentDoc["attended_classes"] ?? 0;
      int total = studentDoc["total_classes"] ?? 0;

      if (increase) attended++;

      await studentRef.update({
        "status": status,
        "attended_classes": attended,
        "total_classes": total + 1, // Increase total classes count
      });

      await fetchStudentAttendance(); // ✅ Refresh Data
    } catch (e) {
      Get.snackbar("Error", "Failed to update attendance: $e");
    }
  }
}
