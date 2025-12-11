import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/data.dart';

/// Cart Controller
/// Manages shopping cart state, items, totals, and checkout preparation
class CartController extends GetxController {
  final CartRepository _cartRepository;

  CartController({
    CartRepository? cartRepository,
  }) : _cartRepository = cartRepository ?? CartRepository(Get.find());

  // Observable state
  final Rx<CartModel?> cart = Rx<CartModel?>(null);
  final RxList<CartItemModel> items = <CartItemModel>[].obs;
  
  final RxBool isLoading = false.obs;
  final RxBool isUpdating = false.obs;
  final RxBool isSyncing = false.obs;
  
  final RxString couponCode = ''.obs;
  final RxBool hasCoupon = false.obs;
  final RxDouble couponDiscount = 0.0.obs;
  
  final RxString errorMessage = ''.obs;

  // Getters
  int get itemCount => items.length;
  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);
  
  double get subtotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);
  double get discount => couponDiscount.value + items.fold(0.0, (sum, item) => sum + item.discountAmount);
  double get tax => cart.value?.tax ?? 0.0;
  double get shipping => cart.value?.shipping ?? 0.0;
  double get total => subtotal - discount + tax + shipping;
  
  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
  bool get hasValidItems => items.any((item) => item.isValid);

  @override
  void onInit() {
    super.onInit();
    loadCart();
  }

  /// Load cart from API
  Future<void> loadCart() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final cartData = await _cartRepository.getCart();
      cart.value = cartData;
      items.value = cartData.items;
      
      if (cartData.couponCode != null) {
        couponCode.value = cartData.couponCode!;
        hasCoupon.value = true;
        couponDiscount.value = cartData.couponDiscount ?? 0.0;
      }
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      // Don't show error for empty cart
      if (!e.message.toLowerCase().contains('empty')) {
        _showError(e.message);
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Add item to cart
  Future<bool> addToCart({
    required int productId,
    int quantity = 1,
    int? variantId,
    String? notes,
  }) async {
    isUpdating.value = true;

    try {
      final cartData = await _cartRepository.addToCart(
        productId: productId,
        quantity: quantity,
        variantId: variantId,
        notes: notes,
      );

      cart.value = cartData;
      items.value = cartData.items;

      Get.snackbar(
        'Added to Cart',
        'Item has been added to your cart',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        duration: const Duration(seconds: 2),
        mainButton: TextButton(
          onPressed: () => Get.toNamed('/cart'),
          child: const Text('View Cart'),
        ),
      );

      return true;
    } on ApiException catch (e) {
      _showError(e.message);
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  /// Update item quantity
  Future<bool> updateQuantity(int itemId, int quantity) async {
    if (quantity < 1) {
      return removeItem(itemId);
    }

    isUpdating.value = true;

    // Optimistic update
    final index = items.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      final oldQuantity = items[index].quantity;
      items[index] = CartItemModel(
        id: items[index].id,
        productId: items[index].productId,
        productName: items[index].productName,
        productImage: items[index].productImage,
        productSku: items[index].productSku,
        variantId: items[index].variantId,
        variantName: items[index].variantName,
        quantity: quantity,
        unitPrice: items[index].unitPrice,
        discountPrice: items[index].discountPrice,
        notes: items[index].notes,
        isAvailable: items[index].isAvailable,
        maxQuantity: items[index].maxQuantity,
        createdAt: items[index].createdAt,
        updatedAt: DateTime.now(),
      );
      items.refresh();

      try {
        final cartData = await _cartRepository.updateCartItem(
          itemId: itemId,
          quantity: quantity,
        );

        cart.value = cartData;
        items.value = cartData.items;
        return true;
      } on ApiException catch (e) {
        // Revert optimistic update
        items[index] = CartItemModel(
          id: items[index].id,
          productId: items[index].productId,
          productName: items[index].productName,
          productImage: items[index].productImage,
          productSku: items[index].productSku,
          variantId: items[index].variantId,
          variantName: items[index].variantName,
          quantity: oldQuantity,
          unitPrice: items[index].unitPrice,
          discountPrice: items[index].discountPrice,
          notes: items[index].notes,
          isAvailable: items[index].isAvailable,
          maxQuantity: items[index].maxQuantity,
          createdAt: items[index].createdAt,
          updatedAt: items[index].updatedAt,
        );
        items.refresh();
        _showError(e.message);
        return false;
      } finally {
        isUpdating.value = false;
      }
    }

    isUpdating.value = false;
    return false;
  }

  /// Increment item quantity
  Future<bool> incrementQuantity(int itemId) async {
    final item = items.firstWhereOrNull((i) => i.id == itemId);
    if (item == null) return false;
    
    if (item.maxQuantity != null && item.quantity >= item.maxQuantity!) {
      _showError('Maximum quantity reached');
      return false;
    }
    
    return updateQuantity(itemId, item.quantity + 1);
  }

  /// Decrement item quantity
  Future<bool> decrementQuantity(int itemId) async {
    final item = items.firstWhereOrNull((i) => i.id == itemId);
    if (item == null) return false;
    
    return updateQuantity(itemId, item.quantity - 1);
  }

  /// Remove item from cart
  Future<bool> removeItem(int itemId) async {
    isUpdating.value = true;

    // Optimistic update
    final removedItem = items.firstWhereOrNull((item) => item.id == itemId);
    final removedIndex = items.indexWhere((item) => item.id == itemId);
    items.removeWhere((item) => item.id == itemId);

    try {
      final cartData = await _cartRepository.removeFromCart(itemId);
      cart.value = cartData;
      items.value = cartData.items;

      Get.snackbar(
        'Removed',
        'Item removed from cart',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.grey.shade100,
        colorText: Colors.grey.shade900,
        duration: const Duration(seconds: 2),
        mainButton: removedItem != null
            ? TextButton(
                onPressed: () => _undoRemove(removedItem),
                child: const Text('Undo'),
              )
            : null,
      );

      return true;
    } on ApiException catch (e) {
      // Revert optimistic update
      if (removedItem != null && removedIndex != -1) {
        items.insert(removedIndex, removedItem);
      }
      _showError(e.message);
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  /// Undo remove item
  Future<void> _undoRemove(CartItemModel item) async {
    await addToCart(
      productId: item.productId,
      quantity: item.quantity,
      variantId: item.variantId,
      notes: item.notes,
    );
  }

  /// Clear entire cart
  Future<bool> clearCart() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed != true) return false;

    isUpdating.value = true;

    try {
      await _cartRepository.clearCart();
      cart.value = null;
      items.clear();
      couponCode.value = '';
      hasCoupon.value = false;
      couponDiscount.value = 0.0;

      Get.snackbar(
        'Cart Cleared',
        'All items have been removed',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.grey.shade100,
        colorText: Colors.grey.shade900,
      );

      return true;
    } on ApiException catch (e) {
      _showError(e.message);
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  /// Apply coupon code
  Future<bool> applyCoupon(String code) async {
    if (code.isEmpty) {
      _showError('Please enter a coupon code');
      return false;
    }

    isUpdating.value = true;

    try {
      final result = await _cartRepository.applyCoupon(code);
      
      couponCode.value = code;
      hasCoupon.value = true;
      couponDiscount.value = result['discount'] ?? 0.0;
      
      // Reload cart to get updated totals
      await loadCart();

      Get.snackbar(
        'Coupon Applied',
        result['message'] ?? 'Discount applied successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );

      return true;
    } on ApiException catch (e) {
      _showError(e.message);
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  /// Remove coupon
  Future<bool> removeCoupon() async {
    isUpdating.value = true;

    try {
      await _cartRepository.removeCoupon();
      
      couponCode.value = '';
      hasCoupon.value = false;
      couponDiscount.value = 0.0;
      
      await loadCart();

      Get.snackbar(
        'Coupon Removed',
        'Discount has been removed',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.grey.shade100,
        colorText: Colors.grey.shade900,
      );

      return true;
    } on ApiException catch (e) {
      _showError(e.message);
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  /// Update item notes
  Future<bool> updateItemNotes(int itemId, String notes) async {
    try {
      await _cartRepository.updateItemNotes(itemId: itemId, notes: notes);
      
      final index = items.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        items[index] = CartItemModel(
          id: items[index].id,
          productId: items[index].productId,
          productName: items[index].productName,
          productImage: items[index].productImage,
          productSku: items[index].productSku,
          variantId: items[index].variantId,
          variantName: items[index].variantName,
          quantity: items[index].quantity,
          unitPrice: items[index].unitPrice,
          discountPrice: items[index].discountPrice,
          notes: notes,
          isAvailable: items[index].isAvailable,
          maxQuantity: items[index].maxQuantity,
          createdAt: items[index].createdAt,
          updatedAt: DateTime.now(),
        );
        items.refresh();
      }

      return true;
    } on ApiException catch (e) {
      _showError(e.message);
      return false;
    }
  }

  /// Move item to wishlist
  Future<bool> moveToWishlist(int itemId) async {
    isUpdating.value = true;

    try {
      await _cartRepository.moveToWishlist(itemId);
      
      items.removeWhere((item) => item.id == itemId);

      Get.snackbar(
        'Moved to Wishlist',
        'Item has been moved to your wishlist',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );

      return true;
    } on ApiException catch (e) {
      _showError(e.message);
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  /// Validate cart before checkout
  Future<Map<String, dynamic>> validateCart() async {
    try {
      return await _cartRepository.validateCart();
    } on ApiException catch (e) {
      _showError(e.message);
      return {'valid': false, 'message': e.message};
    }
  }

  /// Sync cart (for offline support)
  Future<void> syncCart(List<Map<String, dynamic>> localItems) async {
    isSyncing.value = true;

    try {
      final cartData = await _cartRepository.syncCart(localItems);
      cart.value = cartData;
      items.value = cartData.items;
    } on ApiException catch (e) {
      _showError(e.message);
    } finally {
      isSyncing.value = false;
    }
  }

  /// Check if product is in cart
  bool isInCart(int productId, {int? variantId}) {
    return items.any((item) =>
        item.productId == productId &&
        (variantId == null || item.variantId == variantId));
  }

  /// Get cart item by product ID
  CartItemModel? getCartItem(int productId, {int? variantId}) {
    return items.firstWhereOrNull((item) =>
        item.productId == productId &&
        (variantId == null || item.variantId == variantId));
  }

  /// Get quantity of product in cart
  int getProductQuantity(int productId, {int? variantId}) {
    final item = getCartItem(productId, variantId: variantId);
    return item?.quantity ?? 0;
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
