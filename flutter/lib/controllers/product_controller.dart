import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/data.dart';

/// Product Controller
/// Manages product listing, search, filtering, and details
class ProductController extends GetxController {
  final ProductRepository _productRepository;
  final CategoryRepository _categoryRepository;

  ProductController({
    ProductRepository? productRepository,
    CategoryRepository? categoryRepository,
  })  : _productRepository = productRepository ?? ProductRepository(Get.find()),
        _categoryRepository = categoryRepository ?? CategoryRepository(Get.find());

  // Observable state - Products
  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxList<ProductModel> searchResults = <ProductModel>[].obs;
  final RxList<ProductModel> featuredProducts = <ProductModel>[].obs;
  final RxList<ProductModel> newArrivals = <ProductModel>[].obs;
  final RxList<ProductModel> bestSellers = <ProductModel>[].obs;
  final RxList<ProductModel> onSaleProducts = <ProductModel>[].obs;
  final RxList<ProductModel> relatedProducts = <ProductModel>[].obs;
  final RxList<ProductModel> recentlyViewed = <ProductModel>[].obs;
  
  final Rx<ProductModel?> selectedProduct = Rx<ProductModel?>(null);
  
  // Observable state - Categories
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxList<CategoryModel> featuredCategories = <CategoryModel>[].obs;
  final RxList<SubcategoryModel> subcategories = <SubcategoryModel>[].obs;
  final Rx<CategoryModel?> selectedCategory = Rx<CategoryModel?>(null);
  final Rx<SubcategoryModel?> selectedSubcategory = Rx<SubcategoryModel?>(null);

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isSearching = false.obs;
  final RxBool isLoadingDetails = false.obs;
  final RxBool isLoadingCategories = false.obs;
  
  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxInt totalProducts = 0.obs;
  final RxBool hasMoreProducts = true.obs;

  // Search & Filter
  final RxString searchQuery = ''.obs;
  final Rx<ProductFilter> currentFilter = ProductFilter().obs;
  final RxList<String> searchSuggestions = <String>[].obs;
  final RxList<String> recentSearches = <String>[].obs;
  
  // Price range
  final RxDouble minPrice = 0.0.obs;
  final RxDouble maxPrice = 10000.0.obs;
  final RxDouble selectedMinPrice = 0.0.obs;
  final RxDouble selectedMaxPrice = 10000.0.obs;

  // Sort options
  final RxString sortBy = 'created_at'.obs;
  final RxString sortOrder = 'desc'.obs;
  
  // View mode
  final RxBool isGridView = true.obs;

  // Error handling
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  /// Load initial data
  Future<void> loadInitialData() async {
    await Future.wait([
      loadCategories(),
      loadFeaturedProducts(),
      loadPriceRange(),
    ]);
  }

  /// Load all categories
  Future<void> loadCategories() async {
    isLoadingCategories.value = true;
    try {
      final result = await _categoryRepository.getAllCategories(includeSubcategories: true);
      categories.value = result;
      
      // Also load featured categories
      final featured = await _categoryRepository.getFeaturedCategories();
      featuredCategories.value = featured;
    } on ApiException catch (e) {
      _showError(e.message);
    } finally {
      isLoadingCategories.value = false;
    }
  }

  /// Load subcategories for a category
  Future<void> loadSubcategories(int categoryId) async {
    try {
      final result = await _categoryRepository.getSubcategoriesByCategory(categoryId);
      subcategories.value = result;
    } on ApiException catch (e) {
      _showError(e.message);
    }
  }

  /// Load products with current filter
  Future<void> loadProducts({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      hasMoreProducts.value = true;
      products.clear();
    }

    if (!hasMoreProducts.value && !refresh) return;

    isLoading.value = refresh || products.isEmpty;
    isLoadingMore.value = !refresh && products.isNotEmpty;
    errorMessage.value = '';

    try {
      final filter = currentFilter.value.copyWith(
        sortBy: sortBy.value,
        sortOrder: sortOrder.value,
        minPrice: selectedMinPrice.value > 0 ? selectedMinPrice.value : null,
        maxPrice: selectedMaxPrice.value < maxPrice.value ? selectedMaxPrice.value : null,
      );

      final response = await _productRepository.getProducts(
        page: currentPage.value,
        perPage: 20,
        filter: filter,
      );

      if (refresh) {
        products.value = response.data;
      } else {
        products.addAll(response.data);
      }

      currentPage.value = response.currentPage;
      totalPages.value = response.lastPage;
      totalProducts.value = response.total;
      hasMoreProducts.value = response.hasNextPage;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      _showError(e.message);
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  /// Load more products (pagination)
  Future<void> loadMoreProducts() async {
    if (isLoadingMore.value || !hasMoreProducts.value) return;
    currentPage.value++;
    await loadProducts();
  }

  /// Search products
  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    searchQuery.value = query;
    isSearching.value = true;

    try {
      final response = await _productRepository.searchProducts(
        query: query,
        page: 1,
        perPage: 50,
      );
      searchResults.value = response.data;
      
      // Add to recent searches
      if (!recentSearches.contains(query)) {
        recentSearches.insert(0, query);
        if (recentSearches.length > 10) {
          recentSearches.removeLast();
        }
      }
    } on ApiException catch (e) {
      _showError(e.message);
    } finally {
      isSearching.value = false;
    }
  }

  /// Get search suggestions
  Future<void> getSearchSuggestions(String query) async {
    if (query.length < 2) {
      searchSuggestions.clear();
      return;
    }

    try {
      // Simple local suggestion from product names
      final suggestions = products
          .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
          .map((p) => p.name)
          .take(5)
          .toList();
      searchSuggestions.value = suggestions;
    } catch (e) {
      // Ignore suggestion errors
    }
  }

  /// Clear search
  void clearSearch() {
    searchQuery.value = '';
    searchResults.clear();
    searchSuggestions.clear();
  }

  /// Load featured products
  Future<void> loadFeaturedProducts() async {
    try {
      final response = await _productRepository.getFeaturedProducts(limit: 10);
      featuredProducts.value = response;
    } on ApiException catch (e) {
      _showError(e.message);
    }
  }

  /// Load new arrivals
  Future<void> loadNewArrivals() async {
    try {
      final response = await _productRepository.getNewArrivals(limit: 10);
      newArrivals.value = response;
    } on ApiException catch (e) {
      _showError(e.message);
    }
  }

  /// Load best sellers
  Future<void> loadBestSellers() async {
    try {
      final response = await _productRepository.getBestSellers(limit: 10);
      bestSellers.value = response;
    } on ApiException catch (e) {
      _showError(e.message);
    }
  }

  /// Load on sale products
  Future<void> loadOnSaleProducts() async {
    try {
      final response = await _productRepository.getOnSaleProducts(limit: 10);
      onSaleProducts.value = response;
    } on ApiException catch (e) {
      _showError(e.message);
    }
  }

  /// Load product details
  Future<ProductModel?> loadProductDetails(int productId) async {
    isLoadingDetails.value = true;

    try {
      final product = await _productRepository.getProductById(productId);
      selectedProduct.value = product;
      
      // Track as recently viewed
      await trackRecentlyViewed(productId);
      
      // Load related products
      await loadRelatedProducts(productId);
      
      return product;
    } on ApiException catch (e) {
      _showError(e.message);
      return null;
    } finally {
      isLoadingDetails.value = false;
    }
  }

  /// Load related products
  Future<void> loadRelatedProducts(int productId) async {
    try {
      final response = await _productRepository.getRelatedProducts(productId, limit: 10);
      relatedProducts.value = response;
    } on ApiException catch (e) {
      // Silently fail for related products
    }
  }

  /// Track recently viewed product
  Future<void> trackRecentlyViewed(int productId) async {
    try {
      await _productRepository.trackRecentlyViewed(productId);
    } catch (e) {
      // Silently fail tracking
    }
  }

  /// Load recently viewed products
  Future<void> loadRecentlyViewed() async {
    try {
      final response = await _productRepository.getRecentlyViewed(limit: 10);
      recentlyViewed.value = response;
    } on ApiException catch (e) {
      // Silently fail
    }
  }

  /// Load price range
  Future<void> loadPriceRange() async {
    try {
      final range = await _productRepository.getPriceRange();
      minPrice.value = range['min'] ?? 0.0;
      maxPrice.value = range['max'] ?? 10000.0;
      selectedMinPrice.value = minPrice.value;
      selectedMaxPrice.value = maxPrice.value;
    } catch (e) {
      // Use defaults
    }
  }

  /// Filter by category
  void filterByCategory(CategoryModel? category) {
    selectedCategory.value = category;
    selectedSubcategory.value = null;
    
    if (category != null) {
      currentFilter.value = currentFilter.value.copyWith(categoryId: category.id);
      loadSubcategories(category.id);
    } else {
      currentFilter.value = ProductFilter();
    }
    
    loadProducts(refresh: true);
  }

  /// Filter by subcategory
  void filterBySubcategory(SubcategoryModel? subcategory) {
    selectedSubcategory.value = subcategory;
    
    if (subcategory != null) {
      currentFilter.value = currentFilter.value.copyWith(subcategoryId: subcategory.id);
    } else if (selectedCategory.value != null) {
      currentFilter.value = currentFilter.value.copyWith(
        categoryId: selectedCategory.value!.id,
        subcategoryId: null,
      );
    }
    
    loadProducts(refresh: true);
  }

  /// Apply price filter
  void applyPriceFilter(double min, double max) {
    selectedMinPrice.value = min;
    selectedMaxPrice.value = max;
    loadProducts(refresh: true);
  }

  /// Set sort option
  void setSortOption(String sort, String order) {
    sortBy.value = sort;
    sortOrder.value = order;
    loadProducts(refresh: true);
  }

  /// Toggle view mode
  void toggleViewMode() {
    isGridView.value = !isGridView.value;
  }

  /// Clear all filters
  void clearFilters() {
    selectedCategory.value = null;
    selectedSubcategory.value = null;
    selectedMinPrice.value = minPrice.value;
    selectedMaxPrice.value = maxPrice.value;
    sortBy.value = 'created_at';
    sortOrder.value = 'desc';
    currentFilter.value = ProductFilter();
    loadProducts(refresh: true);
  }

  /// Check product availability
  Future<bool> checkAvailability(int productId, int quantity) async {
    try {
      return await _productRepository.checkAvailability(productId, quantity);
    } catch (e) {
      return false;
    }
  }

  /// Get product by ID from local list
  ProductModel? getProductById(int id) {
    try {
      return products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Refresh all data
  Future<void> refreshAll() async {
    await Future.wait([
      loadProducts(refresh: true),
      loadCategories(),
      loadFeaturedProducts(),
      loadNewArrivals(),
      loadBestSellers(),
    ]);
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

/// Product Filter Extension for copyWith
extension ProductFilterCopyWith on ProductFilter {
  ProductFilter copyWith({
    int? categoryId,
    int? subcategoryId,
    String? search,
    double? minPrice,
    double? maxPrice,
    bool? inStock,
    bool? featured,
    bool? onSale,
    String? sortBy,
    String? sortOrder,
    List<String>? brands,
    List<String>? tags,
  }) {
    return ProductFilter(
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      search: search ?? this.search,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      inStock: inStock ?? this.inStock,
      featured: featured ?? this.featured,
      onSale: onSale ?? this.onSale,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      brands: brands ?? this.brands,
      tags: tags ?? this.tags,
    );
  }
}
