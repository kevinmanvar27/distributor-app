import '../providers/api_provider.dart';
import '../models/models.dart';

/// Wishlist Repository - Handles wishlist API calls
class WishlistRepository {
  final ApiProvider _api;

  WishlistRepository(this._api);

  /// Get wishlist
  Future<WishlistModel> getWishlist() async {
    final response = await _api.get<Map<String, dynamic>>(
      '/api/v1/wishlist',
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      return WishlistModel.empty();
    }

    return WishlistModel.fromJson(response.data!);
  }

  /// Get wishlist with pagination
  Future<PaginatedResponse<WishlistItemModel>> getWishlistPaginated({
    int page = 1,
    int perPage = 20,
  }) async {
    return _api.getPaginated<WishlistItemModel>(
      '/api/v1/wishlist',
      queryParams: {'page': page, 'per_page': perPage},
      fromJsonT: (json) => WishlistItemModel.fromJson(json),
    );
  }

  /// Add item to wishlist
  Future<WishlistModel> addToWishlist(int productId) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/api/v1/wishlist/add',
      body: {'product_id': productId},
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success) {
      throw ApiException(
        message: response.message ?? 'Failed to add item to wishlist',
        statusCode: response.statusCode,
        errors: response.errors,
      );
    }

    // Return updated wishlist if provided, otherwise fetch it
    if (response.data != null && response.data!['wishlist'] != null) {
      return WishlistModel.fromJson(response.data!['wishlist']);
    }
    return getWishlist();
  }

  /// Remove item from wishlist
  Future<WishlistModel> removeFromWishlist(int wishlistItemId) async {
    final response = await _api.delete<Map<String, dynamic>>(
      '/api/v1/wishlist/items/$wishlistItemId',
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success) {
      throw ApiException(
        message: response.message ?? 'Failed to remove item from wishlist',
        statusCode: response.statusCode,
      );
    }

    if (response.data != null && response.data!['wishlist'] != null) {
      return WishlistModel.fromJson(response.data!['wishlist']);
    }
    return getWishlist();
  }

  /// Remove item by product ID
  Future<WishlistModel> removeByProduct(int productId) async {
    final response = await _api.delete<Map<String, dynamic>>(
      '/api/v1/wishlist/products/$productId',
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success) {
      throw ApiException(
        message: response.message ?? 'Failed to remove item from wishlist',
        statusCode: response.statusCode,
      );
    }

    if (response.data != null && response.data!['wishlist'] != null) {
      return WishlistModel.fromJson(response.data!['wishlist']);
    }
    return getWishlist();
  }

  /// Toggle wishlist (add if not exists, remove if exists)
  Future<Map<String, dynamic>> toggleWishlist(int productId) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/api/v1/wishlist/toggle',
      body: {'product_id': productId},
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        message: response.message ?? 'Failed to toggle wishlist',
        statusCode: response.statusCode,
      );
    }

    return response.data!;
  }

  /// Clear wishlist
  Future<void> clearWishlist() async {
    final response = await _api.delete('/api/v1/wishlist');

    if (!response.success) {
      throw ApiException(
        message: response.message ?? 'Failed to clear wishlist',
        statusCode: response.statusCode,
      );
    }
  }

  /// Check if product is in wishlist
  Future<bool> isInWishlist(int productId) async {
    final response = await _api.get<Map<String, dynamic>>(
      '/api/v1/wishlist/check/$productId',
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      return false;
    }

    return response.data!['in_wishlist'] == true;
  }

  /// Get wishlist count
  Future<int> getWishlistCount() async {
    final response = await _api.get<Map<String, dynamic>>(
      '/api/v1/wishlist/count',
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      return 0;
    }

    return response.data!['count'] ?? 0;
  }

  /// Move item to cart
  Future<WishlistModel> moveToCart(int wishlistItemId, {int quantity = 1}) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/api/v1/wishlist/items/$wishlistItemId/move-to-cart',
      body: {'quantity': quantity},
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success) {
      throw ApiException(
        message: response.message ?? 'Failed to move item to cart',
        statusCode: response.statusCode,
      );
    }

    if (response.data != null && response.data!['wishlist'] != null) {
      return WishlistModel.fromJson(response.data!['wishlist']);
    }
    return getWishlist();
  }

  /// Move all items to cart
  Future<Map<String, dynamic>> moveAllToCart() async {
    final response = await _api.post<Map<String, dynamic>>(
      '/api/v1/wishlist/move-all-to-cart',
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        message: response.message ?? 'Failed to move items to cart',
        statusCode: response.statusCode,
      );
    }

    return response.data!;
  }

  /// Sync local wishlist with server
  Future<WishlistModel> syncWishlist(List<int> productIds) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/api/v1/wishlist/sync',
      body: {'product_ids': productIds},
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        message: response.message ?? 'Failed to sync wishlist',
        statusCode: response.statusCode,
      );
    }

    return WishlistModel.fromJson(response.data!);
  }

  /// Get wishlist product IDs (for quick lookup)
  Future<List<int>> getWishlistProductIds() async {
    final response = await _api.get<List<dynamic>>(
      '/api/v1/wishlist/product-ids',
      fromJsonT: (data) => data as List<dynamic>,
    );

    if (!response.success || response.data == null) {
      return [];
    }

    return response.data!.map((e) => e as int).toList();
  }
}
