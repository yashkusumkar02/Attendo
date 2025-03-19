import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  bool _isCameraInitialized = false;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras == null || cameras!.isEmpty) {
        Get.snackbar("Camera Error", "No cameras available.");
        return;
      }

      // ✅ Ensure front camera is selected
      CameraDescription frontCamera = cameras!.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras!.first, // Default to first camera if no front
      );

      _cameraController = CameraController(frontCamera, ResolutionPreset.high);
      await _cameraController!.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      Get.snackbar("Camera Error", "Failed to initialize camera: $e");
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _captureImage() async {
    if (!_cameraController!.value.isInitialized || _isCapturing) {
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      final XFile image = await _cameraController!.takePicture();
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String imagePath = join(appDir.path, '${DateTime.now()}.jpg');

      await File(image.path).copy(imagePath);

      // ✅ Pass the image path back to the attendance verification screen
      Get.back(result: imagePath);
    } catch (e) {
      Get.snackbar("Capture Error", "Failed to take picture: $e");
    } finally {
      setState(() {
        _isCapturing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isCameraInitialized
          ? Stack(
        children: [
          CameraPreview(_cameraController!),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: _captureImage,
              child: Icon(
                _isCapturing ? Icons.camera_alt_outlined : Icons.camera,
                size: 60,
                color: Colors.white,
              ),
            ),
          ),
        ],
      )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
