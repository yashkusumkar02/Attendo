import 'package:attendo/controllers/teacher_controllers/classroom_details_controller/classroom_details_controller.dart';
import 'package:attendo/screens/teacher/create_class_screen/create_class_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ClassroomDetailsScreen extends StatelessWidget {
  final String classId;
  final ClassroomDetailsController controller;

  ClassroomDetailsScreen({required this.classId})
      : controller = Get.put(ClassroomDetailsController(classId: classId));

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Get.back(),
          ),
          title: Text(
            "Class Details",
            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          actions: [
            IconButton(icon: Icon(Icons.more_vert, color: Colors.black), onPressed: () {}),
          ],
          bottom: TabBar(
            indicatorColor: Colors.blue,
            labelColor: Colors.black,
            labelStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: "Class"),
              Tab(text: "Students"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildClassTab(),
            Center(child: Text("Student List Coming Soon")),
          ],
        ),
      ),
    );
  }

  // ✅ Build Class Tab
  // ✅ Build Class Tab with Buttons to Create Attendance and View Previous
  Widget _buildClassTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Live Classes", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),

              Obx(() => controller.isLoading.value
                  ? Center(child: CircularProgressIndicator())
                  : controller.liveClasses.isNotEmpty
                  ? Column(
                children: controller.liveClasses.map((classData) {
                  return LiveClassTile(
                    title: classData["title"] ?? "Untitled Class",
                    classCode: classData["classCode"] ?? "N/A",
                    startTime: classData["startTime"] ?? "Unknown",
                    endTime: classData["endTime"] ?? "Unknown",
                    location: classData["location"] != null && classData["location"] is Map
                        ? "Lat: ${(classData["location"]["latitude"] ?? "0.0").toString()}, Lng: ${(classData["location"]["longitude"] ?? "0.0").toString()}"
                        : "No Location Data",
                    onStop: () => controller.stopAttendance(classData["attendanceId"]), classTiming: '',
                  );
                }).toList(),
              )
                  : Center(child: Text("No Live Classes", style: GoogleFonts.poppins()))),

            SizedBox(height: 20),
            Text("Previous Classes", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),

            Obx(() => controller.previousClasses.isNotEmpty
                ? Column(
              children: controller.previousClasses.map((classData) {
                return PreviousClassTile(
                  title: (classData['title'] ?? "Unnamed Class").toString(), // ✅ Ensure String
                  location: (classData['location'] ?? "Unknown Location").toString(), // ✅ Ensure String
                  date: (classData['createdAt'] ?? "N/A").toString(), // ✅ Ensure String
                  time: (classData['classCode'] ?? "N/A").toString(), // ✅ Ensure String
                  classTiming: (classData['classTiming'] ?? "No Timing Info").toString(), // ✅ Show Morning/Afternoon/Evening
                  startTime: (classData['startTime'] ?? "N/A").toString(), // ✅ Show Start Time
                  endTime: (classData['endTime'] ?? "N/A").toString(), // ✅ Show End Time
                );
              }).toList(),
            )
                : Center(child: Text("No Previous Classes", style: GoogleFonts.poppins()))),

            SizedBox(height: 20),

            // ✅ Action Buttons for Creating Attendance and Viewing Previous Attendance
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                _buildActionButton(Icons.add, "Create Attendance", Colors.blue, () {
                  Get.to(() => CreateClassScreen(classId: classId)); // ✅ Navigates to CreateClassScreen
                }),
                _buildActionButton(Icons.history, "Previous Attendance", Colors.grey, () {
                  Get.toNamed('/classroom-details', arguments: {"classId": classId});
                }),
              ],
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ✅ Generic Action Button
  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
    );
  }
}

// ✅ Live Class Tile Widget
class LiveClassTile extends StatelessWidget {
  final String title;
  final String classCode;
  final String classTiming;
  final String startTime;
  final String endTime;
  final String location;
  final VoidCallback onStop;

  LiveClassTile({
    required this.title,
    required this.classCode,
    required this.classTiming,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Class Timing: $classTiming",
                        style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Class Code: $classCode",
                        style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Time: $startTime - $endTime",
                        style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Location: $location",
                        style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.wifi, color: Colors.redAccent), // WiFi signal icon
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: onStop,
              child: Text(
                "Stop Attendance",
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: Size(double.infinity, 40),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



// ✅ Previous Class Tile Widget
class PreviousClassTile extends StatelessWidget {
  final String title;
  final String location;
  final String date;
  final String time;
  final String classTiming;
  final String startTime;
  final String endTime;

  PreviousClassTile({
    required this.title,
    required this.location,
    required this.date,
    required this.time,
    required this.classTiming,
    required this.startTime,
    required this.endTime,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Class Title
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 5),

            // ✅ Class Timing
            Text(
              "Class Timing: $classTiming",
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
            ),
            SizedBox(height: 5),

            // ✅ Class Location
            Text(
              "Location: $location",
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
            ),
            SizedBox(height: 5),

            // ✅ Class Timing
            Text(
              "Time: $startTime - $endTime",
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
            ),
            SizedBox(height: 10),

            // ✅ Date & Time Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BadgeWidget(icon: Icons.calendar_today, text: date), // 📅 Date Badge
                BadgeWidget(icon: Icons.access_time, text: time), // ⏰ Time Badge
              ],
            ),
          ],
        ),
      ),
    );
  }
}


// ✅ Badge Widget for Date & Time
class BadgeWidget extends StatelessWidget {
  final IconData icon;
  final String text;

  BadgeWidget({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          SizedBox(width: 5),
          Text(text, style: GoogleFonts.poppins(fontSize: 14, color: Colors.white)),
        ],
      ),
    );
  }
}
