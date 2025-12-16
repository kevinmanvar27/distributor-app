import '../providers/api_provider.dart';
import '../models/models.dart';

/// Category Repository - Handles category API calls
class CategoryRepository {
  final ApiProvider _api;

  CategoryRepository(this._api);

  /// Get all categories
  Future<List<CategoryModel>> getCategories({
    bool includeSubcategories = false,
    bool includeProductCount = false,
  }) async {
    final response = await _api.get<List<dynamic>>(
      '/api/v1/categories',
      queryParams: {
        if (includeSubcategories) 'include': 'subcategories',
        if (includeProductCount) 'with_count': '1',
      },
      fromJsonT: (data) => data as List<dynamic>,
    );

    if (!response.success || response.data == null) {
      return [];
    }

    return response.data!
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get single category by ID
  Future<CategoryModel> getCategory(
    int id, {
    bool includeSubcategories = true,
    bool includeProducts = false,
  }) async {
    final response = await _api.get<Map<String, dynamic>>(
      '/api/v1/categories/$id',
      queryParams: {
        if (includeSubcategories) 'include': 'subcategories',
        if (includeProducts) 'with_products': '1',
      },
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        message: response.message ?? 'Category not found',
        statusCode: response.statusCode,
      );
    }

    return CategoryModel.fromJson(response.data!);
  }

  /// Get category by slug
  Future<CategoryModel> getCategoryBySlug(
    String slug, {
    bool includeSubcategories = true,
  }) async {
    final response = await _api.get<Map<String, dynamic>>(
      '/api/v1/categories/slug/$slug',
      queryParams: {
        if (includeSubcategories) 'include': 'subcategories',
      },
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        message: response.message ?? 'Category not found',
        statusCode: response.statusCode,
      );
    }

    return CategoryModel.fromJson(response.data!);
  }

  /// Get all subcategories
  Future<List<SubCategoryModel>> getSubcategories({
    int? categoryId,
    bool includeProductCount = false,
  }) async {
    final response = await _api.get<List<dynamic>>(
      '/api/v1/subcategories',
      queryParams: {
        if (categoryId != null) 'category_id': categoryId,
        if (includeProductCount) 'with_count': '1',
      },
      fromJsonT: (data) => data as List<dynamic>,
    );

    if (!response.success || response.data == null) {
      return [];
    }

    return response.data!
        .map((e) => SubCategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get subcategories for a category
  Future<List<SubCategoryModel>> getSubcategoriesByCategory(
    int categoryId, {
    bool includeProductCount = false,
  }) async {
    final response = await _api.get<List<dynamic>>(
      '/api/v1/categories/$categoryId/subcategories',
      queryParams: {
        if (includeProductCount) 'with_count': '1',
      },
      fromJsonT: (data) => data as List<dynamic>,
    );

    if (!response.success || response.data == null) {
      return [];
    }

    return response.data!
        .map((e) => SubCategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get single subcategory
  Future<SubCategoryModel> getSubcategory(int id) async {
    final response = await _api.get<Map<String, dynamic>>(
      '/api/v1/subcategories/$id',
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        message: response.message ?? 'Subcategory not found',
        statusCode: response.statusCode,
      );
    }

    return SubCategoryModel.fromJson(response.data!);
  }

  /// Get featured categories
  Future<List<CategoryModel>> getFeaturedCategories({int limit = 6}) async {
    final response = await _api.get<List<dynamic>>(
      '/api/v1/categories/featured',
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

  /// Get popular categories
  Future<List<CategoryModel>> getPopularCategories({int limit = 6}) async {
    final response = await _api.get<List<dynamic>>(
      '/api/v1/categories/popular',
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

  /// Search categories
  Future<List<CategoryModel>> searchCategories(String query) async {
    final response = await _api.get<List<dynamic>>(
      '/api/v1/categories/search',
      queryParams: {'q': query},
      fromJsonT: (data) => data as List<dynamic>,
    );

    if (!response.success || response.data == null) {
      return [];
    }

    return response.data!
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get category tree (hierarchical)
  Future<List<CategoryModel>> getCategoryTree() async {
    final response = await _api.get<List<dynamic>>(
      '/api/v1/categories/tree',
      fromJsonT: (data) => data as List<dynamic>,
    );

    if (!response.success || response.data == null) {
      return [];
    }

    return response.data!
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
