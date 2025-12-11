import '../providers/api_provider.dart';
import '../models/models.dart';

/// Cart Repository - Handles cart API calls
class CartRepository {
  final ApiProvider _api;

  CartRepository(this._api);

  /// Get cart
  Future<CartModel> getCart() async {
    final response = await _api.get<Map<String, dynamic>>(
      '/api/v1/cart',
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      return CartModel.empty();
    }

    return CartModel.fromJson(response.data!);
  }

  /// Add item to cart
  Future<CartModel> addToCart({
    required int productId,
    int quantity = 1,
    String? notes,
  }) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/api/v1/cart/add',
      body: {
        'product_id': productId,
        'quantity': quantity,
        if (notes != null) 'notes': notes,
      },
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success) {
      throw ApiException(
        message: response.message ?? 'Failed to add item to cart',
        statusCode: response.statusCode,
        errors: response.errors,
      );
    }

    // Return updated cart if provided, otherwise fetch it
    if (response.data != null && response.data!['cart'] != null) {
      return CartModel.fromJson(response.data!['cart']);
    }
    return getCart();
  }

  /// Update cart item quantity
  Future<CartModel> updateQuantity({
    required int cartItemId,
    required int quantity,
  }) async {
    final response = await _api.put<Map<String, dynamic>>(
      '/api/v1/cart/items/$cartItemId',
      body: {'quantity': quantity},
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success) {
      throw ApiException(
        message: response.message ?? 'Failed to update quantity',
        statusCode: response.statusCode,
        errors: response.errors,
      );
    }

    if (response.data != null && response.data!['cart'] != null) {
      return CartModel.fromJson(response.data!['cart']);
    }
    return getCart();
  }

  /// Update cart item by product ID
  Future<CartModel> updateQuantityByProduct({
    required int productId,
    required int quantity,
  }) async {
    final response = await _api.put<Map<String, dynamic>>(
      '/api/v1/cart/products/$productId',
      body: {'quantity': quantity},
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success) {
      throw ApiException(
        message: response.message ?? 'Failed to update quantity',
        statusCode: response.statusCode,
        errors: response.errors,
      );
    }

    if (response.data != null && response.data!['cart'] != null) {
      return CartModel.fromJson(response.data!['cart']);
    }
    return getCart();
  }

  /// Remove item from cart
  Future<CartModel> removeFromCart(int cartItemId) async {
    final response = await _api.delete<Map<String, dynamic>>(
      '/api/v1/cart/items/$cartItemId',
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success) {
      throw ApiException(
        message: response.message ?? 'Failed to remove item',
        statusCode: response.statusCode,
      );
    }

    if (response.data != null && response.data!['cart'] != null) {
      return CartModel.fromJson(response.data!['cart']);
    }
    return getCart();
  }

  /// Remove item by product ID
  Future<CartModel> removeByProduct(int productId) async {
    final response = await _api.delete<Map<String, dynamic>>(
      '/api/v1/cart/products/$productId',
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success) {
      throw ApiException(
        message: response.message ?? 'Failed to remove item',
        statusCode: response.statusCode,
      );
    }

    if (response.data != null && response.data!['cart'] != null) {
      return CartModel.fromJson(response.data!['cart']);
    }
    return getCart();
  }

  /// Clear cart
  Future<void> clearCart() async {
    final response = await _api.delete('/api/v1/cart');

    if (!response.success) {
      throw ApiException(
        message: response.message ?? 'Failed to clear cart',
        statusCode: response.statusCode,
      );
    }
  }

  /// Sync local cart with server (for offline support)
  Future<CartModel> syncCart(List<Map<String, dynamic>> items) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/api/v1/cart/sync',
      body: {'items': items},
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        message: response.message ?? 'Failed to sync cart',
        statusCode: response.statusCode,
      );
    }

    return CartModel.fromJson(response.data!);
  }

  /// Apply coupon code
  Future<CartModel> applyCoupon(String couponCode) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/api/v1/cart/coupon',
      body: {'coupon_code': couponCode},
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success) {
      throw ApiException(
        message: response.message ?? 'Invalid coupon code',
        statusCode: response.statusCode,
        errors: response.errors,
      );
    }

    if (response.data != null && response.data!['cart'] != null) {
      return CartModel.fromJson(response.data!['cart']);
    }
    return getCart();
  }

  /// Remove coupon
  Future<CartModel> removeCoupon() async {
    final response = await _api.delete<Map<String, dynamic>>(
      '/api/v1/cart/coupon',
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success) {
      throw ApiException(
        message: response.message ?? 'Failed to remove coupon',
        statusCode: response.statusCode,
      );
    }

    if (response.data != null && response.data!['cart'] != null) {
      return CartModel.fromJson(response.data!['cart']);
    }
    return getCart();
  }

  /// Get cart count
  Future<int> getCartCount() async {
    final response = await _api.get<Map<String, dynamic>>(
      '/api/v1/cart/count',
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      return 0;
    }

    return response.data!['count'] ?? 0;
  }

  /// Validate cart (check stock, prices, etc.)
  Future<Map<String, dynamic>> validateCart() async {
    final response = await _api.get<Map<String, dynamic>>(
      '/api/v1/cart/validate',
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      return {'valid': false, 'errors': []};
    }

    return response.data!;
  }

  /// Move item to wishlist
  Future<CartModel> moveToWishlist(int cartItemId) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/api/v1/cart/items/$cartItemId/move-to-wishlist',
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success) {
      throw ApiException(
        message: response.message ?? 'Failed to move item to wishlist',
        statusCode: response.statusCode,
      );
    }

    if (response.data != null && response.data!['cart'] != null) {
      return CartModel.fromJson(response.data!['cart']);
    }
    return getCart();
  }

  /// Update item notes
  Future<CartModel> updateItemNotes({
    required int cartItemId,
    required String notes,
  }) async {
    final response = await _api.patch<Map<String, dynamic>>(
      '/api/v1/cart/items/$cartItemId',
      body: {'notes': notes},
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success) {
      throw ApiException(
        message: response.message ?? 'Failed to update notes',
        statusCode: response.statusCode,
      );
    }

    if (response.data != null && response.data!['cart'] != null) {
      return CartModel.fromJson(response.data!['cart']);
    }
    return getCart();
  }
}
