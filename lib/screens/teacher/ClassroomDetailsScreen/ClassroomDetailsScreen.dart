import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:attendo/models/classroom_model.dart';

class ClassroomDetaillsScreen extends StatelessWidget {
  final ClassroomModel classroom;

  // ✅ Convert Get.arguments map back to a ClassroomModel
  ClassroomDetaillsScreen({Key? key})
      : classroom = ClassroomModel(
    id: Get.arguments["classId"] ?? "",
    name: Get.arguments["name"] ?? "Unknown",
    college: Get.arguments["college"] ?? "Unknown",
    branch: Get.arguments["branch"] ?? "Unknown",
    semester: Get.arguments["semester"]?.toString() ?? "Unknown", // ✅ Convert to String
    year: Get.arguments["year"]?.toString() ?? "Unknown", // ✅ Convert to String
  ),
        super(key: key) {
    print("🔍 DEBUG: Classroom Details Received → ${Get.arguments}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(classroom.name, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildClassInfo(),
            SizedBox(height: 20),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  // ✅ Class Info Card
  Widget _buildClassInfo() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(Icons.school, "College", classroom.college),
            _buildInfoRow(Icons.engineering, "Branch", classroom.branch),
            _buildInfoRow(Icons.book, "Semester", classroom.semester),
            _buildInfoRow(Icons.calendar_today, "Year", classroom.year),
            _buildInfoRow(Icons.vpn_key, "Class ID", classroom.id),
          ],
        ),
      ),
    );
  }

  // ✅ Helper for Icon + Text Row
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 24),
          SizedBox(width: 10),
          Text(
            "$label: ",
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Wrap(
      spacing: 10, // ✅ Space between buttons
      alignment: WrapAlignment.center, // ✅ Center align buttons
      children: [
        _buildActionButton(Icons.people, "View Students", Colors.green, () {
          Get.toNamed('/student-list'); // ✅ Navigate to student list
        }),
        _buildActionButton(Icons.add, "Create Attendance", Colors.blue, () {
          Get.toNamed('/classroom-details', arguments: {
            "classId": classroom.id,
          }); // ✅ Navigate to Classroom Details with classId
        }),
      ],
    );
  }


  // ✅ Generic Action Button
  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
    );
  }
}
