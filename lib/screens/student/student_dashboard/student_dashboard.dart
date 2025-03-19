import 'dart:typed_data';
import 'package:attendo/controllers/student_controller/student_dashboard_controller/student_controller.dart';
import 'package:attendo/routes/app_routes.dart';
import 'package:attendo/screens/student/StudentProfileScreen/StudentProfileScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';

class StudentDashboard extends StatelessWidget {
  final StudentDashboardController controller = Get.put(StudentDashboardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(() => Text(
              "Welcome, ${controller.studentName.value}",
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            )),
            GestureDetector(
              onTap: () async {
                await Get.to(() => StudentProfileScreen());
                controller.fetchStudentData(); // ✅ Fetch latest profile data after returning
              },
              child: Obx(() {
                return CircleAvatar(
                  backgroundImage: controller.profileImage.value.isNotEmpty
                      ? MemoryImage(Uint8List.fromList(base64Decode(controller.profileImage.value)))
                      : AssetImage("assets/images/teacher_profile.png") as ImageProvider, // ✅ Default image if missing
                );
              }),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.fetchStudentData(); // ✅ Fix async call
          await controller.fetchJoinedClassrooms();
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.toNamed(AppRoutes.joinClassroom);
                  },
                  icon: Icon(Icons.add, color: Colors.white),
                  label: Text("Join Classroom",
                      style: GoogleFonts.poppins(fontSize: 16, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text("Joined Classrooms",
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),

              Expanded(
                child: Obx(() => controller.joinedClassrooms.isEmpty
                    ? Center(child: Text("No joined classrooms", style: GoogleFonts.poppins(fontSize: 16)))
                    : RefreshIndicator(
                  onRefresh: () async {
                    await controller.fetchStudentData();
                    await controller.fetchJoinedClassrooms();
                  },
                  child: ListView.builder(
                    physics: AlwaysScrollableScrollPhysics(),
                    itemCount: controller.joinedClassrooms.length,
                    itemBuilder: (context, index) {
                      var classroom = controller.joinedClassrooms[index];

                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(classroom["className"],
                                  style: GoogleFonts.poppins(
                                      fontSize: 18, fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Text("Class Code: ${classroom["classId"]}",
                                  style: GoogleFonts.poppins(fontSize: 14)),
                              Text("Teacher: ${classroom["teacher"]}",
                                  style: GoogleFonts.poppins(fontSize: 14)),
                              Text("Semester: ${classroom["semester"]}  |  Year: ${classroom["year"]}",
                                  style: GoogleFonts.poppins(fontSize: 14)),

                              SizedBox(height: 10),

                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () {
                                    Get.toNamed(
                                      AppRoutes.studentClassDetails,
                                      arguments: {
                                        "classId": classroom["classId"],
                                        "className": classroom["className"],
                                      },
                                    );
                                  },
                                  child: Text("Next", style: GoogleFonts.poppins(fontSize: 16, color: Colors.white)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
