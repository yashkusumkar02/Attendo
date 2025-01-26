import 'package:attendo/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/student_controller/student_signup_controller/studentsignup_controller.dart';
import '../../roleselection/role_selection_screen.dart';

class StudentRegistrationPage extends StatelessWidget {
  final StudentRegistrationController controller = Get.put(StudentRegistrationController());

  // Predefined dropdown values
  final List<String> branches = ['CSE', 'IT', 'ECE', 'EEE', 'ME', 'Civil'];
  final List<String> semesters = [
    '1st Sem', '2nd Sem', '3rd Sem', '4th Sem',
    '5th Sem', '6th Sem', '7th Sem', '8th Sem'
  ];
  final List<String> years = ['1st Year', '2nd Year', '3rd Year', '4th Year'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFE),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.arrow_circle_left_outlined, size: 40),
                                onPressed: () => Get.off(RoleSelectionScreen()),
                              ),
                              Spacer(),
                              Text("Student SignUp", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
                              Spacer(),
                            ],
                          ),
                          SizedBox(height: 20),
                          Center(
                            child: Column(
                              children: [
                                Image.asset('assets/images/login.png', height: 200),
                                SizedBox(height: 20),
                                Text("Hey! Login to Attendo", textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black)),
                                SizedBox(height: 30),

                                // ✅ Name Field
                                _textField(controller.nameController, 'Name', 'Enter your full name...'),
                                SizedBox(height: 15),

                                // ✅ Email Field
                                _textField(controller.emailController, 'Email', 'Enter your email...'),
                                SizedBox(height: 15),

                                // ✅ Password Field
                                _textField(controller.passwordController, 'Password', 'Enter your password...', isPassword: true),
                                SizedBox(height: 15),

                                // ✅ Confirm Password Field
                                _textField(controller.confirmPasswordController, 'Confirm Password', 'Re-enter your password...', isPassword: true),
                                SizedBox(height: 15),

                                // ✅ College Name Field
                                _textField(controller.collegeNameController, 'College Name', 'Enter your college name...'),
                                SizedBox(height: 15),

                                // ✅ Dropdown Fields
                                _dropdownField('Branch', branches, controller.branch),
                                SizedBox(height: 15),
                                _dropdownField('Semester', semesters, controller.semester),
                                SizedBox(height: 15),
                                _dropdownField('Year', years, controller.year),
                                SizedBox(height: 30),

                                // ✅ Sign-Up Button
                                ElevatedButton(
                                  onPressed: () => controller.submitRegistration(),
                                  child: Text("Sign-Up", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFFEC107),
                                    minimumSize: Size(double.infinity, 50),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                  ),
                                ),
                                SizedBox(height: 15),

                                Divider(thickness: 1, color: Colors.grey[300]),
                                SizedBox(height: 15),

                                // ✅ Already have an account?
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("Already have an Account?", style: GoogleFonts.poppins(fontSize: 16, color: Colors.black)),
                                    SizedBox(width: 5),
                                    GestureDetector(
                                      onTap: () => Get.toNamed(AppRoutes.studentLogin),
                                      child: Text("Login", style: GoogleFonts.poppins(fontSize: 16, color: Colors.amber, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 50),
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

  // ✅ Custom Text Field Widget
  Widget _textField(TextEditingController controller, String label, String hint, {bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.grey),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        border: OutlineInputBorder(),
        hintText: hint,
      ),
    );
  }

  // ✅ Custom Dropdown Widget
  Widget _dropdownField(String label, List<String> options, RxString controllerValue) {
    return DropdownButtonFormField<String>(
      value: controllerValue.value.isNotEmpty ? controllerValue.value : null,
      onChanged: (value) => controllerValue.value = value ?? '',
      items: options.map((item) => DropdownMenuItem<String>(value: item, child: Text(item))).toList(),
      decoration: InputDecoration(labelText: label, labelStyle: GoogleFonts.poppins(color: Colors.grey), border: OutlineInputBorder()),
    );
  }
}
