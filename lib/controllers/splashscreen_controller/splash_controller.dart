import 'package:get/get.dart';
import '../../routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 5)); // Delay for 3 seconds
    Get.offNamed(AppRoutes.roleSelection); // Navigate to Role Selection Screen
  }
}
