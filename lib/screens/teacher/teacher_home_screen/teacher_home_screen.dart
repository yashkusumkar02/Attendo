import 'package:attendo/controllers/teacher_controllers/teacher_home_controller/teacher_home_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TeacherDashboard extends StatelessWidget {
  final TeacherDashboardController controller = Get.put(TeacherDashboardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Teacher Dashboard",
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == "logout") {
                  FirebaseAuth.instance.signOut();
                  Get.offAllNamed('/teacher-login'); // ✅ Redirect to login after logout
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: "logout",
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 10),
                      Text("Logout", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
              child: CircleAvatar(
                backgroundImage: AssetImage("assets/images/teacher_profile.png"), // Replace with actual image
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(child: CircularProgressIndicator());
                }

                if (controller.classrooms.isEmpty) {
                  return Center(
                    child: Text(
                      "No Classrooms Found.\nCreate one to get started!",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: controller.classrooms.length,
                  itemBuilder: (context, index) {
                    var classroom = controller.classrooms[index];
                    return ClassroomTile(
                      title: classroom.name,
                      description:
                      "${classroom.college} • ${classroom.branch} • ${classroom.semester} Sem • ${classroom.year} Year",
                      onTap: () {
                        controller.openClassroom(classroom); // ✅ Navigates to Classroom Details
                      },
                    );
                  },
                );
              }),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed('/create-classroom'), // ✅ Navigates to Create Classroom
              icon: Icon(Icons.add, color: Colors.white),
              label: Text(
                "Create Classroom",
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ✅ Classroom Tile Widget
class ClassroomTile extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onTap;

  ClassroomTile({required this.title, required this.description, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: ListTile(
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          description,
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
        ),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: onTap, // ✅ Navigates to Classroom Details
      ),
    );
  }
}
