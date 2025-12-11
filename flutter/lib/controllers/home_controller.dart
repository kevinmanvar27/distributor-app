import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/data.dart';

/// Home Controller
/// Manages home screen state, dashboard data, and quick actions
class HomeController extends GetxController {
  final HomeRepository _homeRepository;
  final ProductRepository _productRepository;
  final CategoryRepository _categoryRepository;

  HomeController({
    HomeRepository? homeRepository,
    ProductRepository? productRepository,
    CategoryRepository? categoryRepository,
  })  : _homeRepository = homeRepository ?? HomeRepository(Get.find()),
        _productRepository = productRepository ?? ProductRepository(Get.find()),
        _categoryRepository = categoryRepository ?? CategoryRepository(Get.find());

  // Observable state - Home data
  final Rx<HomeData?> homeData = Rx<HomeData?>(null);
  
  // Featured content
  final RxList<CategoryModel> featuredCategories = <CategoryModel>[].obs;
  final RxList<ProductModel> featuredProducts = <ProductModel>[].obs;
  final RxList<ProductModel> newArrivals = <ProductModel>[].obs;
  final RxList<ProductModel> bestSellers = <ProductModel>[].obs;
  final RxList<ProductModel> dealsOfTheDay = <ProductModel>[].obs;
  final RxList<ProductModel> recommendations = <ProductModel>[].obs;
  final RxList<ProductModel> recentlyViewed = <ProductModel>[].obs;
  
  // Banners
  final RxList<Map<String, dynamic>> banners = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> promotionalBanners = <Map<String, dynamic>>[].obs;
  
  // Quick stats
  final RxMap<String, dynamic> quickStats = <String, dynamic>{}.obs;
  
  // Search suggestions
  final RxList<String> searchSuggestions = <String>[].obs;
  final RxList<String> popularSearches = <String>[].obs;

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxBool isLoadingBanners = false.obs;
  final RxBool isLoadingCategories = false.obs;
  final RxBool isLoadingProducts = false.obs;
  
  // Banner carousel
  final RxInt currentBannerIndex = 0.obs;
  
  final RxString errorMessage = ''.obs;

  // Getters
  bool get hasData => homeData.value != null || featuredProducts.isNotEmpty;
  bool get hasBanners => banners.isNotEmpty;
  bool get hasCategories => featuredCategories.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    loadHomeData();
  }

  /// Load all home data
  Future<void> loadHomeData() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Try to load combined home data first
      final data = await _homeRepository.getHomeData();
      homeData.value = data;
      
      // Populate individual lists from combined data
      featuredCategories.value = data.featuredCategories;
      featuredProducts.value = data.featuredProducts;
      newArrivals.value = data.newArrivals;
      bestSellers.value = data.bestSellers;
      dealsOfTheDay.value = data.dealsOfTheDay;
      recommendations.value = data.recommendations;
      recentlyViewed.value = data.recentlyViewed;
      banners.value = data.banners;
      quickStats.value = data.quickStats;
      popularSearches.value = data.popularSearches;
    } on ApiException catch (e) {
      // If combined endpoint fails, load individually
      await _loadDataIndividually();
    } catch (e) {
      errorMessage.value = 'Failed to load home data';
      _showError('Failed to load home data');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load data from individual endpoints
  Future<void> _loadDataIndividually() async {
    await Future.wait([
      loadFeaturedCategories(),
      loadFeaturedProducts(),
      loadNewArrivals(),
      loadBestSellers(),
      loadBanners(),
      loadQuickStats(),
    ]);
  }

  /// Refresh home data
  Future<void> refreshHomeData() async {
    isRefreshing.value = true;
    await loadHomeData();
    isRefreshing.value = false;
  }

  /// Load featured categories
  Future<void> loadFeaturedCategories() async {
    isLoadingCategories.value = true;
    try {
      final categories = await _homeRepository.getFeaturedCategories(limit: 8);
      featuredCategories.value = categories;
    } on ApiException catch (e) {
      // Silently fail
    } finally {
      isLoadingCategories.value = false;
    }
  }

  /// Load featured products
  Future<void> loadFeaturedProducts() async {
    isLoadingProducts.value = true;
    try {
      final products = await _homeRepository.getFeaturedProducts(limit: 10);
      featuredProducts.value = products;
    } on ApiException catch (e) {
      // Silently fail
    } finally {
      isLoadingProducts.value = false;
    }
  }

  /// Load new arrivals
  Future<void> loadNewArrivals() async {
    try {
      final products = await _homeRepository.getNewArrivals(limit: 10);
      newArrivals.value = products;
    } on ApiException catch (e) {
      // Silently fail
    }
  }

  /// Load best sellers
  Future<void> loadBestSellers() async {
    try {
      final products = await _homeRepository.getBestSellers(limit: 10);
      bestSellers.value = products;
    } on ApiException catch (e) {
      // Silently fail
    }
  }

  /// Load deals of the day
  Future<void> loadDealsOfTheDay() async {
    try {
      final products = await _homeRepository.getDealsOfTheDay(limit: 10);
      dealsOfTheDay.value = products;
    } on ApiException catch (e) {
      // Silently fail
    }
  }

  /// Load recommendations
  Future<void> loadRecommendations() async {
    try {
      final products = await _homeRepository.getRecommendations(limit: 10);
      recommendations.value = products;
    } on ApiException catch (e) {
      // Silently fail
    }
  }

  /// Load recently viewed
  Future<void> loadRecentlyViewed() async {
    try {
      final products = await _homeRepository.getRecentlyViewed(limit: 10);
      recentlyViewed.value = products;
    } on ApiException catch (e) {
      // Silently fail
    }
  }

  /// Load banners
  Future<void> loadBanners() async {
    isLoadingBanners.value = true;
    try {
      final bannerList = await _homeRepository.getBanners();
      banners.value = bannerList;
    } on ApiException catch (e) {
      // Silently fail
    } finally {
      isLoadingBanners.value = false;
    }
  }

  /// Load promotional banner
  Future<void> loadPromotionalBanner() async {
    try {
      final banner = await _homeRepository.getPromotionalBanner();
      if (banner != null) {
        promotionalBanners.value = [banner];
      }
    } on ApiException catch (e) {
      // Silently fail
    }
  }

  /// Load quick stats
  Future<void> loadQuickStats() async {
    try {
      final stats = await _homeRepository.getQuickStats();
      quickStats.value = stats;
    } on ApiException catch (e) {
      // Silently fail
    }
  }

  /// Load search suggestions
  Future<void> loadSearchSuggestions(String query) async {
    if (query.length < 2) {
      searchSuggestions.clear();
      return;
    }

    try {
      final suggestions = await _homeRepository.getSearchSuggestions(query);
      searchSuggestions.value = suggestions;
    } on ApiException catch (e) {
      // Silently fail
    }
  }

  /// Load popular searches
  Future<void> loadPopularSearches() async {
    try {
      final searches = await _homeRepository.getPopularSearches(limit: 10);
      popularSearches.value = searches;
    } on ApiException catch (e) {
      // Silently fail
    }
  }

  /// Set current banner index (for carousel)
  void setBannerIndex(int index) {
    currentBannerIndex.value = index;
  }

  /// Handle banner tap
  void handleBannerTap(Map<String, dynamic> banner) {
    final actionType = banner['action_type'] as String?;
    final actionValue = banner['action_value'] as String?;

    if (actionType == null || actionValue == null) return;

    switch (actionType) {
      case 'product':
        Get.toNamed('/product/$actionValue');
        break;
      case 'category':
        Get.toNamed('/category/$actionValue');
        break;
      case 'url':
        // Open external URL
        break;
      case 'promotion':
        Get.toNamed('/promotion/$actionValue');
        break;
      case 'search':
        Get.toNamed('/search', arguments: {'query': actionValue});
        break;
    }
  }

  /// Navigate to category
  void navigateToCategory(CategoryModel category) {
    Get.toNamed('/category/${category.id}', arguments: category);
  }

  /// Navigate to product
  void navigateToProduct(ProductModel product) {
    Get.toNamed('/product/${product.id}', arguments: product);
  }

  /// Navigate to all products in section
  void navigateToSection(String section) {
    switch (section) {
      case 'featured':
        Get.toNamed('/products', arguments: {'filter': 'featured'});
        break;
      case 'new_arrivals':
        Get.toNamed('/products', arguments: {'filter': 'new'});
        break;
      case 'best_sellers':
        Get.toNamed('/products', arguments: {'filter': 'best_sellers'});
        break;
      case 'deals':
        Get.toNamed('/products', arguments: {'filter': 'on_sale'});
        break;
      case 'categories':
        Get.toNamed('/categories');
        break;
    }
  }

  /// Clear search suggestions
  void clearSearchSuggestions() {
    searchSuggestions.clear();
  }

  /// Show error snackbar
  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade900,
      duration: const Duration(seconds: 3),
    );
  }
}
