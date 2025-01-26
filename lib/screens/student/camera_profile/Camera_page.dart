import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

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
  FaceDetector faceDetector = GoogleMlKit.vision.faceDetector();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      if (widget.cameras == null || widget.cameras!.isEmpty) {
        Get.snackbar("Error", "No cameras available");
        return;
      }
      _cameraController =
          CameraController(widget.cameras![0], ResolutionPreset.medium);
      await _cameraController!.initialize();
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      Get.snackbar("Error", "Camera failed to initialize: $e");
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    faceDetector.close();
    super.dispose();
  }

  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;

    setState(() {
      isCapturing = true;
    });

    try {
      final XFile image = await _cameraController!.takePicture();
      File imageFile = File(image.path);

      bool faceDetected = await _detectFace(imageFile);
      if (faceDetected) {
        Get.back(result: imageFile);
      } else {
        Get.snackbar("Error", "No Face Detected! Try Again.");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to Capture Image: $e");
    } finally {
      setState(() {
        isCapturing = false;
      });
    }
  }

  Future<bool> _detectFace(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final List<Face> faces = await faceDetector.processImage(inputImage);
    return faces.isNotEmpty;
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
              /// Back Button & Title
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
                ],
              ),
              SizedBox(height: 20),

              /// Camera Preview Box
              Center(
                child: Container(
                  height: 600,
                  width: 350,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: _cameraController != null &&
                      _cameraController!.value.isInitialized
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

              /// Scan Face Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isCapturing ? null : _captureImage,
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
