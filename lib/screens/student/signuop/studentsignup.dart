import 'package:attendo/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../controllers/student_controller/student_signup_controller/studentsignup_controller.dart';
import '../../roleselection/role_selection_screen.dart';

class StudentRegistrationPage extends StatelessWidget {
  final StudentRegistrationController controller =
  Get.put(StudentRegistrationController());

  // Predefined dropdown values
  final List<String> branches = [
    'Computer Science',
    'Information Technology',
    'Mechanical',
    'Electrical',
    'Civil',
    'Electronics & Communication',
  ];

  final List<String> semesters = [
    '1st Semester',
    '2nd Semester',
    '3rd Semester',
    '4th Semester',
    '5th Semester',
    '6th Semester',
    '7th Semester',
    '8th Semester',
  ];

  final List<String> years = [
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFE),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // Dismiss the keyboard
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                height: 40, // Set the desired height
                                width: 40,  // Set the desired width
                                child: IconButton(
                                  icon: Icon(
                                    Icons.arrow_circle_left_outlined,
                                    size: 40, // Adjust the icon size
                                  ),
                                  onPressed: () => Get.off(RoleSelectionScreen()), // Use GetX to navigate back
                                ),
                              ),
                              Spacer(),
                              Text(
                                "Student SignUp",
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Spacer(),
                            ],
                          ),
                          SizedBox(height: 20),
                          Center(
                            child: Column(
                              children: [
                                Image.asset(
                                  'assets/images/login.png', // Replace with your image path
                                  height: 200,
                                ),
                                SizedBox(height: 20),
                                Text(
                                  "Hey ! Login in to \nAttendo",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 30),
                                // Name Field
                                TextFormField(
                                  controller: controller.nameController,
                                  onChanged: (value) =>
                                  controller.name.value = value,
                                  decoration: InputDecoration(
                                    labelText: 'Name',
                                    labelStyle: GoogleFonts.poppins(
                                      color: Colors.grey,
                                    ),
                                    floatingLabelBehavior:
                                    FloatingLabelBehavior.auto,
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Colors.blue),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    hintText: 'Enter your full name...',
                                  ),
                                ),
                                SizedBox(height: 15),
                                // College Name Field
                                TextFormField(
                                  controller: controller.collegeNameController,
                                  onChanged: (value) =>
                                  controller.collegeName.value = value,
                                  decoration: InputDecoration(
                                    labelText: 'College Name',
                                    labelStyle: GoogleFonts.poppins(
                                      color: Colors.grey,
                                    ),
                                    floatingLabelBehavior:
                                    FloatingLabelBehavior.auto,
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Colors.blue),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    hintText: 'Enter your college name...',
                                  ),
                                ),
                                SizedBox(height: 15),
                                // Branch Dropdown
                                DropdownButtonFormField<String>(
                                  value: controller.branch.value.isNotEmpty
                                      ? controller.branch.value
                                      : null,
                                  onChanged: (value) =>
                                  controller.branch.value = value ?? '',
                                  items: branches
                                      .map((branch) => DropdownMenuItem<String>(
                                    value: branch,
                                    child: Text(branch),
                                  ))
                                      .toList(),
                                  decoration: InputDecoration(
                                    labelText: 'Branch',
                                    labelStyle: GoogleFonts.poppins(
                                      color: Colors.grey,
                                    ),
                                    floatingLabelBehavior:
                                    FloatingLabelBehavior.auto,
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Colors.blue),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 15),
                                // Semester Dropdown
                                DropdownButtonFormField<String>(
                                  value: controller.semester.value.isNotEmpty
                                      ? controller.semester.value
                                      : null,
                                  onChanged: (value) =>
                                  controller.semester.value = value ?? '',
                                  items: semesters
                                      .map((semester) =>
                                      DropdownMenuItem<String>(
                                        value: semester,
                                        child: Text(semester),
                                      ))
                                      .toList(),
                                  decoration: InputDecoration(
                                    labelText: 'Semester',
                                    labelStyle: GoogleFonts.poppins(
                                      color: Colors.grey,
                                    ),
                                    floatingLabelBehavior:
                                    FloatingLabelBehavior.auto,
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Colors.blue),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 15),
                                // Year Dropdown
                                DropdownButtonFormField<String>(
                                  value: controller.year.value.isNotEmpty
                                      ? controller.year.value
                                      : null,
                                  onChanged: (value) =>
                                  controller.year.value = value ?? '',
                                  items: years
                                      .map((year) => DropdownMenuItem<String>(
                                    value: year,
                                    child: Text(year),
                                  ))
                                      .toList(),
                                  decoration: InputDecoration(
                                    labelText: 'Year',
                                    labelStyle: GoogleFonts.poppins(
                                      color: Colors.grey,
                                    ),
                                    floatingLabelBehavior:
                                    FloatingLabelBehavior.auto,
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Colors.blue),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 30),
                                // Login Button
                                ElevatedButton(
                                  onPressed: () {
                                    Get.offNamed(AppRoutes.studentDetails); // Navigate to the Student Details page
                                  },
                                  child: Text(
                                    "Sign-Up with Student",
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white, // Text color
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFFEC107), // Button color
                                    minimumSize: Size(double.infinity, 50), // Button size
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25), // Rounded corners
                                    ),
                                  ),
                                ),
                                SizedBox(height: 15),
                                Divider(thickness: 1, color: Colors.grey[300]),
                                SizedBox(height: 15),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Already have an Account?",
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    GestureDetector(
                                      onTap: () {
                                        Get.toNamed(AppRoutes.studentLogin);
                                      },
                                      child: Text(
                                        "Login",
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          color: Colors.amber,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 50,),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
