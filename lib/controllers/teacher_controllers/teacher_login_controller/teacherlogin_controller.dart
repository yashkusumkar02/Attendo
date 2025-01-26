import 'package:get/get.dart';

class TeacherLoginController extends GetxController {
  var email = ''.obs;
  var password = ''.obs;

  // Method for logging in
  void login() {
    if (email.value.isNotEmpty && password.value.isNotEmpty) {
      // Add your authentication logic here
      print("Logged in with email: ${email.value}, password: ${password.value}");
      Get.snackbar("Success", "Logged in successfully!",
          snackPosition: SnackPosition.BOTTOM);
    } else {
      Get.snackbar("Error", "Please fill in all fields.",
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // Method for navigating back (for use in the login screen)
  void navigateBack() {
    Get.back();
  }

  // Method for handling the password reset functionality
  void resetPassword() {
    if (email.value.isNotEmpty) {
      // Add your password reset logic here (e.g., send a reset email)
      // You could make a call to your API or use a service to handle this.
      print("Password reset request for email: ${email.value}");
      Get.snackbar('Success', 'Password reset link sent to ${email.value}',
          snackPosition: SnackPosition.BOTTOM);
    } else {
      Get.snackbar('Error', 'Please enter a valid email address.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
