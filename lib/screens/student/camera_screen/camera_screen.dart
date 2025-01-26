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

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    if (cameras!.isNotEmpty) {
      _cameraController = CameraController(cameras![1], ResolutionPreset.high);
      await _cameraController!.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _captureImage() async {
    if (!_cameraController!.value.isInitialized) {
      return;
    }

    final XFile image = await _cameraController!.takePicture();
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String imagePath = join(appDir.path, '${DateTime.now()}.jpg');

    File(image.path).copy(imagePath);

    // ✅ Pass the image path back to the verification screen
    Get.back(result: imagePath);
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
            child: IconButton(
              icon: Icon(Icons.camera, size: 60, color: Colors.white),
              onPressed: _captureImage,
            ),
          ),
        ],
      )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
