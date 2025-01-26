import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/teacher_controllers/teacher_signup_controller/teachersignup_controller.dart';
import '../../../routes/app_routes.dart';

class TeacherSignUpPage extends StatelessWidget {
  final TeacherSignUpController controller = Get.put(TeacherSignUpController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFE),
      body: GestureDetector(
        // Dismiss the keyboard when tapping outside
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                                      onPressed: () =>
                                          Get.offNamed(AppRoutes.roleSelection),
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    "Teacher Signup",
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
                              Center(
                                child: Image.asset(
                                  'assets/images/login.png', // Replace with your asset path
                                  height: 300,
                                  width: 300,
                                ),
                              ),
                              SizedBox(height: 30),
                              Center(
                                child: Text(
                                  "Hey ! Register in \nAttendo",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              SizedBox(height: 50),
                              TextFormField(
                                controller: controller.emailController,
                                onChanged: (value) =>
                                controller.email.value = value,
                                decoration: InputDecoration(
                                  labelText: 'Email',
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
                                  hintText: 'Enter your Email...',
                                ),
                              ),
                              SizedBox(height: 15),
                              TextFormField(
                                controller: controller.passwordController,
                                obscureText: true,
                                onChanged: (value) =>
                                controller.password.value = value,
                                decoration: InputDecoration(
                                  labelText: 'Password',
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
                                  hintText: 'Enter your Password...',
                                ),
                              ),
                              SizedBox(height: 15),
                              TextFormField(
                                controller: controller.confirmPasswordController,
                                obscureText: true,
                                onChanged: (value) =>
                                controller.confirmPassword.value = value,
                                decoration: InputDecoration(
                                  labelText: 'Confirm Password',
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
                                  hintText: 'Re-enter your Password...',
                                ),
                              ),
                              SizedBox(height: 30),
                              Center(
                                child: ElevatedButton(
                                  onPressed: () {
                                    controller.signUp(); // Call Firebase Signup
                                  },
                                  child: Text(
                                    "Sign-Up with Teacher",
                                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                  ),
                                ),
                              ),
                              SizedBox(height: 30),
                            ],
                          ),
                        ),
                        Spacer(),
                        Divider(thickness: 1, color: Colors.grey[300]),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account?",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(width: 5),
                            GestureDetector(
                              onTap: () {
                                Get.offNamed(AppRoutes.teacherLogin);
                              },
                              child: Text(
                                "Login",
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
                        SizedBox(height: 20),
                      ],
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
