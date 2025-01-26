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

                    /// 🔥 Email Input Field
                    TextFormField(
                      controller: controller.emailController, // ✅ Use Controller
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

                    /// 🔥 Password Input Field with Visibility Toggle
                    Obx(() => TextFormField(
                      controller: controller.passwordController, // ✅ Use Controller
                      obscureText: controller.isPasswordHidden.value, // 🔥 Toggle Visibility
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
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isPasswordHidden.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            controller.togglePasswordVisibility(); // 🔥 Toggle Action
                          },
                        ),
                      ),
                    )),
                    SizedBox(height: 15),

                    /// 🔥 Login Button
                    ElevatedButton(
                      onPressed: () {
                        print("📌 DEBUG: Login Button Pressed!");
                        if (controller.emailController.text.isEmpty ||
                            controller.passwordController.text.isEmpty) {
                          print("❌ ERROR: Fields are empty!");
                          Get.snackbar('Error', 'Please fill in all fields',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.redAccent,
                              colorText: Colors.white);
                        } else {
                          print("🚀 Proceeding with Login...");
                          controller.login(); // ✅ Calls Firebase Login
                        }
                      },
                      child: Text(
                        "Login with Teacher",
                        style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding:
                        EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                      ),
                    ),
                    SizedBox(height: 15),

                    /// 🔥 Forgot Password Link
                    GestureDetector(
                      onTap: () {
                        controller.resetPassword();
                      },
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Forgot Password?",
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: Color(0xFF3E3F43),
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 60),

                    /// 🔥 Sign Up Redirection
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
