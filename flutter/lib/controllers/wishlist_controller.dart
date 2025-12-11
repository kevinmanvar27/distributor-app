import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/data.dart';

/// Wishlist Controller
/// Manages wishlist state, items, and operations
class WishlistController extends GetxController {
  final WishlistRepository _wishlistRepository;

  WishlistController({
    WishlistRepository? wishlistRepository,
  }) : _wishlistRepository = wishlistRepository ?? WishlistRepository(Get.find());

  // Observable state
  final Rx<WishlistModel?> wishlist = Rx<WishlistModel?>(null);
  final RxList<WishlistItemModel> items = <WishlistItemModel>[].obs;
  final RxSet<int> wishlistProductIds = <int>{}.obs;
  
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isUpdating = false.obs;
  
  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxBool hasMore = true.obs;
  
  final RxString errorMessage = ''.obs;

  // Getters
  int get itemCount => items.length;
  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    loadWishlist();
    loadWishlistIds();
  }

  /// Load wishlist from API
  Future<void> loadWishlist({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      hasMore.value = true;
      items.clear();
    }

    if (!hasMore.value && !refresh) return;

    isLoading.value = refresh || items.isEmpty;
    isLoadingMore.value = !refresh && items.isNotEmpty;
    errorMessage.value = '';

    try {
      final response = await _wishlistRepository.getWishlist(
        page: currentPage.value,
        perPage: 20,
      );

      if (refresh) {
        items.value = response.data;
      } else {
        items.addAll(response.data);
      }

      currentPage.value = response.currentPage;
      totalPages.value = response.lastPage;
      hasMore.value = response.hasNextPage;

      // Update product IDs set
      wishlistProductIds.addAll(items.map((item) => item.productId));
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      if (!e.message.toLowerCase().contains('empty')) {
        _showError(e.message);
      }
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  /// Load more items (pagination)
  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;
    currentPage.value++;
    await loadWishlist();
  }

  /// Load wishlist product IDs (for quick lookup)
  Future<void> loadWishlistIds() async {
    try {
      final ids = await _wishlistRepository.getWishlistProductIds();
      wishlistProductIds.value = ids.toSet();
    } catch (e) {
      // Silently fail
    }
  }

  /// Add item to wishlist
  Future<bool> addToWishlist(int productId) async {
    isUpdating.value = true;

    // Optimistic update
    wishlistProductIds.add(productId);

    try {
      final item = await _wishlistRepository.addToWishlist(productId);
      items.insert(0, item);

      Get.snackbar(
        'Added to Wishlist',
        'Item has been added to your wishlist',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        duration: const Duration(seconds: 2),
        mainButton: TextButton(
          onPressed: () => Get.toNamed('/wishlist'),
          child: const Text('View'),
        ),
      );

      return true;
    } on ApiException catch (e) {
      // Revert optimistic update
      wishlistProductIds.remove(productId);
      _showError(e.message);
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  /// Remove item from wishlist
  Future<bool> removeFromWishlist(int productId) async {
    isUpdating.value = true;

    // Optimistic update
    final removedItem = items.firstWhereOrNull((item) => item.productId == productId);
    final removedIndex = items.indexWhere((item) => item.productId == productId);
    items.removeWhere((item) => item.productId == productId);
    wishlistProductIds.remove(productId);

    try {
      await _wishlistRepository.removeFromWishlist(productId);

      Get.snackbar(
        'Removed',
        'Item removed from wishlist',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.grey.shade100,
        colorText: Colors.grey.shade900,
        duration: const Duration(seconds: 2),
        mainButton: removedItem != null
            ? TextButton(
                onPressed: () => _undoRemove(productId),
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
      wishlistProductIds.add(productId);
      _showError(e.message);
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  /// Undo remove
  Future<void> _undoRemove(int productId) async {
    await addToWishlist(productId);
  }

  /// Toggle wishlist (add/remove)
  Future<bool> toggleWishlist(int productId) async {
    if (isInWishlist(productId)) {
      return removeFromWishlist(productId);
    } else {
      return addToWishlist(productId);
    }
  }

  /// Check if product is in wishlist
  bool isInWishlist(int productId) {
    return wishlistProductIds.contains(productId);
  }

  /// Move item to cart
  Future<bool> moveToCart(int productId, {int quantity = 1}) async {
    isUpdating.value = true;

    try {
      await _wishlistRepository.moveToCart(productId, quantity: quantity);
      
      items.removeWhere((item) => item.productId == productId);
      wishlistProductIds.remove(productId);

      Get.snackbar(
        'Moved to Cart',
        'Item has been moved to your cart',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        mainButton: TextButton(
          onPressed: () => Get.toNamed('/cart'),
          child: const Text('View Cart'),
        ),
      );

      // Refresh cart
      final cartController = Get.find<CartController>();
      await cartController.loadCart();

      return true;
    } on ApiException catch (e) {
      _showError(e.message);
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  /// Move all items to cart
  Future<bool> moveAllToCart() async {
    if (items.isEmpty) return false;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Move All to Cart'),
        content: Text('Move all ${items.length} items to your cart?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Move All'),
          ),
        ],
      ),
    );

    if (confirmed != true) return false;

    isUpdating.value = true;

    try {
      await _wishlistRepository.moveAllToCart();
      
      items.clear();
      wishlistProductIds.clear();

      Get.snackbar(
        'Moved to Cart',
        'All items have been moved to your cart',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        mainButton: TextButton(
          onPressed: () => Get.toNamed('/cart'),
          child: const Text('View Cart'),
        ),
      );

      // Refresh cart
      final cartController = Get.find<CartController>();
      await cartController.loadCart();

      return true;
    } on ApiException catch (e) {
      _showError(e.message);
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  /// Clear wishlist
  Future<bool> clearWishlist() async {
    if (items.isEmpty) return false;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Clear Wishlist'),
        content: const Text('Are you sure you want to remove all items from your wishlist?'),
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
      // Remove all items one by one (or implement bulk delete in API)
      for (final item in items.toList()) {
        await _wishlistRepository.removeFromWishlist(item.productId);
      }
      
      items.clear();
      wishlistProductIds.clear();

      Get.snackbar(
        'Wishlist Cleared',
        'All items have been removed',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.grey.shade100,
        colorText: Colors.grey.shade900,
      );

      return true;
    } on ApiException catch (e) {
      _showError(e.message);
      await loadWishlist(refresh: true);
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  /// Sync wishlist (for offline support)
  Future<void> syncWishlist(List<int> localProductIds) async {
    try {
      await _wishlistRepository.syncWishlist(localProductIds);
      await loadWishlist(refresh: true);
    } on ApiException catch (e) {
      _showError(e.message);
    }
  }

  /// Get wishlist item by product ID
  WishlistItemModel? getWishlistItem(int productId) {
    return items.firstWhereOrNull((item) => item.productId == productId);
  }

  /// Refresh wishlist
  Future<void> refresh() async {
    await loadWishlist(refresh: true);
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
