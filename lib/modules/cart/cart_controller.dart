// Cart Controller
// 
// Manages shopping cart state and operations:
// - Cart items list with reactive updates
// - Add/remove/update item quantities
// - Cart totals calculation (subtotal, tax, total)
// - Checkout flow initiation
// - Cart badge count for navigation

import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../models/cart_item.dart';
import '../../models/product.dart';
import '../../core/services/api_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/app_theme.dart';

class CartController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();

  // ─────────────────────────────────────────────────────────────────────────────
  // Reactive State
  // ─────────────────────────────────────────────────────────────────────────────

  final RxList<CartItem> cartItems = <CartItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isCheckingOut = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // Tax rate (configurable)
  final double taxRate = 0.10; // 10% tax

  // ─────────────────────────────────────────────────────────────────────────────
  // Computed Properties
  // ─────────────────────────────────────────────────────────────────────────────

  /// Total number of items in cart (sum of quantities)
  int get cartCount => cartItems.fold(0, (sum, item) => sum + item.quantity);

  /// Reactive cart count for badge updates
  RxInt get cartCountRx => cartCount.obs;

  /// Number of unique products in cart
  int get uniqueItemsCount => cartItems.length;

  /// Cart subtotal (before tax)
  double get subtotal => cartItems.fold(
    0.0, 
    (sum, item) => sum + item.totalPrice,
  );

  /// Tax amount
  double get taxAmount => subtotal * taxRate;

  /// Total discount applied
  double get totalDiscount => cartItems.fold(
    0.0,
    (sum, item) => sum + item.discountAmount,
  );

  /// Cart total (after tax)
  double get total => subtotal + taxAmount;

  /// Check if cart is empty
  bool get isEmpty => cartItems.isEmpty;

  /// Check if cart has items
  bool get hasItems => cartItems.isNotEmpty;

  // ─────────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _loadCartFromStorage();
  }

  @override
  void onClose() {
    _saveCartToStorage();
    super.onClose();
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Cart Operations
  // ─────────────────────────────────────────────────────────────────────────────

  /// Add product to cart or increment quantity if exists
  void addToCart(Product product, {int quantity = 1}) {
    final existingIndex = cartItems.indexWhere(
      (item) => item.productId == product.id,
    );

    if (existingIndex != -1) {
      // Product exists, increment quantity
      final existingItem = cartItems[existingIndex];
      final newQuantity = existingItem.quantity + quantity;
      
      // Check stock limit
      if (newQuantity > product.stock) {
        _showSnackbar(
          'Stock Limit',
          'Only ${product.stock} items available',
          isError: true,
        );
        return;
      }

      cartItems[existingIndex] = existingItem.copyWith(quantity: newQuantity);
    } else {
      // New product, add to cart
      if (quantity > product.stock) {
        _showSnackbar(
          'Stock Limit',
          'Only ${product.stock} items available',
          isError: true,
        );
        return;
      }

      final cartItem = CartItem(
        productId: product.id,
        name: product.name,
        imageUrl: product.imageUrl,
        price: product.displayPrice,
        originalPrice: product.price,
        quantity: quantity,
        stock: product.stock,
      );
      cartItems.add(cartItem);
    }

    _saveCartToStorage();
    _showSnackbar(
      'Added to Cart',
      '${product.name} added to your cart',
    );
  }

  /// Remove item from cart
  void removeFromCart(int productId) {
    final item = cartItems.firstWhereOrNull((item) => item.productId == productId);
    if (item != null) {
      cartItems.removeWhere((item) => item.productId == productId);
      _saveCartToStorage();
      _showSnackbar(
        'Removed',
        '${item.name} removed from cart',
      );
    }
  }

  /// Update item quantity
  void updateQuantity(int productId, int newQuantity) {
    final index = cartItems.indexWhere((item) => item.productId == productId);
    if (index == -1) return;

    final item = cartItems[index];

    if (newQuantity <= 0) {
      // Remove item if quantity is zero or negative
      removeFromCart(productId);
      return;
    }

    if (newQuantity > item.stock) {
      _showSnackbar(
        'Stock Limit',
        'Only ${item.stock} items available',
        isError: true,
      );
      return;
    }

    cartItems[index] = item.copyWith(quantity: newQuantity);
    _saveCartToStorage();
  }

  /// Increment item quantity by 1
  void incrementQuantity(int productId) {
    final item = cartItems.firstWhereOrNull((item) => item.productId == productId);
    if (item != null) {
      updateQuantity(productId, item.quantity + 1);
    }
  }

  /// Decrement item quantity by 1
  void decrementQuantity(int productId) {
    final item = cartItems.firstWhereOrNull((item) => item.productId == productId);
    if (item != null) {
      updateQuantity(productId, item.quantity - 1);
    }
  }

  /// Clear entire cart
  void clearCart() {
    cartItems.clear();
    _saveCartToStorage();
    _showSnackbar('Cart Cleared', 'All items have been removed');
  }

  /// Check if product is in cart
  bool isInCart(int productId) {
    return cartItems.any((item) => item.productId == productId);
  }

  /// Get quantity of specific product in cart
  int getQuantityInCart(int productId) {
    final item = cartItems.firstWhereOrNull((item) => item.productId == productId);
    return item?.quantity ?? 0;
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Checkout
  // ─────────────────────────────────────────────────────────────────────────────

  /// Initiate checkout process
  Future<void> checkout() async {
    if (isEmpty) {
      _showSnackbar('Empty Cart', 'Add items to your cart first', isError: true);
      return;
    }

    isCheckingOut.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      // Prepare order payload
      final orderItems = cartItems.map((item) => {
        'product_id': item.productId,
        'quantity': item.quantity,
        'price': item.price,
      }).toList();

      final orderData = {
        'items': orderItems,
        'subtotal': subtotal,
        'tax': taxAmount,
        'total': total,
      };

      // POST /orders endpoint
      final response = await _apiService.post('/orders', data: orderData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Order successful
        clearCart();
        _showSnackbar(
          'Order Placed!',
          'Your order has been placed successfully',
        );
        // Navigate to order confirmation or orders list
        Get.offAllNamed('/main');
      } else {
        throw Exception('Failed to place order');
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to place order. Please try again.';
      _showSnackbar(
        'Checkout Failed',
        errorMessage.value,
        isError: true,
      );
    } finally {
      isCheckingOut.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Local Storage
  // ─────────────────────────────────────────────────────────────────────────────

  /// Load cart from local storage
  Future<void> _loadCartFromStorage() async {
    isLoading.value = true;
    try {
      final cartJson = _storageService.getString('cart_items');
      if (cartJson != null && cartJson.isNotEmpty) {
        final List<dynamic> decoded = _parseJsonList(cartJson);
        cartItems.value = decoded
            .map((json) => CartItem.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      // If parsing fails, start with empty cart
      cartItems.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// Save cart to local storage
  Future<void> _saveCartToStorage() async {
    try {
      final cartJson = cartItems.map((item) => item.toJson()).toList();
      await _storageService.saveString('cart_items', _encodeJsonList(cartJson));
    } catch (e) {
      // Silent fail for storage errors
    }
  }

  /// Parse JSON list string
  List<dynamic> _parseJsonList(String jsonString) {
    try {
      if (jsonString.isEmpty) return [];
      final decoded = json.decode(jsonString);
      return decoded is List ? decoded : [];
    } catch (e) {
      return [];
    }
  }

  /// Encode list to JSON string
  String _encodeJsonList(List<Map<String, dynamic>> list) {
    try {
      return json.encode(list);
    } catch (e) {
      return '[]';
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────────

  void _showSnackbar(String title, String message, {bool isError = false}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError 
          ? AppTheme.errorColor.withValues(alpha: 0.9)
          : AppTheme.successColor.withValues(alpha: 0.9),
      colorText: Colors.white,
      margin: const EdgeInsets.all(AppTheme.spacingMD),
      borderRadius: AppTheme.radiusMD,
      duration: const Duration(seconds: 2),
      icon: Icon(
        isError ? Icons.error_outline : Icons.check_circle_outline,
        color: Colors.white,
      ),
    );
  }
}
