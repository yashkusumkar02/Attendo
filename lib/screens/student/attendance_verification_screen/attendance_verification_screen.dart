import 'package:attendo/controllers/student_controller/attendance_verification_controller/attendance_verification_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class AttendanceVerificationScreen extends StatelessWidget {
  final AttendanceVerificationController controller = Get.put(AttendanceVerificationController());

  @override
  Widget build(BuildContext context) {
    // ✅ Fetch class details on screen load
    var args = Get.arguments;
    if (args != null && args["classId"] != null && args["className"] != null) {
      controller.classId.value = args["classId"];
      controller.className.value = args["className"];
      controller.getStudentLocation();
      controller.fetchClassDetails();
    } else {
      Get.snackbar("Error", "Class ID is missing!");
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text("Verify Attendance",
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
      ),
      body: Column(
        children: [
          // Map
          Expanded(
            child: Obx(() => controller.studentLocation.value != null
                ? FlutterMap(
              options: MapOptions(
                initialCenter: controller.studentLocation.value!,
                initialZoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                if (controller.teacherLocation.value != null)
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: controller.teacherLocation.value!,
                        radius: 50, // ✅ 50 meter circular radius
                        useRadiusInMeter: true,
                        color: Colors.red.withOpacity(0.3),
                        borderColor: Colors.red,
                        borderStrokeWidth: 2,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    if (controller.teacherLocation.value != null)
                      Marker(
                        point: controller.teacherLocation.value!,
                        width: 50,
                        height: 50,
                        child: Icon(Icons.location_pin, color: Colors.red, size: 40),
                      ),
                    Marker(
                      point: controller.studentLocation.value!,
                      width: 50,
                      height: 50,
                      child: Icon(Icons.person_pin_circle, color: Colors.blue, size: 40),
                    ),
                  ],
                ),
              ],
            )
                : Center(child: CircularProgressIndicator())),
          ),

          // Face Scan & Class Code Section
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Scan Face Button
                Obx(() => ElevatedButton.icon(
                  onPressed: controller.scanFace,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: controller.faceScanned.value ? Colors.green : Colors.blue,
                    minimumSize: Size(double.infinity, 50),
                  ),
                  icon: Icon(Icons.face, color: Colors.white),
                  label: Text(
                    controller.faceScanned.value ? "Face Verified ✅" : "Scan Face",
                    style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
                  ),
                )),
                SizedBox(height: 15),

                // Class Code Input
                TextField(
                  controller: controller.classCodeController,
                  decoration: InputDecoration(
                    hintText: "Enter Class Code",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    prefixIcon: Icon(Icons.vpn_key),
                  ),
                ),

                // Verify Attendance Button
                SizedBox(height: 15),
                ElevatedButton(
                  onPressed: controller.verifyAttendance,
                  child: Text("Verify Attendance"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
