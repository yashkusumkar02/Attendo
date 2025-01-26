import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class ClassroomDetailsController extends GetxController {
  var isLoading = false.obs;
  var liveClasses = [].obs;
  var previousClasses = [].obs;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String classId;

  ClassroomDetailsController({required this.classId});

  @override
  void onInit() {
    super.onInit();
    fetchAttendance(); // Load attendance when the screen opens
  }

  // ✅ Fetch Attendance Only for this Classroom
  void fetchAttendance() {
    isLoading(true);

    _db
        .collection("classrooms")
        .doc(classId)
        .collection("attendance")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .listen((snapshot) {
      liveClasses.value = snapshot.docs
          .where((doc) => doc["status"] == "live")
          .map((doc) {
        Map<String, dynamic> data = doc.data();
        return {
          "attendanceId": data["attendanceId"] ?? "",
          "title": (data["classTiming"] ?? "Unnamed Class").toString(),  // ✅ Ensure String
          "classTiming": (data["classTiming"] ?? "Unknown").toString(),  // ✅ Ensure String
          "startTime": (data["startTime"] ?? "N/A").toString(),          // ✅ Ensure String
          "endTime": (data["endTime"] ?? "N/A").toString(),              // ✅ Ensure String
          "classCode": (data["classCode"] ?? "N/A").toString(),          // ✅ Ensure String
          "location": (data["teacherLocation"] != null)
              ? "Lat: ${data["teacherLocation"]["latitude"]}, Lng: ${data["teacherLocation"]["longitude"]}"
              : "No Location Data",  // ✅ Ensure String
        };
      }).toList();

      previousClasses.value = snapshot.docs
          .where((doc) => doc["status"] == "completed")
          .map((doc) {
        Map<String, dynamic> data = doc.data();
        return {
          "attendanceId": data["attendanceId"] ?? "",
          "title": (data["classTiming"] ?? "Unnamed Class").toString(),
          "classTiming": (data["classTiming"] ?? "Unknown").toString(),
          "startTime": (data["startTime"] ?? "N/A").toString(),
          "endTime": (data["endTime"] ?? "N/A").toString(),
          "classCode": (data["classCode"] ?? "N/A").toString(),
          "location": (data["teacherLocation"] != null)
              ? "Lat: ${data["teacherLocation"]["latitude"]}, Lng: ${data["teacherLocation"]["longitude"]}"
              : "No Location Data",
        };
      }).toList();

      update(); // ✅ Ensure UI updates in real-time
      isLoading(false);
    });
  }


  // ✅ Stop Attendance (Mark it as completed)
  void stopAttendance(String attendanceId) async {
    try {
      await _db
          .collection("classrooms")
          .doc(classId)
          .collection("attendance")
          .doc(attendanceId)
          .update({
        "status": "completed",
      });

      Get.snackbar("Success", "Attendance marked as completed", snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar("Error", "Failed to stop attendance: $e", snackPosition: SnackPosition.BOTTOM);
    }
  }
}
