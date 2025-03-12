import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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
    fetchAttendance(); // ✅ Load attendance when the screen opens
  }

  // ✅ Fetch Attendance and Sort into Live & Previous Classes
  void fetchAttendance() {
    isLoading(true);

    _db
        .collection("classrooms")
        .doc(classId)
        .collection("attendance")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .listen((snapshot) async {
      List<Map<String, dynamic>> updatedLiveClasses = [];
      List<Map<String, dynamic>> updatedPreviousClasses = [];

      DateTime now = DateTime.now(); // ✅ Get current timestamp

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data();
        String attendanceId = doc.id;
        String status = data["status"] ?? "live"; // Default to live
        String endTimeStr = data["endTime"] ?? "11:59 PM"; // Default fallback

        // ✅ Extract class created date from Firestore
        DateTime classDate = (data["createdAt"] as Timestamp).toDate();

        // ✅ Combine class date with parsed end time
        DateTime fullEndTime;
        try {
          DateTime parsedEndTime = DateFormat("h:mm a").parse(endTimeStr);
          fullEndTime = DateTime(classDate.year, classDate.month, classDate.day,
              parsedEndTime.hour, parsedEndTime.minute);
        } catch (e) {
          print("⚠️ Error parsing endTime: $e");
          continue;
        }

        print("🕒 Now: $now | ⏳ Full End Time: $fullEndTime | Status: $status");

        // ✅ Ensure new classes are set as "live" by default
        if (status == "completed" && now.isBefore(fullEndTime)) {
          print("🟡 Attendance $attendanceId should be 'live', correcting...");
          await _db
              .collection("classrooms")
              .doc(classId)
              .collection("attendance")
              .doc(attendanceId)
              .update({"status": "live"});
          status = "live"; // ✅ Locally update status
        }

        // ✅ Separate into "live" and "completed" lists
        if (status == "live") {
          updatedLiveClasses.add({
            "attendanceId": attendanceId,
            "title": data["classTiming"] ?? "Live Class",
            "startTime": data["startTime"] ?? "N/A",
            "endTime": data["endTime"] ?? "N/A",
            "classCode": data["classCode"] ?? "N/A",
            "location": (data["teacherLocation"] != null)
                ? "Lat: ${data["teacherLocation"]["latitude"]}, Lng: ${data["teacherLocation"]["longitude"]}"
                : "No Location Data",
          });
        } else {
          updatedPreviousClasses.add({
            "attendanceId": attendanceId,
            "title": data["classTiming"] ?? "Previous Class",
            "startTime": data["startTime"] ?? "N/A",
            "endTime": data["endTime"] ?? "N/A",
            "classCode": data["classCode"] ?? "N/A",
            "date": DateFormat("dd MMMM yyyy").format(classDate),
            "location": (data["teacherLocation"] != null)
                ? "Lat: ${data["teacherLocation"]["latitude"]}, Lng: ${data["teacherLocation"]["longitude"]}"
                : "No Location Data",
          });
        }
      }

      // ✅ Update UI with filtered lists
      liveClasses.value = updatedLiveClasses;
      previousClasses.value = updatedPreviousClasses;

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
