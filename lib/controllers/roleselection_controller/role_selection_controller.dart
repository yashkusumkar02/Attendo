import 'package:get/get.dart';
import '../../routes/app_routes.dart';

class RoleSelectionController extends GetxController {
  void navigateToTeacherLogin() {
    // Navigate to Teacher Login Screen
    Get.toNamed(AppRoutes.teacherLogin);
  }

  void navigateToStudentLogin() {
    // Navigate to Student Login Screen
    Get.toNamed(AppRoutes.studentLogin);
  }
}
