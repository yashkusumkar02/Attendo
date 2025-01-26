import 'package:attendo/controllers/teacher_controllers/teacher_details_controllers/teacherdetail_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../routes/app_routes.dart';

class TeacherDetailsPage extends StatelessWidget {
  final TeacherDetailController controller =
  Get.put(TeacherDetailController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFE),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // Dismiss the keyboard
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      height: 40,
                      width: 40,
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_circle_left_outlined,
                          size: 40,
                        ),
                        onPressed: () =>
                            Get.offNamed(AppRoutes.roleSelection),
                      ),
                    ),
                    Spacer(),
                    Text(
                      "Teacher Details",
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
                      Text(
                        "Please provide your personal details to proceed.",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.black54,
                          textBaseline: TextBaseline.alphabetic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 30),
                      Image.asset(
                        'assets/images/file_upload.png', // Replace with your image path
                        height: 200,
                      ),
                      SizedBox(height: 30),
                      TextFormField(
                        controller: controller.nameController,
                        onChanged: (value) => controller.name.value = value,
                        decoration: InputDecoration(
                          labelText: "Enter Name",
                          labelStyle: GoogleFonts.poppins(
                            color: Colors.grey,
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          hintText: "Enter your full name...",
                        ),
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: controller.collegeController,
                        onChanged: (value) => controller.college.value = value,
                        decoration: InputDecoration(
                          labelText: "Select College",
                          labelStyle: GoogleFonts.poppins(
                            color: Colors.grey,
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          hintText: "Enter your college name...",
                        ),
                      ),
                      SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: controller.submitRegistration,
                        child: Text(
                          "Submit",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
