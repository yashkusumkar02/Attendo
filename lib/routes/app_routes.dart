class AppRoutes {
  static const String splash = '/';
  static const String roleSelection = '/role-selection';

  // Authentication Routes
  static const String teacherLogin = '/teacher-login';
  static const String studentLogin = '/student-login';
  static const String forgotPassword = '/forgot-password';
  static const String teacherSignUp = '/teacher-signup';
  static const String studentSignup = '/student-signup';

  // Details Screens
  static const String teacherDetails = '/teacher-details';
  static const String studentDetails = '/student-details';

  // Teacher Area
  static const String teacherDashboard = '/teacher-dashboard';
  static const String createClassroom = '/create-classroom';
  static const String classroomDetails = '/classroom-details'; // ✅ Added here
  static const String classsroomDetails = '/classsroom-details'; // ✅ Added here
  static const String createClass = '/create-class';

  // Student Area
  static const String studentDashboard = '/student-dashboard';
  static const String joinClassroom = '/join-classroom';
  static const String studentAttendanceDetails = '/student-attendance-details';
  static const String studentClassDetails = '/student-class-details';
  static const String attendanceVerification = '/attendance-verification';
  static const String cameraScreen = '/camera-screen';

  // Attendance Management
  static const String searchStudentAttendance = '/search-student-attendance';
  static const String presentStudentList = '/present-student-list';
}
