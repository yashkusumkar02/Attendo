import 'package:attendo/controllers/teacher_controllers/student_list_controller/student_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentListScreen extends StatelessWidget {
  final StudentListController controller = Get.put(StudentListController());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: controller.searchController,
            decoration: InputDecoration(
              hintText: "Search student by name...",
              hintStyle: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
              filled: true,
              fillColor: Colors.grey.shade100,
              prefixIcon: Icon(Icons.search, color: Colors.blue),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            style: GoogleFonts.poppins(fontSize: 16),
          ),
          SizedBox(height: 20),

          // Student List (Filtered dynamically)
          Expanded(
            child: Obx(() => controller.filteredStudents.isEmpty
                ? Center(
                child: Text("No Students Found", style: GoogleFonts.poppins(fontSize: 16)))
                : ListView.builder(
              itemCount: controller.filteredStudents.length,
              itemBuilder: (context, index) {
                var student = controller.filteredStudents[index];
                return StudentTile(
                  studentId: student["id"],
                  studentName: student["name"],
                  studentDetails: student["details"],
                  status: student["status"],
                  onTap: () => controller.goToStudentDetails(student["id"]),
                );
              },
            )),
          ),
        ],
      ),
    );
  }
}

// Student List Tile
class StudentTile extends StatelessWidget {
  final int studentId;
  final String studentName;
  final String studentDetails;
  final String status;
  final VoidCallback onTap;

  StudentTile({
    required this.studentId,
    required this.studentName,
    required this.studentDetails,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Icon(Icons.person, color: Colors.blue),
        ),
        title: Text(studentName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        subtitle: Text(studentDetails, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: status == "Present" ? Colors.green : Colors.red,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(status, style: GoogleFonts.poppins(fontSize: 14, color: Colors.white)),
        ),
        onTap: onTap,
      ),
    );
  }
}
