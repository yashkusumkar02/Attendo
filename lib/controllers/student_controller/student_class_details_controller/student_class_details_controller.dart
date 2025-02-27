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
      fetchStudentsList(); // ✅ Fetch students separately
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

      Get.toNamed('/attendance-verification', arguments: {
        "classId": classId,
        "className": className,
      });
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch class details.");
    }
  }

  Future<void> checkStudentAttendance() async {
    String studentId = FirebaseAuth.instance.currentUser!.uid;

    DocumentSnapshot attendanceDoc = await FirebaseFirestore.instance
        .collection("classrooms")
        .doc(classId.value)
        .collection("attendance")
        .doc(correctClassCode.value)
        .collection("students")
        .doc(studentId)
        .get();

    if (attendanceDoc.exists) {
      isAttendanceMarked.value = true; // ✅ Attendance already marked
    }
  }

  /// ✅ **Fetch Class Details**
  Future<void> fetchClassDetails() async {
    try {
      if (classId.value.isEmpty) {
        Get.snackbar("Error", "Class ID is missing!");
        return;
      }

      QuerySnapshot attendanceSnapshot = await FirebaseFirestore.instance
          .collection("classrooms")
          .doc(classId.value)
          .collection("attendance")
          .orderBy("createdAt", descending: true)
          .limit(1)
          .get();

      if (attendanceSnapshot.docs.isNotEmpty) {
        var data = attendanceSnapshot.docs.first.data() as Map<String, dynamic>;

        teacherLocation.value = LatLng(
          data["teacherLocation"]["latitude"],
          data["teacherLocation"]["longitude"],
        );

        correctClassCode.value = data["classCode"];
        classFetched.value = true;

        // ✅ Check if student's attendance is already marked
        await checkStudentAttendance();
      } else {
        Get.snackbar("Error", "No active attendance session found!");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch class details.");
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
          .get();

      liveClasses.clear();
      previousClasses.clear();

      for (var doc in attendanceSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;

        String startTime = data.containsKey("startTime") && data["startTime"] != null
            ? data["startTime"]
            : "N/A";

        String endTime = data.containsKey("endTime") && data["endTime"] != null
            ? data["endTime"]
            : "N/A";

        bool hasAttended = await checkStudentAttendanceForClass(doc.id);

        if (hasAttended) {
          previousClasses.add({
            "title": "Previous Class",
            "location": "Lat: ${data["teacherLocation"]["latitude"]}, Long: ${data["teacherLocation"]["longitude"]}",
            "date": formatDate(data["createdAt"]),
            "startTime": startTime
          });
        } else {
          liveClasses.add({
            "title": "Live Class",
            "location": "Lat: ${data["teacherLocation"]["latitude"]}, Long: ${data["teacherLocation"]["longitude"]}",
            "startTime": startTime,
            "endTime": endTime
          });
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch attendance records.");
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
