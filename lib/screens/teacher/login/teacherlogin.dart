import 'package:attendo/routes/app_routes.dart';
import 'package:attendo/screens/roleselection/role_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/teacher_controllers/teacher_login_controller/teacherlogin_controller.dart';

class TeacherLoginScreen extends StatelessWidget {
  final TeacherLoginController controller = Get.put(TeacherLoginController());

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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 40,
                          width: 40,
                          child: IconButton(
                            icon: Icon(
                              Icons.arrow_circle_left_outlined,
                              size: 40,
                            ),
                            onPressed: () => Get.off(RoleSelectionScreen()),
                          ),
                        ),
                        Spacer(),
                        Text(
                          "Teacher",
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Spacer(),
                      ],
                    ),
                    SizedBox(height: 20),
                    Align(
                      alignment: Alignment.center,
                      child: Image.asset(
                        'assets/images/login.png',
                        height: 300,
                        width: 300,
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
                    ElevatedButton(
                      onPressed: () {
                        if (controller.email.isEmpty || controller.password.isEmpty) {
                          Get.snackbar('Error', 'Please fill in all fields');
                        } else {
                          controller.login();
                        }
                      },
                      child: Text(
                        "Login with Teacher",
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
                    SizedBox(height: 15),
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
                            Get.offNamed(AppRoutes.teacherSignUp);
                          },
                          child: Text(
                            "Sign Up",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
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
