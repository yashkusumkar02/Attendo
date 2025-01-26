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
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search student by name",
                filled: true,
                fillColor: Colors.grey.shade100,
                prefixIcon: Icon(Icons.search, color: Colors.blue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Student Info Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 2,
              child: Obx(() => ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Icon(Icons.person, color: Colors.blue),
                ),
                title: Text(
                  (controller.studentDetails["name"] ?? "Unknown Student").toString(),
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  (controller.studentDetails["details"] ?? "No details available").toString(),
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                ),
                trailing: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: (controller.studentDetails["status"] ?? "Absent").toString() == "Present"
                        ? Colors.green
                        : Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    (controller.studentDetails["status"] ?? "Absent").toString(),
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                  ),
                ),
              )),
            ),
          ),


          Spacer(), // Push bottom sheet to the bottom

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
                // Drag handle
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                SizedBox(height: 10),

                // Attendance Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Attendance", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                    Obx(() => Text("Class: ${controller.studentDetails["attended_classes"]}/${controller.studentDetails["total_classes"]}",
                        style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey))),
                  ],
                ),
                SizedBox(height: 5),

                // Progress Bar for Attendance
                Obx(() {
                  double progress = ((controller.studentDetails["attendance_percentage"] ?? 0) as num).toDouble() / 100;

                  return LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0), // Ensures value is between 0.0 and 1.0
                    backgroundColor: Colors.grey.shade300,
                    color: Colors.blue,
                    minHeight: 8,
                  );
                }),
                SizedBox(height: 5),

                // Percentage Display
                Obx(() => Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "${controller.studentDetails["attendance_percentage"]}%",
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                )),
                SizedBox(height: 20),

                // Mark Attendance Buttons
                _buildActionButton("Mark Present", Icons.arrow_forward, Colors.green, controller.markPresent),
                SizedBox(height: 10),
                _buildActionButton("Mark Absent", Icons.arrow_forward, Colors.red, controller.markAbsent),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Attendance Action Button
  Widget _buildActionButton(String text, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        elevation: 1,
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black)),
          Icon(icon, color: color),
        ],
      ),
    );
  }
}
