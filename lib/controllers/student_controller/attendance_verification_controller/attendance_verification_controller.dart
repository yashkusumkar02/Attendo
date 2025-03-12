import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:attendo/routes/app_routes.dart';
import 'package:attendo/screens/student/camera_screen/camera_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:latlong2/latlong.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';

class AttendanceVerificationController extends GetxController {
  var classId = "".obs;
  var className = "".obs;
  var faceScanned = false.obs;
  var locationVerified = false.obs;
  var studentLocation = Rx<LatLng?>(null);
  var teacherLocation = Rx<LatLng?>(null);
  var correctClassCode = "".obs;
  var classFetched = false.obs;
  var endTime = "".obs;
  var isAttendanceMarked = false.obs;

  TextEditingController classCodeController = TextEditingController();

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
        .orderBy("createdAt", descending: true)
        .limit(1)
        .get();

    if (attendanceSnapshot.docs.isNotEmpty) {
      var data = attendanceSnapshot.docs.first.data() as Map<String, dynamic>;

      teacherLocation.value = LatLng(
        data["teacherLocation"]["latitude"],
        data["teacherLocation"]["longitude"],
      );

      correctClassCode.value = data["classCode"].toString().trim();
      endTime.value = data["endTime"];
      classFetched.value = true;

      Get.snackbar("Success", "Class details fetched successfully!");
    } else {
      Get.snackbar("Error", "No active attendance session found!");
    }
  }

  /// ✅ **Get Student's Current Location**
  Future<void> getStudentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition();
    studentLocation.value = LatLng(position.latitude, position.longitude);

    if (!isWithinAllowedDistance()) {
      _showLocationErrorDialog();
    }
  }

  /// ✅ **Check if Student is within 50m**
  bool isWithinAllowedDistance() {
    if (studentLocation.value == null || teacherLocation.value == null) return false;
    double distance = Geolocator.distanceBetween(
      studentLocation.value!.latitude, studentLocation.value!.longitude,
      teacherLocation.value!.latitude, teacherLocation.value!.longitude,
    );
    return distance <= 50;
  }

  /// ✅ **Scan Face and Verify**
  Future<void> scanFace() async {
    if (!isWithinAllowedDistance()) {
      _showLocationErrorDialog();
      return;
    }

    // ✅ Open Camera and Capture Image
    String? imagePath = await Get.to(() => CameraScreen());

    if (imagePath == null) {
      Get.snackbar("Error", "Face scan failed. Please try again.");
      return;
    }

    // ✅ Verify Face with Firebase
    bool isFaceMatched = await verifyFace(imagePath);

    if (isFaceMatched) {
      faceScanned.value = true;  // ✅ Update UI
      Get.snackbar("Success", "Face successfully verified.");
    } else {
      Get.snackbar("Error", "Face mismatch! Please try again.");
    }
  }

  /// ✅ **Verify Attendance**
  Future<void> verifyAttendance() async {
    if (!classFetched.value) {
      Get.snackbar("Error", "Class details are not loaded!");
      return;
    }

    if (!isWithinAllowedDistance()) {
      Get.snackbar("Error", "You are too far from the teacher’s location!");
      return;
    }

    if (!faceScanned.value) {
      Get.snackbar("Error", "Please scan your face first!");
      return;
    }

    if (classCodeController.text.trim() != correctClassCode.value.trim()) {
      Get.snackbar("Error", "Invalid Class Code!");
      return;
    }

    if (_isAttendanceTimeOver()) {
      Get.snackbar("Error", "Attendance time is over!");
      return;
    }

    // ✅ If all conditions pass, then mark attendance
    await markAttendance();
  }


  /// ✅ **Check if Attendance Time is Over**
  bool _isAttendanceTimeOver() {
    if (endTime.value.isEmpty) return false;

    // ✅ Get current date
    DateTime now = DateTime.now();

    // ✅ Parse Firestore `endTime` with today's date
    DateTime classEndTime = DateFormat("h:mm a").parse(endTime.value);
    classEndTime = DateTime(now.year, now.month, now.day, classEndTime.hour, classEndTime.minute);

    print("⏳ Current Time: ${now.toString()}");
    print("⏰ Class End Time: ${classEndTime.toString()}");

    return now.isAfter(classEndTime);
  }

  /// ✅ **Mark Attendance**
  Future<void> markAttendance() async {
    print("🔥 DEBUG: `markAttendance()` called from AttendanceVerificationController");

    String studentId = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection("classrooms")
        .doc(classId.value)
        .collection("attendance")
        .doc(correctClassCode.value)
        .collection("students")
        .doc(studentId)
        .set({
      "studentId": studentId,
      "attendanceStatus": "Present",
      "timestamp": FieldValue.serverTimestamp(),
    });

    Get.snackbar("Success", "Attendance marked successfully!");

    // ✅ Redirect to Student Class Details instead of Teacher's
    Get.offNamed(AppRoutes.studentClassDetails, arguments: {"classId": classId.value});
  }




  /// ✅ **Verify Face with Firebase**
  /// ✅ **Verify Face with Firebase**
  Future<bool> verifyFace(String capturedImagePath) async {
    try {
      String studentId = FirebaseAuth.instance.currentUser!.uid;

      // ✅ 1. Fetch Student's Registered Face (Base64)
      DocumentSnapshot studentDoc = await FirebaseFirestore.instance.collection("students").doc(studentId).get();

      if (!studentDoc.exists || !studentDoc.data().toString().contains("faceImageBase64")) {
        print("❌ ERROR: No registered face found in Firestore.");
        return false;
      }

      String base64Face = studentDoc["faceImageBase64"];
      Uint8List registeredFaceBytes = base64Decode(base64Face);

      // ✅ 2. Save Registered Face Locally
      final Directory tempDir = await getTemporaryDirectory();
      final File registeredFaceFile = File('${tempDir.path}/registered_face.jpg');
      await registeredFaceFile.writeAsBytes(registeredFaceBytes);

      // ✅ 3. Initialize Face Detector with Landmark Detection
      FaceDetector faceDetector = GoogleMlKit.vision.faceDetector(
        FaceDetectorOptions(
          enableClassification: true,
          enableLandmarks: true,  // ✅ Required for feature extraction
          enableContours: true,   // ✅ Improves accuracy
        ),
      );

      // ✅ 4. Process Both Images
      List<Face> capturedFaces = await faceDetector.processImage(InputImage.fromFile(File(capturedImagePath)));
      List<Face> registeredFaces = await faceDetector.processImage(InputImage.fromFile(registeredFaceFile));

      faceDetector.close();

      // ✅ Debugging: Print detected faces
      print("📸 Captured Faces: ${capturedFaces.length}");
      print("🖼️ Registered Faces: ${registeredFaces.length}");

      // ✅ 5. Ensure Faces Exist
      if (capturedFaces.isEmpty || registeredFaces.isEmpty) {
        print("❌ ERROR: No faces detected.");
        return false;
      }

      // ✅ 6. Extract Feature Vectors (Bounding Box and Key Landmarks)
      Face capturedFace = capturedFaces.first;
      Face registeredFace = registeredFaces.first;

      // ✅ 7. Compare Face Features
      double similarityScore = calculateFaceSimilarity(capturedFace, registeredFace);
      print("📊 Face Similarity Score: $similarityScore");

      // ✅ 8. Return Match Result (Threshold: 80%)
      return similarityScore >= 0.80;
    } catch (e) {
      print("🔥 ERROR: Face Verification Failed - $e");
      return false;
    }
  }
  double calculateFaceSimilarity(Face face1, Face face2) {
    // ✅ Extract Landmark Points (Eyes, Nose, Mouth, Jaw, etc.)
    Map<FaceContourType, FaceContour?> contours1 = face1.contours;
    Map<FaceContourType, FaceContour?> contours2 = face2.contours;

    if (contours1.isEmpty || contours2.isEmpty) return 0.0;

    double sumOfDifferences = 0.0;
    int totalPoints = 0;

    // ✅ Compare Each Landmark Point
    for (FaceContourType type in FaceContourType.values) {
      if (contours1[type] != null && contours2[type] != null) {
        List<Point<int>> points1 = contours1[type]!.points;
        List<Point<int>> points2 = contours2[type]!.points;

        for (int i = 0; i < points1.length && i < points2.length; i++) {
          sumOfDifferences += (points1[i].x - points2[i].x).abs() +
              (points1[i].y - points2[i].y).abs();
          totalPoints++;
        }
      }
    }
    }

  /// ✅ **Extract Face Features for Comparison**
  List<double> extractFaceFeatures(Face face) {
    List<double> features = [];

    if (face.contours[FaceContourType.face] != null) {
      for (var point in face.contours[FaceContourType.face]!.points) {
        features.add(point.x.toDouble());
        features.add(point.y.toDouble());
      }
    }

    return features;
  }

  /// ✅ **Calculate Cosine Similarity between Two Feature Sets**
  double cosineSimilarity(List<double> vectorA, List<double> vectorB) {
    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;

    for (int i = 0; i < vectorA.length; i++) {
      dotProduct += vectorA[i] * vectorB[i];
      normA += vectorA[i] * vectorA[i];
      normB += vectorB[i] * vectorB[i];
    }

    return dotProduct / (sqrt(normA) * sqrt(normB));
  }


  /// ✅ **Download Image from Firebase Storage**
  Future<File> downloadImageFromFirebase(String imageUrl) async {
    final Directory tempDir = await getTemporaryDirectory();
    final String filePath = '${tempDir.path}/student_face.jpg';
    File file = File(filePath);
    await FirebaseStorage.instance.refFromURL(imageUrl).writeToFile(file);
    return file;
  }

  /// ✅ **Compare Face Features**
  double calculateFaceSimilarity(Face face1, Face face2) {
    Rect box1 = face1.boundingBox;
    Rect box2 = face2.boundingBox;

    double intersection = (box1.overlaps(box2)) ? 1.0 : 0.0; // 1 if they overlap, 0 if not

    return intersection; // 1 = Match, 0 = No Match
  }




  /// ✅ **Show Location Error**
  void _showLocationErrorDialog() {
    Get.defaultDialog(
      title: "Location Error",
      content: Column(
        children: [
          Icon(Icons.location_off, color: Colors.red, size: 50),
          SizedBox(height: 10),
          Text("You are too far from the teacher's location!"),
        ],
      ),
      confirm: ElevatedButton(onPressed: () => Get.back(), child: Text("OK")),
    );
  }
}
