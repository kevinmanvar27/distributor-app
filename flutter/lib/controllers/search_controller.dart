import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/data.dart';

/// Search Controller
/// Manages advanced search, autocomplete, filters, and search history
class AppSearchController extends GetxController {
  final ProductRepository _productRepository;
  final HomeRepository _homeRepository;

  AppSearchController({
    ProductRepository? productRepository,
    HomeRepository? homeRepository,
  })  : _productRepository = productRepository ?? ProductRepository(Get.find()),
        _homeRepository = homeRepository ?? HomeRepository(Get.find());

  // Search query
  final RxString query = ''.obs;
  final searchTextController = TextEditingController();
  final searchFocusNode = FocusNode();

  // Search results
  final RxList<ProductModel> searchResults = <ProductModel>[].obs;
  final RxList<String> suggestions = <String>[].obs;
  final RxList<String> recentSearches = <String>[].obs;
  final RxList<String> popularSearches = <String>[].obs;
  final RxList<CategoryModel> suggestedCategories = <CategoryModel>[].obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxInt totalResults = 0.obs;

  // Filters
  final Rx<ProductFilter> filters = ProductFilter().obs;
  final RxBool filtersApplied = false.obs;
  
  // Sort options
  final RxString sortBy = 'relevance'.obs;
  final RxString sortOrder = 'desc'.obs;
  final RxList<Map<String, String>> sortOptions = <Map<String, String>>[
    {'value': 'relevance', 'label': 'Relevance'},
    {'value': 'name_asc', 'label': 'Name (A-Z)'},
    {'value': 'name_desc', 'label': 'Name (Z-A)'},
    {'value': 'price_asc', 'label': 'Price (Low to High)'},
    {'value': 'price_desc', 'label': 'Price (High to Low)'},
    {'value': 'newest', 'label': 'Newest First'},
    {'value': 'rating', 'label': 'Highest Rated'},
    {'value': 'popularity', 'label': 'Most Popular'},
  ].obs;

  // View mode
  final RxBool isGridView = true.obs;

  // Loading states
  final RxBool isSearching = false.obs;
  final RxBool isLoadingSuggestions = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasSearched = false.obs;

  // Price range
  final RxDouble minPrice = 0.0.obs;
  final RxDouble maxPrice = 10000.0.obs;
  final RxDouble selectedMinPrice = 0.0.obs;
  final RxDouble selectedMaxPrice = 10000.0.obs;

  // Available categories for filtering
  final RxList<CategoryModel> availableCategories = <CategoryModel>[].obs;

  // Getters
  bool get hasResults => searchResults.isNotEmpty;
  bool get hasMorePages => currentPage.value < totalPages.value;
  bool get isQueryEmpty => query.value.isEmpty;
  bool get showSuggestions => suggestions.isNotEmpty || recentSearches.isNotEmpty;

  static const String _recentSearchesKey = 'recent_searches';
  static const int _maxRecentSearches = 10;

  @override
  void onInit() {
    super.onInit();
    _loadRecentSearches();
    _loadPopularSearches();
    _loadAvailableCategories();
    _setupSearchListener();
  }

  @override
  void onClose() {
    searchTextController.dispose();
    searchFocusNode.dispose();
    super.onClose();
  }

  /// Setup search listener with debounce
  void _setupSearchListener() {
    debounce(
      query,
      (_) => _onQueryChanged(),
      time: const Duration(milliseconds: 300),
    );
  }

  /// Handle query changes
  void _onQueryChanged() {
    if (query.value.length >= 2) {
      loadSuggestions();
    } else {
      suggestions.clear();
    }
  }

  /// Update query
  void updateQuery(String value) {
    query.value = value;
    searchTextController.text = value;
  }

  /// Clear query
  void clearQuery() {
    query.value = '';
    searchTextController.clear();
    suggestions.clear();
    searchFocusNode.requestFocus();
  }

  /// Perform search
  Future<void> search({bool resetPage = true}) async {
    if (query.value.trim().isEmpty) return;

    if (resetPage) {
      currentPage.value = 1;
      searchResults.clear();
    }

    isSearching.value = true;
    hasSearched.value = true;

    try {
      // Save to recent searches
      _saveRecentSearch(query.value.trim());

      // Build filter with search query
      final searchFilter = ProductFilter(
        search: query.value.trim(),
        categoryId: filters.value.categoryId,
        subcategoryId: filters.value.subcategoryId,
        minPrice: selectedMinPrice.value > 0 ? selectedMinPrice.value : null,
        maxPrice: selectedMaxPrice.value < maxPrice.value ? selectedMaxPrice.value : null,
        inStock: filters.value.inStock,
        onSale: filters.value.onSale,
        featured: filters.value.featured,
        sortBy: _getSortField(),
        sortOrder: _getSortOrder(),
        page: currentPage.value,
        perPage: 20,
      );

      final response = await _productRepository.getProducts(filter: searchFilter);
      
      if (resetPage) {
        searchResults.value = response.data;
      } else {
        searchResults.addAll(response.data);
      }
      
      totalPages.value = response.lastPage;
      totalResults.value = response.total;
      currentPage.value = response.currentPage;
      
      // Clear suggestions after search
      suggestions.clear();
    } on ApiException catch (e) {
      _showError(e.message);
    } finally {
      isSearching.value = false;
    }
  }

  /// Load more results
  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMorePages) return;

    isLoadingMore.value = true;
    currentPage.value++;
    
    await search(resetPage: false);
    
    isLoadingMore.value = false;
  }

  /// Load search suggestions
  Future<void> loadSuggestions() async {
    if (query.value.length < 2) return;

    isLoadingSuggestions.value = true;

    try {
      final suggestionList = await _homeRepository.getSearchSuggestions(query.value);
      suggestions.value = suggestionList;
    } on ApiException catch (e) {
      // Silently fail
    } finally {
      isLoadingSuggestions.value = false;
    }
  }

  /// Select suggestion
  void selectSuggestion(String suggestion) {
    updateQuery(suggestion);
    search();
  }

  /// Load recent searches from storage
  Future<void> _loadRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final searches = prefs.getStringList(_recentSearchesKey) ?? [];
      recentSearches.value = searches;
    } catch (e) {
      // Silently fail
    }
  }

  /// Save recent search to storage
  Future<void> _saveRecentSearch(String searchQuery) async {
    try {
      // Remove if already exists
      recentSearches.remove(searchQuery);
      
      // Add to beginning
      recentSearches.insert(0, searchQuery);
      
      // Limit to max
      if (recentSearches.length > _maxRecentSearches) {
        recentSearches.removeRange(_maxRecentSearches, recentSearches.length);
      }

      // Save to storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_recentSearchesKey, recentSearches);
    } catch (e) {
      // Silently fail
    }
  }

  /// Remove recent search
  Future<void> removeRecentSearch(String searchQuery) async {
    recentSearches.remove(searchQuery);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_recentSearchesKey, recentSearches);
    } catch (e) {
      // Silently fail
    }
  }

  /// Clear all recent searches
  Future<void> clearRecentSearches() async {
    recentSearches.clear();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_recentSearchesKey);
    } catch (e) {
      // Silently fail
    }
  }

  /// Load popular searches
  Future<void> _loadPopularSearches() async {
    try {
      final searches = await _homeRepository.getPopularSearches(limit: 10);
      popularSearches.value = searches;
    } on ApiException catch (e) {
      // Silently fail
    }
  }

  /// Load available categories for filtering
  Future<void> _loadAvailableCategories() async {
    try {
      final categories = await _homeRepository.getFeaturedCategories(limit: 20);
      availableCategories.value = categories;
    } on ApiException catch (e) {
      // Silently fail
    }
  }

  /// Apply filters
  void applyFilters({
    int? categoryId,
    int? subcategoryId,
    double? minPrice,
    double? maxPrice,
    bool? inStock,
    bool? onSale,
    bool? featured,
  }) {
    filters.value = ProductFilter(
      categoryId: categoryId,
      subcategoryId: subcategoryId,
      minPrice: minPrice,
      maxPrice: maxPrice,
      inStock: inStock,
      onSale: onSale,
      featured: featured,
    );

    if (minPrice != null) selectedMinPrice.value = minPrice;
    if (maxPrice != null) selectedMaxPrice.value = maxPrice;

    filtersApplied.value = _hasActiveFilters();
    
    if (hasSearched.value) {
      search();
    }
  }

  /// Check if any filters are active
  bool _hasActiveFilters() {
    return filters.value.categoryId != null ||
        filters.value.subcategoryId != null ||
        selectedMinPrice.value > 0 ||
        selectedMaxPrice.value < maxPrice.value ||
        filters.value.inStock == true ||
        filters.value.onSale == true ||
        filters.value.featured == true;
  }

  /// Clear all filters
  void clearFilters() {
    filters.value = ProductFilter();
    selectedMinPrice.value = 0;
    selectedMaxPrice.value = maxPrice.value;
    filtersApplied.value = false;
    
    if (hasSearched.value) {
      search();
    }
  }

  /// Set sort option
  void setSortOption(String option) {
    sortBy.value = option;
    
    if (hasSearched.value) {
      search();
    }
  }

  /// Get sort field for API
  String _getSortField() {
    switch (sortBy.value) {
      case 'name_asc':
      case 'name_desc':
        return 'name';
      case 'price_asc':
      case 'price_desc':
        return 'price';
      case 'newest':
        return 'created_at';
      case 'rating':
        return 'rating';
      case 'popularity':
        return 'sales_count';
      default:
        return 'relevance';
    }
  }

  /// Get sort order for API
  String _getSortOrder() {
    switch (sortBy.value) {
      case 'name_asc':
      case 'price_asc':
        return 'asc';
      default:
        return 'desc';
    }
  }

  /// Toggle view mode
  void toggleViewMode() {
    isGridView.value = !isGridView.value;
  }

  /// Set view mode
  void setViewMode(bool gridView) {
    isGridView.value = gridView;
  }

  /// Set price range
  void setPriceRange(double min, double max) {
    selectedMinPrice.value = min;
    selectedMaxPrice.value = max;
    filtersApplied.value = _hasActiveFilters();
  }

  /// Filter by category
  void filterByCategory(CategoryModel category) {
    applyFilters(categoryId: category.id);
  }

  /// Clear category filter
  void clearCategoryFilter() {
    applyFilters(categoryId: null, subcategoryId: null);
  }

  /// Show filter bottom sheet
  void showFilterSheet() {
    Get.bottomSheet(
      _buildFilterSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
  }

  /// Build filter bottom sheet
  Widget _buildFilterSheet() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filters',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  clearFilters();
                  Get.back();
                },
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Price Range', style: TextStyle(fontWeight: FontWeight.w600)),
          Obx(() => RangeSlider(
            values: RangeValues(selectedMinPrice.value, selectedMaxPrice.value),
            min: minPrice.value,
            max: maxPrice.value,
            divisions: 100,
            labels: RangeLabels(
              '\$${selectedMinPrice.value.toStringAsFixed(0)}',
              '\$${selectedMaxPrice.value.toStringAsFixed(0)}',
            ),
            onChanged: (values) {
              setPriceRange(values.start, values.end);
            },
          )),
          const SizedBox(height: 16),
          Obx(() => CheckboxListTile(
            title: const Text('In Stock Only'),
            value: filters.value.inStock ?? false,
            onChanged: (value) {
              applyFilters(inStock: value);
            },
          )),
          Obx(() => CheckboxListTile(
            title: const Text('On Sale'),
            value: filters.value.onSale ?? false,
            onChanged: (value) {
              applyFilters(onSale: value);
            },
          )),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Get.back();
                search();
              },
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }

  /// Show sort bottom sheet
  void showSortSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sort By',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...sortOptions.map((option) => Obx(() => RadioListTile<String>(
              title: Text(option['label']!),
              value: option['value']!,
              groupValue: sortBy.value,
              onChanged: (value) {
                if (value != null) {
                  setSortOption(value);
                  Get.back();
                }
              },
            ))),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
  }

  /// Navigate to product
  void navigateToProduct(ProductModel product) {
    Get.toNamed('/product/${product.id}', arguments: product);
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
