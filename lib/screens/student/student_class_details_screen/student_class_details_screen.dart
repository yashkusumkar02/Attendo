import 'package:attendo/controllers/student_controller/student_class_details_controller/student_class_details_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentClassDetailsScreen extends StatelessWidget {
  final StudentClassDetailsController controller = Get.put(StudentClassDetailsController());

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
          title: Obx(() => Text(
            controller.className.value,
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          )),
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
            _buildStudentsTab(),
          ],
        ),
      ),
    );
  }

  /// 📌 CLASS TAB (Attendance, Live & Previous Classes)
  Widget _buildClassTab() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => Text("Teacher: ${controller.teacherName.value}",
              style: GoogleFonts.poppins(fontSize: 16))),
          Obx(() => Text("Semester: ${controller.semester.value}",
              style: GoogleFonts.poppins(fontSize: 16))),
          Obx(() => Text("Year: ${controller.year.value}",
              style: GoogleFonts.poppins(fontSize: 16))),

          SizedBox(height: 20),

          Text("Live Classes", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Obx(() => controller.liveClasses.isEmpty
              ? Text("No live classes", style: GoogleFonts.poppins(fontSize: 14))
              : Column(
            children: controller.liveClasses.map((liveClass) => _liveClassTile(liveClass)).toList(),
          )),

          SizedBox(height: 20),

          Text("Previous Classes", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Obx(() => controller.previousClasses.isEmpty
              ? Text("No previous classes", style: GoogleFonts.poppins(fontSize: 14))
              : Column(
            children: controller.previousClasses.map((prevClass) => _previousClassTile(prevClass)).toList(),
          )),
        ],
      ),
    );
  }

  /// ✅ STUDENTS TAB (Fetch Student List from Firestore)
  Widget _buildStudentsTab() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Obx(() {
        if (controller.studentsList.isEmpty) {
          return Center(
            child: Text(
              "No students joined yet.",
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: controller.studentsList.length,
          itemBuilder: (context, index) {
            var student = controller.studentsList[index];
            return _studentCard(student["name"], student["status"]);
          },
        );
      }),
    );
  }

  /// ✅ LIVE CLASS CARD (Displays Class Timing)
  Widget _liveClassTile(Map<String, dynamic> liveClass) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: ListTile(
        title: Text(
          liveClass["title"] ?? "Unknown Timing",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Start Time: ${liveClass["startTime"]}", style: GoogleFonts.poppins(fontSize: 14)),
            Text("End Time: ${liveClass["endTime"]}", style: GoogleFonts.poppins(fontSize: 14)),
            Text("Location: ${liveClass["location"]}", style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
          ],
        ),
        trailing: Obx(() => controller.isAttendanceMarked.value
            ? Text(
          "Attendance Marked ✅",
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        )
            : SizedBox(
          width: 140,
          height: 40,
          child: ElevatedButton(
            onPressed: () {
              final classController = Get.find<StudentClassDetailsController>();
              classController.navigateToAttendanceVerification(); // ✅ Redirect to verification
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: Text("Take Attendance", style: TextStyle(fontSize: 14, color: Colors.white)),
          ),
        )),
      ),
    );
  }


  /// ✅ PREVIOUS CLASS CARD
  Widget _previousClassTile(Map<String, dynamic> prevClass) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: ListTile(
        title: Text(prevClass["title"], style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        subtitle: Text(prevClass["location"], style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
        trailing: Text(prevClass["date"], style: GoogleFonts.poppins(fontSize: 14, color: Colors.black)),
      ),
    );
  }

  /// ✅ STUDENT CARD (For Student List)
  Widget _studentCard(String name, String status) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: ListTile(
        title: Text(name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: status == "Present" ? Colors.green : Colors.red,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            status,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
