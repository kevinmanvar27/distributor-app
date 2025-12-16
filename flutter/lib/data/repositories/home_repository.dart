import '../providers/api_provider.dart';
import '../models/models.dart';

/// Home Data Model - Combined home screen data
class HomeData {
  final List<Map<String, dynamic>> banners;
  final List<CategoryModel> featuredCategories;
  final List<ProductModel> featuredProducts;
  final List<ProductModel> newArrivals;
  final List<ProductModel> bestSellers;
  final List<ProductModel> onSaleProducts;
  final List<Map<String, dynamic>> announcements;
  final Map<String, dynamic>? promotionalBanner;

  HomeData({
    this.banners = const [],
    this.featuredCategories = const [],
    this.featuredProducts = const [],
    this.newArrivals = const [],
    this.bestSellers = const [],
    this.onSaleProducts = const [],
    this.announcements = const [],
    this.promotionalBanner,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData(
      banners: (json['banners'] as List?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      featuredCategories: (json['featured_categories'] as List?)
              ?.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      featuredProducts: (json['featured_products'] as List?)
              ?.map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      newArrivals: (json['new_arrivals'] as List?)
              ?.map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      bestSellers: (json['best_sellers'] as List?)
              ?.map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      onSaleProducts: (json['on_sale_products'] as List?)
              ?.map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      announcements: (json['announcements'] as List?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      promotionalBanner: json['promotional_banner'],
    );
  }

  factory HomeData.empty() => HomeData();
}

/// Home Repository - Handles home screen API calls
class HomeRepository {
  final ApiProvider _api;

  HomeRepository(this._api);

  /// Get all home data in single call
  Future<HomeData> getHomeData() async {
    final response = await _api.get<Map<String, dynamic>>(
      '/api/v1/home',
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      return HomeData.empty();
    }

    return HomeData.fromJson(response.data!);
  }

  /// Get banners/sliders
  Future<List<Map<String, dynamic>>> getBanners({
    String? position,
    int? limit,
  }) async {
    final response = await _api.get<List<dynamic>>(
      '/api/v1/home/banners',
      queryParams: {
        if (position != null) 'position': position,
        if (limit != null) 'limit': limit,
      },
      fromJsonT: (data) => data as List<dynamic>,
    );

    if (!response.success || response.data == null) {
      return [];
    }

    return response.data!.map((e) => e as Map<String, dynamic>).toList();
  }

  /// Get featured categories
  Future<List<CategoryModel>> getFeaturedCategories({int limit = 8}) async {
    final response = await _api.get<List<dynamic>>(
      '/api/v1/home/featured-categories',
      queryParams: {'limit': limit},
      fromJsonT: (data) => data as List<dynamic>,
    );

    if (!response.success || response.data == null) {
      return [];
    }

    return response.data!
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get featured products
  Future<List<ProductModel>> getFeaturedProducts({int limit = 10}) async {
    final response = await _api.get<List<dynamic>>(
      '/api/v1/home/featured-products',
      queryParams: {'limit': limit},
      fromJsonT: (data) => data as List<dynamic>,
    );

    if (!response.success || response.data == null) {
      return [];
    }

    return response.data!
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get new arrivals
  Future<List<ProductModel>> getNewArrivals({int limit = 10}) async {
    final response = await _api.get<List<dynamic>>(
      '/api/v1/home/new-arrivals',
      queryParams: {'limit': limit},
      fromJsonT: (data) => data as List<dynamic>,
    );

    if (!response.success || response.data == null) {
      return [];
    }

    return response.data!
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get best sellers
  Future<List<ProductModel>> getBestSellers({int limit = 10}) async {
    final response = await _api.get<List<dynamic>>(
      '/api/v1/home/best-sellers',
      queryParams: {'limit': limit},
      fromJsonT: (data) => data as List<dynamic>,
    );

    if (!response.success || response.data == null) {
      return [];
    }

    return response.data!
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get on-sale products
  Future<List<ProductModel>> getOnSaleProducts({int limit = 10}) async {
    final response = await _api.get<List<dynamic>>(
      '/api/v1/home/on-sale',
      queryParams: {'limit': limit},
      fromJsonT: (data) => data as List<dynamic>,
    );

    if (!response.success || response.data == null) {
      return [];
    }

    return response.data!
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get announcements
  Future<List<Map<String, dynamic>>> getAnnouncements() async {
    final response = await _api.get<List<dynamic>>(
      '/api/v1/home/announcements',
      fromJsonT: (data) => data as List<dynamic>,
    );

    if (!response.success || response.data == null) {
      return [];
    }

    return response.data!.map((e) => e as Map<String, dynamic>).toList();
  }

  /// Get promotional banner
  Future<Map<String, dynamic>?> getPromotionalBanner() async {
    final response = await _api.get<Map<String, dynamic>>(
      '/api/v1/home/promotional-banner',
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      return null;
    }

    return response.data;
  }

  /// Get quick stats (for dashboard)
  Future<Map<String, dynamic>> getQuickStats() async {
    final response = await _api.get<Map<String, dynamic>>(
      '/api/v1/home/stats',
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      return {};
    }

    return response.data!;
  }

  /// Get recently viewed products
  Future<List<ProductModel>> getRecentlyViewed({int limit = 10}) async {
    final response = await _api.get<List<dynamic>>(
      '/api/v1/home/recently-viewed',
      queryParams: {'limit': limit},
      fromJsonT: (data) => data as List<dynamic>,
    );

    if (!response.success || response.data == null) {
      return [];
    }

    return response.data!
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get recommended products (personalized)
  Future<List<ProductModel>> getRecommendedProducts({int limit = 10}) async {
    final response = await _api.get<List<dynamic>>(
      '/api/v1/home/recommended',
      queryParams: {'limit': limit},
      fromJsonT: (data) => data as List<dynamic>,
    );

    if (!response.success || response.data == null) {
      return [];
    }

    return response.data!
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get deals of the day
  Future<List<ProductModel>> getDealsOfTheDay({int limit = 10}) async {
    final response = await _api.get<List<dynamic>>(
      '/api/v1/home/deals',
      queryParams: {'limit': limit},
      fromJsonT: (data) => data as List<dynamic>,
    );

    if (!response.success || response.data == null) {
      return [];
    }

    return response.data!
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Search suggestions
  Future<List<String>> getSearchSuggestions(String query) async {
    final response = await _api.get<List<dynamic>>(
      '/api/v1/home/search-suggestions',
      queryParams: {'q': query},
      fromJsonT: (data) => data as List<dynamic>,
    );

    if (!response.success || response.data == null) {
      return [];
    }

    return response.data!.map((e) => e.toString()).toList();
  }

  /// Get popular searches
  Future<List<String>> getPopularSearches({int limit = 10}) async {
    final response = await _api.get<List<dynamic>>(
      '/api/v1/home/popular-searches',
      queryParams: {'limit': limit},
      fromJsonT: (data) => data as List<dynamic>,
    );

    if (!response.success || response.data == null) {
      return [];
    }

    return response.data!.map((e) => e.toString()).toList();
  }
}
