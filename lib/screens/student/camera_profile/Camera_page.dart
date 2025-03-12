import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:async';

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
  FaceDetector faceDetector = GoogleMlKit.vision.faceDetector(
    FaceDetectorOptions(
      enableClassification: true,
      enableLandmarks: true,
      enableContours: true,
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
    try {
      if (widget.cameras == null || widget.cameras!.isEmpty) {
        Get.snackbar("Error", "No cameras available");
        return;
      }
      _cameraController = CameraController(
        widget.cameras![selectedCameraIndex],
        ResolutionPreset.medium,
      );
      await _cameraController!.initialize();
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      Get.snackbar("Error", "Camera failed to initialize: $e");
    }
  }

  void _switchCamera() {
    if (widget.cameras!.length > 1) {
      selectedCameraIndex = (selectedCameraIndex + 1) % widget.cameras!.length;
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
      final XFile image = await _cameraController!.takePicture();
      File imageFile = File(image.path);
      bool isRealPerson = await _verifyLiveness(imageFile);

      if (isRealPerson) {
        setState(() {
          faceDetected = true;
        });
        Get.snackbar("Face Detected", "Wait and look forward. Capturing in 5 seconds...");
        await Future.delayed(Duration(seconds: 5));
        _captureImage();
      } else {
        Get.snackbar("Error", "Liveness detection failed! Please try again.");
      }
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
      File imageFile = File(image.path);
      Get.back(result: imageFile);
    } catch (e) {
      Get.snackbar("Error", "Failed to Capture Image: $e");
    } finally {
      setState(() {
        isCapturing = false;
      });
    }
  }

  Future<bool> _verifyLiveness(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final List<Face> faces = await faceDetector.processImage(inputImage);

    if (faces.isEmpty) {
      Get.snackbar("Error", "No face detected! Try again.");
      return false;
    }

    Face face = faces.first;
    bool isEyeOpen = (face.leftEyeOpenProbability ?? 0) > 0.2 &&
        (face.rightEyeOpenProbability ?? 0) > 0.2;

    bool hasHeadMovement = (face.headEulerAngleY ?? 0).abs() > 5 ||
        (face.headEulerAngleZ ?? 0).abs() > 5;

    bool hasMouthMovement = (face.smilingProbability ?? 0) > 0.3;

    if (!isEyeOpen) {
      Get.snackbar("Error", "Please blink your eyes for verification.");
      return false;
    }

    if (!hasHeadMovement) {
      Get.snackbar("Error", "Move your head slightly for verification.");
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