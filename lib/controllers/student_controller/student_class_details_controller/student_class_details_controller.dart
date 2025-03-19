import 'package:attendo/routes/app_routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class StudentClassDetailsController extends GetxController {
  var classId = "".obs;
  var className = "".obs;
  var teacherName = "".obs;
  var semester = "".obs;
  var year = "".obs;
  var liveClasses = <Map<String, dynamic>>[].obs;
  var previousClasses = <Map<String, dynamic>>[].obs;
  var studentsList = <Map<String, dynamic>>[].obs;
  var endTime = "".obs;  // ✅ Declare this missing variable


  // ✅ Missing variables added
  var isAttendanceMarked = false.obs;
  var classFetched = false.obs;
  var correctClassCode = "".obs;
  var teacherLocation = Rx<LatLng?>(null);

  @override
  void onInit() {
    super.onInit();
    var args = Get.arguments;
    if (args != null) {
      classId.value = args["classId"];
      className.value = args["className"];

      fetchClassDetails();
      fetchAttendanceRecords();
      fetchStudentsList();
      checkStudentAttendance(); // ✅ Automatically check attendance
    }
  }

  Future<void> navigateToAttendanceVerification() async {
    try {
      String studentId = FirebaseAuth.instance.currentUser!.uid;

      QuerySnapshot classQuery = await FirebaseFirestore.instance
          .collection("classrooms")
          .where("students", arrayContains: studentId)
          .get();

      if (classQuery.docs.isEmpty) {
        Get.snackbar("Error", "No active class found for this student.");
        return;
      }

      var classData = classQuery.docs.first.data() as Map<String, dynamic>;

      String classId = classQuery.docs.first.id;
      String className = classData["name"];

      print("📌 DEBUG: Navigating to Attendance Verification for Class ID: $classId, Class Name: $className");

      Get.toNamed('/attendance-verification', arguments: {
        "classId": classId,
        "className": className,
      });
    } catch (e) {
      print("❌ DEBUG: Failed to Navigate to Attendance Verification - $e");
      Get.snackbar("Error", "Failed to fetch class details.");
    }
  }
  Future<void> checkStudentAttendance() async {
    try {
      String studentId = FirebaseAuth.instance.currentUser!.uid;

      // ✅ Fetch the latest attendance session
      QuerySnapshot attendanceSnapshot = await FirebaseFirestore.instance
          .collection("classrooms")
          .doc(classId.value)
          .collection("attendance")
          .orderBy("createdAt", descending: true) // ✅ Sort by latest
          .limit(1)
          .get();

      if (attendanceSnapshot.docs.isEmpty) {
        print("❌ DEBUG: No active attendance session found.");
        isAttendanceMarked.value = false;
        return;
      }

      // ✅ Extract latest session ID
      String latestAttendanceId = attendanceSnapshot.docs.first.id;
      print("📌 DEBUG: Checking attendance for Attendance ID: $latestAttendanceId");

      // ✅ Check if student has marked attendance
      DocumentSnapshot studentAttendance = await FirebaseFirestore.instance
          .collection("classrooms")
          .doc(classId.value)
          .collection("attendance")
          .doc(latestAttendanceId) // ✅ Uses latest session ID
          .collection("students")
          .doc(studentId)
          .get();

      if (studentAttendance.exists) {
        isAttendanceMarked.value = true;
        print("✅ DEBUG: Attendance already marked for Student ID: $studentId.");
      } else {
        isAttendanceMarked.value = false;
        print("❌ DEBUG: No attendance record found for Student ID: $studentId.");
      }
    } catch (e) {
      print("🔥 ERROR: Failed to check attendance - $e");
    }
  }


  Future<void> markAttendance() async {
    try {
      String studentId = FirebaseAuth.instance.currentUser!.uid;

      // ✅ Fetch latest attendance ID dynamically
      QuerySnapshot attendanceSnapshot = await FirebaseFirestore.instance
          .collection("classrooms")
          .doc(classId.value)
          .collection("attendance")
          .orderBy("createdAt", descending: true)
          .limit(1)
          .get();

      if (attendanceSnapshot.docs.isEmpty) {
        Get.snackbar("Error", "No active attendance session found.");
        return;
      }

      String attendanceId = attendanceSnapshot.docs.first.id; // ✅ Use correct attendance ID
      print("📌 DEBUG: Storing attendance in Attendance ID: $attendanceId");

      // ✅ Mark student as Present in the correct attendance session
      await FirebaseFirestore.instance
          .collection("classrooms")
          .doc(classId.value)
          .collection("attendance")
          .doc(attendanceId)
          .collection("students")
          .doc(studentId)
          .set({
        "studentId": studentId,
        "attendanceStatus": "Present",
        "timestamp": FieldValue.serverTimestamp(),
      });

      isAttendanceMarked.value = true;
      Get.snackbar("Success", "Attendance marked successfully!");

      // ✅ Ensure Firestore read consistency
      await Future.delayed(Duration(seconds: 2));
      await checkStudentAttendance();
    } catch (e) {
      print("🔥 ERROR: Failed to mark attendance - $e");
      Get.snackbar("Error", "Failed to mark attendance.");
    }
  }


  /// ✅ **Fetch Class Details**
  /// ✅ **Fetch Class Details**
  Future<void> fetchClassDetails() async {
    if (classId.value.isEmpty) {
      Get.snackbar("Error", "Class ID is missing!");
      return;
    }

    QuerySnapshot attendanceSnapshot = await FirebaseFirestore.instance
        .collection("classrooms")
        .doc(classId.value)
        .collection("attendance")
        .orderBy("createdAt", descending: true) // ✅ Get latest session
        .limit(1)
        .get();

    if (attendanceSnapshot.docs.isNotEmpty) {
      var data = attendanceSnapshot.docs.first.data() as Map<String, dynamic>;

      teacherLocation.value = LatLng(
        data["teacherLocation"]["latitude"],
        data["teacherLocation"]["longitude"],
      );

      correctClassCode.value = data["classCode"].toString().trim(); // ✅ Stores the session ID
      endTime.value = data["endTime"];
      classFetched.value = true;
    } else {
      Get.snackbar("Error", "No active attendance session found!");
    }
  }


  Future<void> fetchStudentsList() async {
    try {
      QuerySnapshot studentsSnapshot = await FirebaseFirestore.instance
          .collection("classrooms")
          .doc(classId.value)
          .collection("students")
          .get();

      studentsList.clear();
      for (var doc in studentsSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        studentsList.add({
          "name": data["name"] ?? "Unknown Student",
          "status": "Present"
        });
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch students list.");
    }
  }

  Future<void> fetchAttendanceRecords() async {
    try {
      QuerySnapshot attendanceSnapshot = await FirebaseFirestore.instance
          .collection("classrooms")
          .doc(classId.value)
          .collection("attendance")
          .orderBy("createdAt", descending: true)
          .get();

      liveClasses.clear();
      previousClasses.clear();

      DateTime now = DateTime.now(); // ✅ Get current time

      for (var doc in attendanceSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;

        String startTime = data["startTime"] ?? "N/A";
        String endTime = data["endTime"] ?? "N/A";
        String status = data.containsKey("status") ? data["status"] : "live"; // ✅ Get attendance status
        DateTime? endDateTime = _parseTime(endTime); // ✅ Convert to DateTime

        bool isCompleted = (status == "completed") || (endDateTime != null && now.isAfter(endDateTime));

        if (isCompleted) {
          previousClasses.add({
            "title": "Previous Class",
            "location": "Lat: ${data["teacherLocation"]["latitude"]}, Long: ${data["teacherLocation"]["longitude"]}",
            "date": formatDate(data["createdAt"]),
            "startTime": startTime,
            "endTime": endTime
          });

          // ✅ Ensure Firestore is updated if it wasn't marked as completed
          if (status != "completed") {
            await doc.reference.update({"status": "completed"});
          }

        } else {
          liveClasses.add({
            "title": "Live Class",
            "location": "Lat: ${data["teacherLocation"]["latitude"]}, Long: ${data["teacherLocation"]["longitude"]}",
            "startTime": startTime,
            "endTime": endTime
          });
        }
      }

      update(); // ✅ Ensure UI updates
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch attendance records: $e");
    }
  }

  DateTime? _parseTime(String time) {
    try {
      final now = DateTime.now();
      final timeParts = time.split(":");
      int hour = int.parse(timeParts[0].trim());
      int minute = int.parse(timeParts[1].split(" ")[0].trim());

      if (time.contains("PM") && hour != 12) {
        hour += 12; // Convert PM times
      } else if (time.contains("AM") && hour == 12) {
        hour = 0; // Midnight case
      }

      return DateTime(now.year, now.month, now.day, hour, minute);
    } catch (e) {
      print("❌ ERROR: Failed to parse time - $e");
      return null;
    }
  }


  Future<bool> checkStudentAttendanceForClass(String attendanceId) async {
    String studentId = FirebaseAuth.instance.currentUser!.uid;

    DocumentSnapshot attendanceDoc = await FirebaseFirestore.instance
        .collection("classrooms")
        .doc(classId.value)
        .collection("attendance")
        .doc(attendanceId)
        .collection("students")
        .doc(studentId)
        .get();

    return attendanceDoc.exists;
  }

  String formatDate(dynamic timestamp) {
    if (timestamp is Timestamp) {
      DateTime date = timestamp.toDate();
      return "${date.day}/${date.month}/${date.year}";
    }
    return "Unknown Date";
  }
}
