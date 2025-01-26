import 'package:attendo/screens/roleselection/role_selection_screen.dart';
import 'package:attendo/screens/splashscreen/splashscreen.dart';
import 'package:attendo/screens/student/login/studentlogin.dart';
import 'package:attendo/screens/student/signuop/studentsignup.dart';
import 'package:attendo/screens/student/student_details/student_details.dart';
import 'package:attendo/screens/teacher/login/teacherlogin.dart';
import 'package:attendo/screens/teacher/signup/teachersignup.dart';
import 'package:attendo/screens/teacher/teacher_details/teacher_details.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes/app_routes.dart'; // Placeholder for Role Selection

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Attendo',
      initialRoute: AppRoutes.splash,
      getPages: [
        GetPage(name: AppRoutes.splash, page: () => SplashScreen()),
        GetPage(name: AppRoutes.roleSelection, page: () => const RoleSelectionScreen()),// Placeholder
        GetPage(name: AppRoutes.teacherLogin, page: ()=> TeacherLoginScreen()),
        GetPage(name: AppRoutes.teacherSignUp, page: ()=> TeacherSignUpPage()),
        GetPage(name: AppRoutes.studentLogin, page: ()=> StudentLoginScreen()),
        GetPage(name: AppRoutes.studentSignup, page: ()=> StudentRegistrationPage()),
        GetPage(name: AppRoutes.teacherDetails, page: () => TeacherDetailsPage()),
        GetPage(name: AppRoutes.studentDetails, page: () => StudentProfilePage()),

      ],
    );
  }
}