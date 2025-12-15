// 
// Manages subcategories screen:
// - Displays subcategories of a parent category
// - Fetches products for each subcategory from API

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../models/home_data.dart';
import '../../models/product.dart';

class SubcategoriesController extends GetxController {
  // Parent category info
  final Rx<HomeCategory?> parentCategory = Rx<HomeCategory?>(null);
  
  // Subcategories list (from parent category)
  final RxList<HomeCategory> subcategories = <HomeCategory>[].obs;
  
  // Loading state
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    // Get category data from arguments
    final args = Get.arguments;
    if (args != null && args is HomeCategory) {
      parentCategory.value = args;
      subcategories.assignAll(args.subCategories ?? []);
      debugPrint('SubcategoriesController: Loaded ${subcategories.length} subcategories for ${args.name}');
    }
  }
  
  /// Navigate to subcategory products
  void goToSubcategoryProducts(HomeCategory subcategory) {
    Get.toNamed(
      '/subcategory-products/${subcategory.id}',
      arguments: subcategory,
    );
  }
}

/// Controller for subcategory products screen
class SubcategoryProductsController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  
  // Subcategory info
  final Rx<HomeCategory?> subcategory = Rx<HomeCategory?>(null);
  
  // Products list
  final RxList<Product> products = <Product>[].obs;
  
  // Loading & pagination state
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasMore = true.obs;
  
  int _currentPage = 1;
  static const int _pageSize = 20;
  
  @override
  void onInit() {
    super.onInit();
    // Get subcategory data from arguments
    final args = Get.arguments;
    if (args != null && args is HomeCategory) {
      subcategory.value = args;
      debugPrint('SubcategoryProductsController: Loading products for ${args.name} (ID: ${args.id})');
      loadProducts();
    }
  }
  
  /// Load products for this subcategory
  Future<void> loadProducts() async {
    if (subcategory.value == null) return;
    
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      _currentPage = 1;
      
      final response = await _apiService.get(
        '/subcategories/${subcategory.value!.id}/products',
        queryParameters: {
          'page': _currentPage,
          'per_page': _pageSize,
        },
      );
      
      debugPrint('SubcategoryProductsController: API response status: ${response.statusCode}');
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        
        // Parse products from response
        List<Product> loadedProducts = [];
        if (data['data'] != null && data['data'] is List) {
          loadedProducts = (data['data'] as List)
              .map((json) => Product.fromJson(json))
              .toList();
        } else if (data['products'] != null && data['products'] is List) {
          loadedProducts = (data['products'] as List)
              .map((json) => Product.fromJson(json))
              .toList();
        } else if (data is List) {
          loadedProducts = data.map((json) => Product.fromJson(json)).toList();
        }
        
        products.assignAll(loadedProducts);
        hasMore.value = loadedProducts.length >= _pageSize;
        
        debugPrint('SubcategoryProductsController: Loaded ${products.length} products');
      } else {
        throw Exception('Failed to load products: Status ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('SubcategoryProductsController: Error loading products: $e');
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Load more products (pagination)
  Future<void> loadMoreProducts() async {
    if (isLoadingMore.value || !hasMore.value || subcategory.value == null) return;
    
    try {
      isLoadingMore.value = true;
      _currentPage++;
      
      final response = await _apiService.get(
        '/subcategories/${subcategory.value!.id}/products',
        queryParameters: {
          'page': _currentPage,
          'per_page': _pageSize,
        },
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        
        List<Product> loadedProducts = [];
        if (data['data'] != null && data['data'] is List) {
          loadedProducts = (data['data'] as List)
              .map((json) => Product.fromJson(json))
              .toList();
        } else if (data['products'] != null && data['products'] is List) {
          loadedProducts = (data['products'] as List)
              .map((json) => Product.fromJson(json))
              .toList();
        } else if (data is List) {
          loadedProducts = data.map((json) => Product.fromJson(json)).toList();
        }
        
        products.addAll(loadedProducts);
        hasMore.value = loadedProducts.length >= _pageSize;
        
        debugPrint('SubcategoryProductsController: Loaded ${loadedProducts.length} more products');
      }
    } catch (e) {
      debugPrint('SubcategoryProductsController: Error loading more products: $e');
      _currentPage--; // Revert page on error
    } finally {
      isLoadingMore.value = false;
    }
  }
  
  /// Refresh products
  Future<void> refreshProducts() async {
    await loadProducts();
  }
  
  /// Navigate to product detail
  void goToProductDetail(Product product) {
    Get.toNamed('/product/${product.id}');
  }
}
