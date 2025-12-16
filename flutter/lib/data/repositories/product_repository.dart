import '../providers/api_provider.dart';
import '../models/models.dart';

/// Product Filter Options
class ProductFilter {
  final int? categoryId;
  final int? subcategoryId;
  final double? minPrice;
  final double? maxPrice;
  final String? sortBy;
  final String? sortOrder;
  final bool? inStock;
  final bool? featured;
  final bool? onSale;
  final List<int>? brandIds;
  final String? search;

  ProductFilter({
    this.categoryId,
    this.subcategoryId,
    this.minPrice,
    this.maxPrice,
    this.sortBy,
    this.sortOrder,
    this.inStock,
    this.featured,
    this.onSale,
    this.brandIds,
    this.search,
  });

  Map<String, dynamic> toQueryParams() {
    return {
      if (categoryId != null) 'category_id': categoryId,
      if (subcategoryId != null) 'subcategory_id': subcategoryId,
      if (minPrice != null) 'min_price': minPrice,
      if (maxPrice != null) 'max_price': maxPrice,
      if (sortBy != null) 'sort_by': sortBy,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (inStock != null) 'in_stock': inStock ? '1' : '0',
      if (featured != null) 'featured': featured ? '1' : '0',
      if (onSale != null) 'on_sale': onSale ? '1' : '0',
      if (brandIds != null && brandIds!.isNotEmpty)
        'brand_ids': brandIds!.join(','),
      if (search != null && search!.isNotEmpty) 'search': search,
    };
  }

  ProductFilter copyWith({
    int? categoryId,
    int? subcategoryId,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? sortOrder,
    bool? inStock,
    bool? featured,
    bool? onSale,
    List<int>? brandIds,
    String? search,
  }) {
    return ProductFilter(
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      inStock: inStock ?? this.inStock,
      featured: featured ?? this.featured,
      onSale: onSale ?? this.onSale,
      brandIds: brandIds ?? this.brandIds,
      search: search ?? this.search,
    );
  }
}

/// Product Repository - Handles product API calls
class ProductRepository {
  final ApiProvider _api;

  ProductRepository(this._api);

  /// Get all products with pagination
  Future<PaginatedResponse<ProductModel>> getProducts({
    int page = 1,
    int perPage = 20,
    ProductFilter? filter,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
      ...?filter?.toQueryParams(),
    };

    return _api.getPaginated<ProductModel>(
      '/api/v1/products',
      queryParams: queryParams,
      fromJsonT: (json) => ProductModel.fromJson(json),
    );
  }

  /// Get single product by ID
  Future<ProductModel> getProduct(int id) async {
    final response = await _api.get<Map<String, dynamic>>(
      '/api/v1/products/$id',
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        message: response.message ?? 'Product not found',
        statusCode: response.statusCode,
      );
    }

    return ProductModel.fromJson(response.data!);
  }

  /// Get product by slug
  Future<ProductModel> getProductBySlug(String slug) async {
    final response = await _api.get<Map<String, dynamic>>(
      '/api/v1/products/slug/$slug',
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        message: response.message ?? 'Product not found',
        statusCode: response.statusCode,
      );
    }

    return ProductModel.fromJson(response.data!);
  }

  /// Search products
  Future<PaginatedResponse<ProductModel>> searchProducts({
    required String query,
    int page = 1,
    int perPage = 20,
    ProductFilter? filter,
  }) async {
    final queryParams = <String, dynamic>{
      'q': query,
      'page': page,
      'per_page': perPage,
      ...?filter?.toQueryParams(),
    };

    return _api.getPaginated<ProductModel>(
      '/api/v1/products/search',
      queryParams: queryParams,
      fromJsonT: (json) => ProductModel.fromJson(json),
    );
  }

  /// Get featured products
  Future<List<ProductModel>> getFeaturedProducts({int limit = 10}) async {
    final response = await _api.get<List<dynamic>>(
      '/api/v1/products/featured',
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
      '/api/v1/products/new-arrivals',
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
      '/api/v1/products/best-sellers',
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

  /// Get products on sale
  Future<PaginatedResponse<ProductModel>> getOnSaleProducts({
    int page = 1,
    int perPage = 20,
  }) async {
    return _api.getPaginated<ProductModel>(
      '/api/v1/products/on-sale',
      queryParams: {'page': page, 'per_page': perPage},
      fromJsonT: (json) => ProductModel.fromJson(json),
    );
  }

  /// Get related products
  Future<List<ProductModel>> getRelatedProducts(
    int productId, {
    int limit = 10,
  }) async {
    final response = await _api.get<List<dynamic>>(
      '/api/v1/products/$productId/related',
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

  /// Get products by category
  Future<PaginatedResponse<ProductModel>> getProductsByCategory(
    int categoryId, {
    int page = 1,
    int perPage = 20,
    ProductFilter? filter,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
      ...?filter?.toQueryParams(),
    };

    return _api.getPaginated<ProductModel>(
      '/api/v1/categories/$categoryId/products',
      queryParams: queryParams,
      fromJsonT: (json) => ProductModel.fromJson(json),
    );
  }

  /// Get products by subcategory
  Future<PaginatedResponse<ProductModel>> getProductsBySubcategory(
    int subcategoryId, {
    int page = 1,
    int perPage = 20,
    ProductFilter? filter,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
      ...?filter?.toQueryParams(),
    };

    return _api.getPaginated<ProductModel>(
      '/api/v1/subcategories/$subcategoryId/products',
      queryParams: queryParams,
      fromJsonT: (json) => ProductModel.fromJson(json),
    );
  }

  /// Get recently viewed products
  Future<List<ProductModel>> getRecentlyViewed({int limit = 10}) async {
    final response = await _api.get<List<dynamic>>(
      '/api/v1/products/recently-viewed',
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

  /// Track product view
  Future<void> trackProductView(int productId) async {
    await _api.post('/api/v1/products/$productId/view');
  }

  /// Get price range for filters
  Future<Map<String, double>> getPriceRange({
    int? categoryId,
    int? subcategoryId,
  }) async {
    final response = await _api.get<Map<String, dynamic>>(
      '/api/v1/products/price-range',
      queryParams: {
        if (categoryId != null) 'category_id': categoryId,
        if (subcategoryId != null) 'subcategory_id': subcategoryId,
      },
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      return {'min': 0, 'max': 100000};
    }

    return {
      'min': (response.data!['min'] ?? 0).toDouble(),
      'max': (response.data!['max'] ?? 100000).toDouble(),
    };
  }

  /// Check product availability
  Future<Map<String, dynamic>> checkAvailability(
    int productId, {
    int quantity = 1,
  }) async {
    final response = await _api.get<Map<String, dynamic>>(
      '/api/v1/products/$productId/availability',
      queryParams: {'quantity': quantity},
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      return {'available': false, 'stock': 0};
    }

    return response.data!;
  }
}
