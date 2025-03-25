import 'dart:convert';
import 'dart:io';
import 'package:attendo/controllers/student_controller/student_dashboard_controller/student_controller.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';

class CameraPage extends StatefulWidget {
  final List<CameraDescription>? cameras;
  final String studentId;

  CameraPage({required this.cameras, required this.studentId});

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _cameraController;
  bool isCapturing = false;
  FaceDetector faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );
  int selectedCameraIndex = 0;
  bool faceDetected = false;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    WidgetsFlutterBinding.ensureInitialized(); // ✅ Ensures Flutter is ready

    PermissionStatus status = await Permission.camera.request();
    if (!status.isGranted) {
      Get.snackbar("Permission Denied", "Camera permission is required!");
      return;
    }

    try {
      if (widget.cameras == null || widget.cameras!.isEmpty) {
        Get.snackbar("Error", "No cameras available");
        return;
      }

      _cameraController = CameraController(
        widget.cameras![selectedCameraIndex],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (!mounted) return;

      setState(() {});
    } catch (e) {
      Get.snackbar("Error", "Camera initialization failed: $e");
    }
  }

  void _switchCamera() async {
    if (widget.cameras!.length > 1) {
      selectedCameraIndex = (selectedCameraIndex + 1) % widget.cameras!.length;

      await _cameraController?.dispose(); // Ensure old controller is disposed
      _initializeCamera();
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    faceDetector.close();
    super.dispose();
  }

  Future<void> _detectFaceAndCapture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    try {
      await Future.delayed(Duration(milliseconds: 500)); // Ensure frame stability
      final XFile image = await _cameraController!.takePicture();
      File imageFile = File(image.path);

      if (!await imageFile.exists()) {
        Get.snackbar("Error", "Failed to capture image. Try again.");
        return;
      }

      bool isRealPerson = await _verifyLiveness(imageFile);

      if (!isRealPerson) {
        Get.snackbar("Error", "Liveness detection failed! Try again.");
        return;
      }

      setState(() {
        faceDetected = true;
      });

      Get.snackbar("Face Detected", "Wait and look forward. Capturing final image...");

      await Future.delayed(Duration(seconds: 2));

      print("✅ Calling _captureImage()...");  // Debugging output
      await _captureImage(); // Ensure this function runs
    } catch (e) {
      Get.snackbar("Error", "Failed to Capture Image: $e");
    }
  }

  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    setState(() {
      isCapturing = true;
    });

    try {
      final XFile image = await _cameraController!.takePicture();
      final File originalFile = File(image.path);

      print("✅ Image Captured at: ${originalFile.path}");

      // ✅ Convert Image to Base64
      List<int> imageBytes = await originalFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      print("✅ Image Converted to Base64");

      // ✅ Store Image in Firestore
      await _updateFirestoreProfile(base64Image);

      // ✅ Update the StudentDashboardController after capturing the image
      StudentDashboardController controller = Get.find();
      controller.profileImage.value = base64Image;

      // ✅ Navigate back to StudentProfilePage with the updated image
      Get.snackbar("Success", "Face image saved successfully!");
      Future.delayed(Duration(seconds: 1), () {
        Get.offAllNamed('/student-details', arguments: {"studentId": widget.studentId});
      });

    } catch (e) {
      Get.snackbar("Error", "Failed to Capture Image: $e");
      print("❌ Capture Image Error: $e");
    } finally {
      setState(() {
        isCapturing = false;
      });
    }
  }

  Future<void> _updateFirestoreProfile(String base64Image) async {
    try {
      await FirebaseFirestore.instance
          .collection("students")
          .doc(widget.studentId)
          .update({
        "faceImageBase64": base64Image, // ✅ Store Base64 image in Firestore
      });

      print("✅ Firestore Updated with Base64 Image");

      // ✅ Ensure Navigation Back After Firestore Update
      Future.delayed(Duration(seconds: 1), () {
        Get.offAllNamed('/student-details', arguments: {"studentId": widget.studentId});
      });

    } catch (e) {
      print("❌ Firestore Update Error: $e");
      Get.snackbar("Error", "Failed to update Firestore: $e");
    }
  }

  Future<bool> _verifyLiveness(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final List<Face> faces = await faceDetector.processImage(inputImage);

    print("✅ Detected ${faces.length} faces");  // Debugging output

    if (faces.isEmpty) {
      Get.snackbar("Error", "No face detected! Try again.");
      return false;
    }

    Face face = faces.first;
    print("🔹 Eye Open Probability: ${face.leftEyeOpenProbability}, ${face.rightEyeOpenProbability}");
    print("🔹 Head Euler Angle: Y = ${face.headEulerAngleY}, Z = ${face.headEulerAngleZ}");
    print("🔹 Smile Probability: ${face.smilingProbability}");

    bool isEyeOpen = (face.leftEyeOpenProbability ?? 0) > 0.2;  // ⬇️ Lowered from 0.3
    bool hasHeadMovement = (face.headEulerAngleY ?? 0).abs() > 3 ||
        (face.headEulerAngleZ ?? 0).abs() > 3;  // ⬇️ Lowered from 5
    bool hasMouthMovement = (face.smilingProbability ?? 0) > 0.2;  // ⬇️ Lowered from 0.3

    if (!isEyeOpen) {
      Get.snackbar("Error", "Blink your eyes for verification.");
      return false;
    }

    await Future.delayed(Duration(seconds: 1)); // ⏳ Allow face processing time

    if (!isEyeOpen) {
      Get.snackbar("Error", "Blink your eyes for verification.");
      return false;
    }

    await Future.delayed(Duration(seconds: 1));

    if (!hasHeadMovement) {
      Get.snackbar("Error", "Move your head slightly for verification.");
      return false;
    }

    await Future.delayed(Duration(seconds: 1));

    if (!hasMouthMovement) {
      Get.snackbar("Error", "Smile or move your mouth for verification.");
      return false;
    }

    return true;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6FAFE),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, size: 30, color: Colors.black),
                    onPressed: () => Get.back(),
                  ),
                  Spacer(),
                  Text(
                    "Scan Face",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.switch_camera, size: 30, color: Colors.black),
                    onPressed: _switchCamera,
                  ),
                ],
              ),
              SizedBox(height: 20),
              Center(
                child: Container(
                  height: 600,
                  width: 350,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: _cameraController != null && _cameraController!.value.isInitialized
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CameraPreview(_cameraController!),
                  )
                      : Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
              SizedBox(height: 50),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _detectFaceAndCapture,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    "Scan Face",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}