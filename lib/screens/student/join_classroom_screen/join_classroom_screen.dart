import 'package:attendo/controllers/student_controller/join_classroom_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class JoinClassroomScreen extends StatelessWidget {
  final JoinClassroomController controller = Get.put(JoinClassroomController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Join Classroom", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: controller.searchController,
              decoration: InputDecoration(
                labelText: "Search by classroom name",
                border: OutlineInputBorder(),
              ),
              onChanged: controller.filterClassrooms,
            ),
            SizedBox(height: 20),
            Expanded(
              child: Obx(() => ListView.builder(
                itemCount: controller.filteredClassrooms.length,
                itemBuilder: (context, index) {
                  var classroom = controller.filteredClassrooms[index];

                  return Card(
                    child: ListTile(
                      title: Text("${classroom['name']}", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Teacher: ${classroom['teacher']}", style: GoogleFonts.poppins(fontSize: 14)),
                          Text("Semester: ${classroom['semester']}", style: GoogleFonts.poppins(fontSize: 14)),
                          Text("Branch: ${classroom['branch']}", style: GoogleFonts.poppins(fontSize: 14)),
                          Text("Year: ${classroom['year']}", style: GoogleFonts.poppins(fontSize: 14)),
                        ],
                      ),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue, // ✅ Button stays blue
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        onPressed: () {
                          _showJoinDialog(context, classroom["classId"]); // ✅ Use `classId` as classCode
                        },
                        child: Text("Join", style: GoogleFonts.poppins(fontSize: 16, color: Colors.white)), // ✅ White font
                      ),
                    ),
                  );
                },
              )),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Show Join Dialog (No extra argument needed)
  void _showJoinDialog(BuildContext context, String classCode) {
    final TextEditingController codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Enter Class Code", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: codeController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: InputDecoration(labelText: "Class Code"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: GoogleFonts.poppins(fontSize: 16)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, // ✅ Button stays blue
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            onPressed: () async {
              String enteredCode = codeController.text.trim();

              if (enteredCode.isEmpty || enteredCode.length != 6) {
                Get.snackbar("Error", "Class code must be exactly 6 digits!", snackPosition: SnackPosition.BOTTOM);
                return;
              }

              // ✅ Fix: Pass only one argument
              bool isValid = await Get.find<JoinClassroomController>().validateClassCode(enteredCode);
              if (isValid) {
                await Get.find<JoinClassroomController>().joinClassroom(enteredCode);
                Navigator.pop(context);
              }
            },
            child: Text("Join", style: GoogleFonts.poppins(fontSize: 16, color: Colors.white)), // ✅ Keep text white
          ),
        ],
      ),
    );
  }
}
