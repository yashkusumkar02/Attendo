import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class StudentDashboardController extends GetxController {
  var studentName = "".obs;
  var profileImage = "".obs;
  var joinedClassrooms = <Map<String, dynamic>>[].obs; // ✅ Stores joined classrooms

  @override
  void onInit() {
    super.onInit();
    fetchStudentData();
    fetchJoinedClassrooms();
    ever(profileImage, (_) => update());// ✅ Fetch joined classrooms
  }

  // ✅ Fetch Student Data from Firestore
  Future<void> fetchStudentData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Get.offAllNamed('/role-selection');
        return;
      }

      DocumentSnapshot studentDoc =
      await FirebaseFirestore.instance.collection("students").doc(user.uid).get();

      if (studentDoc.exists) {
        Map<String, dynamic>? studentData = studentDoc.data() as Map<String, dynamic>?;

        studentName.value = studentData?["name"] ?? "Student";

        // ✅ Check if 'faceImageBase64' field exists before accessing it
        if (studentData?.containsKey("profileImageBase64") == true) {
          profileImage.value = studentData?["profileImageBase64"] ?? "";
        } else {
          print("⚠️ faceImageBase64 field does not exist. Using default image.");
          profileImage.value = ""; // Set to an empty string or default image
        }
      } else {
        Get.snackbar("Error", "Student details not found.");
        Get.offAllNamed('/role-selection');
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch student details: $e");
      print("❌ Fetch Student Data Error: $e");
    }
  }

  // ✅ Fetch Joined Classrooms (Fetch Semester from the Classroom Database)
  Future<void> fetchJoinedClassrooms() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection("students")
        .doc(user.uid)
        .collection("joinedClasses")
        .snapshots()
        .listen((QuerySnapshot snapshot) async {
      List<Map<String, dynamic>> joinedClassesList = [];

      for (var doc in snapshot.docs) {
        var classData = doc.data() as Map<String, dynamic>;
        String classId = doc.id;

        DocumentSnapshot classDoc = await FirebaseFirestore.instance
            .collection("classrooms")
            .doc(classId)
            .get();

        if (classDoc.exists) {
          var classDetails = classDoc.data() as Map<String, dynamic>;
          String teacherId = classDetails["teacherId"] ?? "";

          String teacherName = await _fetchTeacherName(teacherId);

          joinedClassesList.add({
            "classId": classId,
            "className": classDetails["name"] ?? "Unknown Class",
            "teacher": teacherName,
            "semester": classDetails["semester"] ?? "N/A",
            "year": classDetails["year"] ?? "N/A",
          });
        }
      }

      joinedClassrooms.assignAll(joinedClassesList);
    });

    update(); // ✅ Force update UI
  }


  // ✅ Fetch Teacher Name from `users` Collection
  Future<String> _fetchTeacherName(String teacherId) async {
    try {
      if (teacherId.isEmpty) return "Unknown Teacher";

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
}
