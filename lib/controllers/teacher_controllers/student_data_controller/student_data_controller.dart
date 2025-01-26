import 'package:get/get.dart';

class StudentDataController extends GetxController {
  // List of Students (Dummy Data)
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

  // Update Student Status by ID
  void updateStudentStatus(int id, String status) {
    var index = students.indexWhere((student) => student["id"] == id);
    if (index != -1) {
      students[index]["status"] = status;

      // Explicitly cast "attended_classes" as int before modifying it
      int attendedClasses = (students[index]["attended_classes"] ?? 0) as int;

      if (status == "Present") {
        students[index]["attended_classes"] = attendedClasses + 1;
      } else {
        if (attendedClasses > 0) {
          students[index]["attended_classes"] = attendedClasses - 1;
        }
      }

      students.refresh(); // 🔄 Ensures UI updates in real-time
    }
  }

}
