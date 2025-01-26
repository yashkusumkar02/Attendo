import 'package:attendo/models/custom_textfield.dart';
import 'package:attendo/routes/app_routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'dart:math';

class CreateClassroomScreen extends StatefulWidget {
  @override
  _CreateClassroomScreenState createState() => _CreateClassroomScreenState();
}

class _CreateClassroomScreenState extends State<CreateClassroomScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController classIdController = TextEditingController();

  String? selectedCollege;
  String? selectedBranch;
  String? selectedYear;
  String? selectedSemester;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Predefined lists for dropdown options
  List<String> collegeList = [];
  List<String> branchList = ["CSE", "IT", "ECE", "EEE", "ME", "Civil"];
  List<String> yearList = ["1st Year", "2nd Year", "3rd Year", "4th Year"];
  List<String> semesterList = ["1st Sem", "2nd Sem", "3rd Sem", "4th Sem", "5th Sem", "6th Sem", "7th Sem", "8th Sem"];

  @override
  void initState() {
    super.initState();
    _fetchTeacherCollege();
    _generateClassId(); // Auto-generate Class ID
  }

  // ✅ Fetch Teacher's College from Firestore
  Future<void> _fetchTeacherCollege() async {
    String teacherId = _auth.currentUser!.uid;
    var teacherDoc = await _db.collection("users").doc(teacherId).get();
    if (teacherDoc.exists) {
      setState(() {
        selectedCollege = teacherDoc.data()?["college"];
        collegeList = [selectedCollege!]; // Only show teacher's assigned college
      });
    }
  }

  // ✅ Generate Unique Class ID
  void _generateClassId() {
    String classId = Random().nextInt(1000000).toString().padLeft(6, '0');
    classIdController.text = classId;
  }

  // ✅ Save Class Data to Firestore
  void _createClassroom() async {
    String teacherId = _auth.currentUser!.uid;
    String className = nameController.text.trim();

    if (className.isEmpty || selectedCollege == null || selectedBranch == null || selectedYear == null || selectedSemester == null) {
      Get.snackbar("Error", "Please fill all fields!",
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    try {
      await _db.collection("classrooms").doc(classIdController.text).set({
        "teacherId": teacherId,
        "name": className,
        "college": selectedCollege,
        "branch": selectedBranch,
        "year": selectedYear,
        "semester": selectedSemester,
        "classId": classIdController.text, // Store Class ID
        "createdAt": FieldValue.serverTimestamp(),
      });

      Get.snackbar("Success", "Classroom Created Successfully!",
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);

      Get.offAllNamed(AppRoutes.teacherDashboard); // ✅ Redirect to Teacher Dashboard

    } catch (e) {
      Get.snackbar("Error", "Failed to create classroom: $e",
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

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
          "Create Classroom",
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: ElevatedButton.icon(
              onPressed: _createClassroom, // ✅ Call function to create class
              icon: Icon(Icons.add, color: Colors.white, size: 18),
              label: Text(
                "Create",
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView( // ✅ Prevents Overflow Issues
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            CustomTextField(controller: nameController, hintText: "Enter Class Name"),
            SizedBox(height: 10),

            // ✅ Auto-Generated Class ID
            CustomTextField(controller: classIdController, hintText: "Class ID (Auto-generated)", readOnly: true),
            SizedBox(height: 10),

            // ✅ College Dropdown (Disabled, Auto-Fetched)
            _buildDropdown(
              label: "College",
              value: selectedCollege,
              items: collegeList,
              onChanged: null, // Disabled since it's auto-filled
            ),
            SizedBox(height: 10),

            // ✅ Branch Dropdown
            _buildDropdown(
              label: "Branch",
              value: selectedBranch,
              items: branchList,
              onChanged: (value) => setState(() => selectedBranch = value),
            ),
            SizedBox(height: 10),

            // ✅ Year Dropdown
            _buildDropdown(
              label: "Year",
              value: selectedYear,
              items: yearList,
              onChanged: (value) => setState(() => selectedYear = value),
            ),
            SizedBox(height: 10),

            // ✅ Semester Dropdown
            _buildDropdown(
              label: "Semester",
              value: selectedSemester,
              items: semesterList,
              onChanged: (value) => setState(() => selectedSemester = value),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ✅ Custom Dropdown Widget (Fixed Overflow Issue)
  Widget _buildDropdown({required String label, String? value, required List<String> items, required ValueChanged<String?>? onChanged}) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9), // ✅ Prevents overflow
      child: DropdownButtonFormField<String>(
        value: value,
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(
              item,
              overflow: TextOverflow.ellipsis, // ✅ Prevents long text overflow
              style: GoogleFonts.poppins(fontSize: 16),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12), // ✅ Adjust padding to prevent overflow
        ),
        isExpanded: true, // ✅ Fixes overflow issue
      ),
    );
  }
}
