import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';

import '../../roleselection/role_selection_screen.dart';

class StudentProfilePage extends StatefulWidget {
  @override
  _StudentProfilePageState createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      final frontCamera = _cameras?.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );

      if (frontCamera != null) {
        _cameraController = CameraController(frontCamera, ResolutionPreset.medium);
        await _cameraController!.initialize();
        setState(() {});
      } else {
        Get.snackbar("Error", "No front camera found!");
      }
    } catch (e) {
      print("Error initializing camera: $e");
      Get.snackbar("Error", "Unable to initialize camera");
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _startFaceScan() async {
    await Get.to(() => CameraPage(
      cameraController: _cameraController,
      onCapture: (image) async {
        // Simulate a verification process
        await Future.delayed(Duration(seconds: 2));
        Get.snackbar(
          "Face Scan",
          "Face verified successfully!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFE),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    height: 40, // Set the desired height
                    width: 40,  // Set the desired width
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_circle_left_outlined,
                        size: 40, // Adjust the icon size
                      ),
                      onPressed: () => Get.off(RoleSelectionScreen()), // Use GetX to navigate back
                    ),
                  ),
                  Spacer(),
                  Text(
                    "Student",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Spacer(),
                ],
              ),
              SizedBox(height: 20),
              Text(
                "Please provide your personal details to proceed.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/profile_image.png',
                      height: 300,
                      width: 300,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Upload Profile Image",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: _startFaceScan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: 30,
                      width: 30,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Face Scan",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Handle submit functionality
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  "Submit",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CameraPage extends StatelessWidget {
  final CameraController? cameraController;
  final Function(XFile) onCapture;

  CameraPage({required this.cameraController, required this.onCapture});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: cameraController != null && cameraController!.value.isInitialized
          ? Stack(
        children: [
          CameraPreview(cameraController!),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: () async {
                  final image = await cameraController!.takePicture();
                  onCapture(image);
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(15),
                ),
                child: Icon(
                  Icons.camera,
                  color: Colors.black,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      )
          : Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
