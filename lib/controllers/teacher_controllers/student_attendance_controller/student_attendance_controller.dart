import 'package:attendo/controllers/teacher_controllers/student_list_controller/student_list_controller.dart';
import 'package:get/get.dart';

class StudentAttendanceController extends GetxController {
  final StudentListController studentListController = Get.find();
  late int studentId;
  var studentDetails = {}.obs;

  @override
  void onInit() {
    super.onInit();
    studentId = Get.arguments as int;

    studentDetails.value = studentListController.students.firstWhere(
          (student) => student["id"] == studentId,
      orElse: () {
        print("⚠️ Error: Student with ID $studentId not found!");
        return {"id": studentId, "name": "Unknown Student", "details": "No details available", "status": "Absent"};
      },
    );
  }

  // Function to Mark Student as Present
  void markPresent() {
    studentListController.updateStudentStatus(studentId, "Present");

    // ✅ Refresh Student List Data
    studentListController.students.refresh();

    // ✅ Update local student details
    studentDetails.value = studentListController.students.firstWhere((student) => student["id"] == studentId);
    update(); // ✅ Ensures UI updates
  }

  // Function to Mark Student as Absent
  void markAbsent() {
    studentListController.updateStudentStatus(studentId, "Absent");

    // ✅ Refresh Student List Data
    studentListController.students.refresh();

    // ✅ Update local student details
    studentDetails.value = studentListController.students.firstWhere((student) => student["id"] == studentId);
    update(); // ✅ Ensures UI updates
  }
}
