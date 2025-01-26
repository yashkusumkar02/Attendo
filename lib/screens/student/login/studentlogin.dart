import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/student_controller/student_login_controller/studentlogin_controller.dart';

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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 50),
                    _buildHeader(),
                    SizedBox(height: 20),
                    _buildLoginImage(),
                    SizedBox(height: 30),
                    _buildTitle(),
                    SizedBox(height: 70),
                    _buildEmailInput(),
                    SizedBox(height: 15),
                    _buildPasswordInput(),
                    SizedBox(height: 15),
                    _buildLoginButton(),
                    SizedBox(height: 20),
                    _buildForgotPassword(),
                    SizedBox(height: 60),
                    Divider(thickness: 1, color: Colors.grey[300]),
                    SizedBox(height: 10),
                    _buildSignUpOption(),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ✅ Header with Back Button and Title
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_circle_left_outlined, size: 40),
          onPressed: () => Get.offNamed('/role-selection'),
        ),
        Spacer(),
        Text(
          "Student",
          style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        Spacer(),
      ],
    );
  }

  // ✅ Login Image
  Widget _buildLoginImage() {
    return Align(
      alignment: Alignment.center,
      child: Image.asset('assets/images/login.png', height: 300, width: 300),
    );
  }

  // ✅ Title
  Widget _buildTitle() {
    return Text(
      "Hey ! Login in to \nAttendo",
      textAlign: TextAlign.center,
      style: GoogleFonts.poppins(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
    );
  }

  // ✅ Email Input Field
  Widget _buildEmailInput() {
    return TextFormField(
      controller: controller.emailController,
      decoration: _inputDecoration('Email', 'Enter your Email...'),
    );
  }

  // ✅ Password Input Field
  Widget _buildPasswordInput() {
    return TextFormField(
      controller: controller.passwordController,
      obscureText: true,
      decoration: _inputDecoration('Password', 'Enter your Password...'),
    );
  }

  // ✅ Login Button with Loading State
  Widget _buildLoginButton() {
    return Obx(() => ElevatedButton(
      onPressed: controller.isLoading.value ? null : controller.login,
      child: controller.isLoading.value
          ? CircularProgressIndicator(color: Colors.white)
          : Text(
        "Login with Student",
        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.amber,
        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
    ));
  }

  // ✅ Forgot Password Section
  Widget _buildForgotPassword() {
    return GestureDetector(
      onTap: controller.resetPassword,
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
    );
  }

  // ✅ Signup Section
  Widget _buildSignUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Don't have an account?", style: GoogleFonts.poppins(fontSize: 16, color: Colors.black)),
        SizedBox(width: 5),
        GestureDetector(
          onTap: () => Get.toNamed('/student-signup'),
          child: Text(
            "Sign Up",
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.amber, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
          ),
        ),
      ],
    );
  }

  // ✅ Custom Input Decoration
  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(color: Colors.grey),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      border: OutlineInputBorder(),
      hintText: hint,
    );
  }
}
