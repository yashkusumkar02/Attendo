import 'package:attendo/controllers/teacher_controllers/student_attendance_controller/student_attendance_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentAttendanceDetailsScreen extends StatelessWidget {
  final StudentAttendanceController controller = Get.put(StudentAttendanceController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Present Student",
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator()); // ✅ Show loading spinner
        }

        if (controller.studentDetails.isEmpty) {
          return Center(child: Text("No data found!", style: GoogleFonts.poppins()));
        }

        return Column(
          children: [
            // Student Info Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Icon(Icons.person, color: Colors.blue),
                  ),
                  title: Text(
                    controller.studentDetails["name"],
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Attendance: ${controller.studentDetails["attended_classes"]}/${controller.studentDetails["total_classes"]}",
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                  ),
                  trailing: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: controller.studentDetails["status"] == "Present"
                          ? Colors.green
                          : Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      controller.studentDetails["status"],
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),

            Spacer(),

            // Bottom Sheet for Attendance Info
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              ),
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Attendance", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("${controller.studentDetails["attendance_percentage"]}%",
                          style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                  SizedBox(height: 5),

                  // Progress Bar
                  LinearProgressIndicator(
                    value: (controller.studentDetails["attendance_percentage"] ?? 0) / 100,
                    backgroundColor: Colors.grey.shade300,
                    color: Colors.blue,
                    minHeight: 8,
                  ),
                  SizedBox(height: 20),

                  // Attendance Buttons
                  _buildActionButton("Mark Present", Icons.check, Colors.green, controller.markPresent),
                  SizedBox(height: 10),
                  _buildActionButton("Mark Absent", Icons.close, Colors.red, controller.markAbsent),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildActionButton(String text, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text, style: GoogleFonts.poppins(fontSize: 16)),
      style: ElevatedButton.styleFrom(backgroundColor: color),
    );
  }
}
