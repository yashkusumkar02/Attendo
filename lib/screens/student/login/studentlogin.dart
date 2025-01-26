import 'package:attendo/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/student_controller/student_login_controller/studentlogin_controller.dart';
import '../../roleselection/role_selection_screen.dart';
import '../signuop/studentsignup.dart';

class StudentLoginScreen extends StatelessWidget {
  final StudentLoginController controller = Get.put(StudentLoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFE),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Set this to min
                  children: [
                    SizedBox(height: 50), // For spacing from the top

                    // Row for Back Button and Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                        // Spacer to push the "Student" text to the center
                        Spacer(), // This will take up the remaining space between the icon and the text
                        Text(
                          "Student",
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Spacer(), // This will ensure that the "Student" text is truly centered horizontally
                      ],
                    ),

                    SizedBox(height: 20),

                    // Image in the center, slightly below the center
                    Align(
                      alignment: Alignment.center,
                      child: Image.asset(
                        'assets/images/login.png', // Replace with the actual path
                        height: 300,
                        width: 300, // Reduced height to allow space for login elements
                      ),
                    ),

                    SizedBox(height: 30),
                    Text(
                      "Hey ! Login in to \nAttendo",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 70),

                    // Email input field
                    TextFormField(
                      onChanged: (value) => controller.email.value = value,
                      decoration: InputDecoration(
                        labelText: 'Email',
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
                        hintText: 'Enter your Email...',
                      ),
                    ),
                    SizedBox(height: 15),

                    // Password input field
                    TextFormField(
                      obscureText: true,
                      onChanged: (value) => controller.password.value = value,
                      decoration: InputDecoration(
                        labelText: 'Password',
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
                        hintText: 'Enter your Password...',
                      ),
                    ),
                    SizedBox(height: 15),
                    // Login Button
                    ElevatedButton(
                      onPressed: controller.login,
                      child: Text(
                        "Login with Student",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Get.bottomSheet(
                          Container(
                            height: MediaQuery.of(context).size.height * 0.6,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(25),
                                topRight: Radius.circular(25),
                              ),
                            ),
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 20),
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.black, width: 2),
                                        ),
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.close,
                                            color: Colors.black,
                                            size: 24,
                                          ),
                                          onPressed: () => Get.back(),
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: Column(
                                        children: [
                                          Image.asset(
                                            'assets/images/forgotpassword.png',
                                            height: 200,
                                            width: 200,
                                          ),
                                          SizedBox(height: 20),
                                          Text(
                                            'Forgot Password',
                                            style: GoogleFonts.poppins(
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            'Please enter your email address to receive a link\nfor resetting your password.',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 30),
                                    TextFormField(
                                      onChanged: (value) => controller.email.value = value,
                                      decoration: InputDecoration(
                                        labelText: 'Registered Email',
                                        labelStyle: GoogleFonts.poppins(color: Colors.grey),
                                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          borderSide: BorderSide(color: Colors.blue),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          borderSide: BorderSide(color: Colors.grey),
                                        ),
                                        hintText: 'Enter your registered email...',
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Align(
                                      alignment: Alignment.bottomCenter,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          controller.resetPassword();
                                          Get.back();
                                        },
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
                                          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(25),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          backgroundColor: Colors.white,
                          isScrollControlled: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25),
                            ),
                          ),
                        );
                      },
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Forgot Password?",
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: Color(0xFF3E3F43), // Updated color code
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 60),

                    // Divider and "Don't have an account?" section
                    Divider(thickness: 1, color: Colors.grey[300]),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 5),
                        GestureDetector(
                          onTap: () {
                            Get.to(() => StudentRegistrationPage());
                          },
                          child: Text(
                            "Sign Up",
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
                    SizedBox(height: 20), // Padding at the bottom
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
