// Splash Controller
// 
// Handles app initialization and authentication check on startup.
// Navigates to login or main screen based on auth state.

import 'package:get/get.dart';
import '../../core/services/storage_service.dart';

class SplashController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  
  final RxBool isLoading = true.obs;
  final RxString statusMessage = 'Initializing...'.obs;
  
  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }
  
  Future<void> _initializeApp() async {
    try {
      // Simulate minimum splash duration for branding
      await Future.delayed(const Duration(milliseconds: 1500));
      
      statusMessage.value = 'Checking authentication...';
      
      // Check if user is authenticated
      final isAuthenticated = _storageService.isAuthenticated();
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (isAuthenticated) {
        // User is logged in, navigate to main screen
        Get.offAllNamed('/main');
      } else {
        // User is not logged in, navigate to login
        Get.offAllNamed('/login');
      }
    } catch (e) {
      // On error, default to login screen
      Get.offAllNamed('/login');
    } finally {
      isLoading.value = false;
    }
  }
}
