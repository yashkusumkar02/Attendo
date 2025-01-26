import 'package:attendo/routes/app_routes.dart';
import 'package:attendo/screens/roleselection/role_selection_screen.dart';
import 'package:attendo/screens/splashscreen/splashscreen.dart';
import 'package:attendo/screens/student/attendance_verification_screen/attendance_verification_screen.dart';
import 'package:attendo/screens/student/camera_screen/camera_screen.dart';
import 'package:attendo/screens/student/join_classroom_screen/join_classroom_screen.dart';
import 'package:attendo/screens/student/login/studentlogin.dart';
import 'package:attendo/screens/student/signuop/studentsignup.dart';
import 'package:attendo/screens/student/student_class_details_screen/student_class_details_screen.dart';
import 'package:attendo/screens/student/student_dashboard/student_dashboard.dart';
import 'package:attendo/screens/student/student_details/student_details.dart';
import 'package:attendo/screens/teacher/ClassroomDetailsScreen/ClassroomDetailsScreen.dart';
import 'package:attendo/screens/teacher/classroom_details_screen/classroom_details_screen.dart';
import 'package:attendo/screens/teacher/create_class_screen/create_class_screen.dart';
import 'package:attendo/screens/teacher/create_classroom_screen/create_classroom_screen.dart';
import 'package:attendo/screens/teacher/login/teacherlogin.dart';
import 'package:attendo/screens/teacher/signup/teachersignup.dart';
import 'package:attendo/screens/teacher/student_attendance_details_screen/student_attendance_details_screen.dart';
import 'package:attendo/screens/teacher/teacher_details/teacher_details.dart';
import 'package:attendo/screens/teacher/teacher_home_screen/teacher_home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GeolocatorPlatform.instance.isLocationServiceEnabled();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Attendo',
      home: AuthCheck(), // ✅ Auto-redirects based on login status
      getPages: [
        GetPage(name: AppRoutes.splash, page: () => SplashScreen()),
        GetPage(name: AppRoutes.roleSelection, page: () => const RoleSelectionScreen()),

        // Authentication
        GetPage(name: AppRoutes.teacherLogin, page: () => TeacherLoginScreen()),
        GetPage(name: AppRoutes.teacherSignUp, page: () => TeacherSignUpPage()),
        GetPage(name: AppRoutes.studentLogin, page: () => StudentLoginScreen()),
        GetPage(name: AppRoutes.studentSignup, page: () => StudentRegistrationPage()),

        // Details Screens
        GetPage(
          name: AppRoutes.teacherDetails,
          page: () => TeacherDetailsPage(),
        ),
        GetPage(
          name: AppRoutes.studentDetails,
          page: () {
            final args = Get.arguments as Map<String, dynamic>?;
            if (args == null || !args.containsKey("studentId")) {
              return Scaffold(body: Center(child: Text("Error: Student ID missing")));
            }
            return StudentProfilePage(studentId: args["studentId"]);
          },
        ),

        // Teacher Area
        GetPage(name: AppRoutes.teacherDashboard, page: () => TeacherDashboard()),
        GetPage(name: AppRoutes.createClassroom, page: () => CreateClassroomScreen()),
        GetPage(
          name: AppRoutes.classroomDetails,
          page: () {
            final args = Get.arguments as Map<String, dynamic>?;
            if (args == null || !args.containsKey("classId")) {
              return Scaffold(body: Center(child: Text("Error: No classroom data received")));
            }
            return ClassroomDetailsScreen(classId: args["classId"]);
          },
        ),
        GetPage(name: AppRoutes.createClass, page: () => CreateClassScreen(classId: '',)),
        GetPage(name: AppRoutes.studentAttendanceDetails, page: () => StudentAttendanceDetailsScreen()),
        GetPage(name: AppRoutes.classsroomDetails, page: () => ClassroomDetaillsScreen()),

        // Student Area
        GetPage(name: AppRoutes.studentDashboard, page: () => StudentDashboard()),
        GetPage(name: AppRoutes.joinClassroom, page: () => JoinClassroomScreen()),
        GetPage(name: AppRoutes.studentClassDetails, page: () => StudentClassDetailsScreen()),
        GetPage(name: AppRoutes.attendanceVerification, page: () => AttendanceVerificationScreen()),
        GetPage(name: AppRoutes.cameraScreen, page: () => CameraScreen()),
      ],
    );
  }
}

// ✅ Auto Redirect Based on Login Status
class AuthCheck extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          return FutureBuilder(
            future: getUserRole(snapshot.data!.uid),
            builder: (context, AsyncSnapshot<String?> roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  backgroundColor: Colors.white,
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              if (roleSnapshot.hasError || roleSnapshot.data == null) {
                return RoleSelectionScreen(); // Redirect to role selection if error
              }
              if (roleSnapshot.data == "teacher") {
                return TeacherDashboard(); // Redirect to Teacher Dashboard
              } else {
                return StudentDashboard(); // Redirect to Student Dashboard
              }
            },
          );
        }
        return SplashScreen(); // Default screen (login/signup)
      },
    );
  }
}

// ✅ Fetch User Role from Firestore
// ✅ Fetch User Role from Firestore based on UID
Future<String?> getUserRole(String uid) async {
  try {
    // 🔍 Check if the user exists in the "students" collection
    var studentDoc = await FirebaseFirestore.instance.collection("students").doc(uid).get();
    if (studentDoc.exists) {
      return "student"; // ✅ User is a student
    }

    // 🔍 Check if the user exists in the "teachers" collection
    var teacherDoc = await FirebaseFirestore.instance.collection("teachers").doc(uid).get();
    if (teacherDoc.exists) {
      return "teacher"; // ✅ User is a teacher
    }

    return null; // ❌ No role found, user is not registered properly
  } catch (e) {
    print("Error fetching role: $e");
    return null;
  }
}

