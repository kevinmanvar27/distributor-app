// Home Controller
// 
// Manages home screen data from /home API ONLY.
// Uses Homepage model with:
// - categories (displayed as icons)
// - featuredProducts (Featured Products section)
// - latestProducts (Latest Products section)

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../models/home_data.dart';

class HomeController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  
  // Home data from /home API
  final Rx<HomepageData?> homeData = Rx<HomepageData?>(null);
  
  // Categories list
  final RxList<HomeCategory> categories = <HomeCategory>[].obs;
  
  // Featured products list
  final RxList<HomeProduct> featuredProducts = <HomeProduct>[].obs;
  
  // Latest products list
  final RxList<HomeProduct> latestProducts = <HomeProduct>[].obs;
  
  // Loading & error states
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    debugPrint('HomeController: onInit called');
    loadHomeData();
  }
  
  /// Load home data from /home API ONLY
  Future<void> loadHomeData() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      debugPrint('HomeController: Loading data from /home API...');
      
      final response = await _apiService.get('/home');
      
      debugPrint('HomeController: /home API response status: ${response.statusCode}');
      
      if (response.statusCode == 200 && response.data != null) {
        // Parse the response using Homepage model
        final homepage = Homepage.fromJson(response.data);
        
        if (homepage.success) {
          homeData.value = homepage.data;
          
          // Update categories list
          categories.assignAll(homepage.data.categories);
          debugPrint('HomeController: Loaded ${categories.length} categories');
          
          // Update featured products list
          featuredProducts.assignAll(homepage.data.featuredProducts);
          debugPrint('HomeController: Loaded ${featuredProducts.length} featured products');
          
          // Update latest products list
          latestProducts.assignAll(homepage.data.latestProducts);
          debugPrint('HomeController: Loaded ${latestProducts.length} latest products');
          
        } else {
          throw Exception(homepage.message.isNotEmpty ? homepage.message : 'Failed to load home data');
        }
        
      } else {
        throw Exception('Failed to load home data: Status ${response.statusCode}');
      }
      
    } catch (e) {
      debugPrint('HomeController: Error loading home data: $e');
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
      debugPrint('HomeController: isLoading set to false');
    }
  }
  
  /// Refresh home data (pull-to-refresh)
  Future<void> refreshHomeData() async {
    await loadHomeData();
  }
  
  /// Check if home has any content
  bool get hasContent => 
      categories.isNotEmpty || 
      featuredProducts.isNotEmpty || 
      latestProducts.isNotEmpty;
}
