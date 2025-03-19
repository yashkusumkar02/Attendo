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
import 'package:attendo/screens/teacher/student_list_screen/student_list_screen.dart';
import 'package:attendo/screens/teacher/teacher_details/teacher_details.dart';
import 'package:attendo/screens/teacher/teacher_home_screen/teacher_home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Permission.camera.request();

  // ✅ Remove setPersistence for Mobile (ONLY use for Web)
  if (kIsWeb) {
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  }

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
        GetPage(name: AppRoutes.studentList, page: () => StudentListScreen()),
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

        User? user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          return FutureBuilder<String?>(
            future: getUserRole(user.uid), // ✅ Get role from Firestore
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              if (roleSnapshot.hasError || roleSnapshot.data == null) {
                Get.snackbar("Error", "No role found! Please contact admin.", snackPosition: SnackPosition.BOTTOM);
                return RoleSelectionScreen(); // ❌ Redirect only after showing error
              }
              if (roleSnapshot.data == "teacher") {
                return TeacherDashboard(); // ✅ Redirect to teacher dashboard
              } else {
                return StudentDashboard(); // ✅ Redirect to student dashboard
              }
            },
          );
        }

        return RoleSelectionScreen(); // ❌ Default to role selection if not logged in
      },
    );
  }
}



// ✅ Fetch User Role from Firestore
// ✅ Improved User Role Fetching
Future<String?> getUserRole(String uid) async {
  try {
    print("🔍 Checking role for user: $uid");

    // 🔎 Check if user exists in "students" collection
    var studentDoc = await FirebaseFirestore.instance.collection("students").doc(uid).get();
    if (studentDoc.exists && studentDoc.data()?["role"] == "student") {
      print("✅ User is a STUDENT");
      return "student";
    }

    // 🔎 Check if user exists in "teachers" collection
    var teacherDoc = await FirebaseFirestore.instance.collection("teachers").doc(uid).get();
    if (teacherDoc.exists && teacherDoc.data()?["role"] == "teacher") {
      print("✅ User is a TEACHER");
      return "teacher";
    }

    print("❌ No role found in Firestore!");
    return null;
  } catch (e) {
    print("🔥 ERROR Fetching Role: $e");
    return null;
  }
}

// ✅ Save user role during signup
Future<void> saveUserRole(String uid, String email, String name, String role) async {
  try {
    await FirebaseFirestore.instance.collection(role == "teacher" ? "teachers" : "students").doc(uid).set({
      "name": name,
      "email": email,
      "role": role, // ✅ Ensure role is stored correctly
      "createdAt": FieldValue.serverTimestamp(),
    });
    print("✅ User role saved successfully!");
  } catch (e) {
    print("❌ Error saving user role: $e");
  }
}

