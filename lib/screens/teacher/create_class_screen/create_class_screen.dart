import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:attendo/controllers/teacher_controllers/create_class_controller/create_class_controller.dart';

class CreateClassScreen extends StatelessWidget {
  final String classId;
  final CreateClassController controller;

  CreateClassScreen({required this.classId})
      : controller = Get.put(CreateClassController(classId: classId));

  final List<String> classTimings = ["Morning", "Afternoon", "Evening"];
  final List<String> timeSlots = [
    "8:30 AM", "9:30 AM", "10:30 AM", "11:30 AM", "12:30 PM",
    "1:30 PM", "2:30 PM", "3:30 PM", "4:30 PM", "5:30 PM"
  ];

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
          "Create Attendance",
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // ✅ Class Name Dropdown
            Obx(() => DropdownButtonFormField<String>(
              value: controller.selectedClassTiming.value,
              onChanged: (newValue) {
                controller.selectedClassTiming.value = newValue!;
              },
              items: classTimings.map((String timing) {
                return DropdownMenuItem<String>(
                  value: timing,
                  child: Text(timing, style: GoogleFonts.poppins(fontSize: 16)),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: "Class Name",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            )),
            SizedBox(height: 10),

            // ✅ Auto-Generated Class Code (Read-Only)
            TextFormField(
              controller: controller.classCodeController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Class Code",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            SizedBox(height: 10),

            // ✅ Start Time Dropdown
            Obx(() => DropdownButtonFormField<String>(
              value: controller.selectedStartTime.value,
              onChanged: (newValue) {
                controller.selectedStartTime.value = newValue!;
              },
              items: timeSlots.map((String time) {
                return DropdownMenuItem<String>(
                  value: time,
                  child: Text(time, style: GoogleFonts.poppins(fontSize: 16)),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: "Select Start Time",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            )),
            SizedBox(height: 10),

            // ✅ End Time Dropdown
            Obx(() => DropdownButtonFormField<String>(
              value: controller.selectedEndTime.value,
              onChanged: (newValue) {
                controller.selectedEndTime.value = newValue!;
              },
              items: timeSlots.map((String time) {
                return DropdownMenuItem<String>(
                  value: time,
                  child: Text(time, style: GoogleFonts.poppins(fontSize: 16)),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: "Select End Time",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            )),
            SizedBox(height: 10),

            // ✅ Fetch Location Button
            ElevatedButton.icon(
              onPressed: controller.getTeacherLocation,
              icon: Icon(Icons.location_on, color: Colors.white),
              label: Obx(() => Text(controller.teacherLocationText.value,
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
              )),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
            SizedBox(height: 20),

            // ✅ Create Attendance Button
            ElevatedButton.icon(
              onPressed: () => controller.createAttendance(),
              icon: Icon(Icons.check, color: Colors.white),
              label: Text("Create Attendance"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
