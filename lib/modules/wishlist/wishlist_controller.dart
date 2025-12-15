// 
// WishlistController - Manages wishlist state using GetX
// Features:
// - Add/remove products from wishlist
// - Persist wishlist while app is running
// - Reactive state for UI updates
// - Snackbar feedback

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/product.dart';
import '../../core/services/storage_service.dart';
import 'dart:convert';

class WishlistController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  
  /// Reactive list of wishlist products
  final RxList<Product> wishlistItems = <Product>[].obs;
  
  /// Loading state
  final RxBool isLoading = false.obs;
  
  // Storage key for wishlist
  static const String _wishlistKey = 'wishlist_items';
  
  @override
  void onInit() {
    super.onInit();
    _loadWishlistFromStorage();
  }
  
  /// Load wishlist from local storage
  Future<void> _loadWishlistFromStorage() async {
    try {
      isLoading.value = true;
      final String? wishlistJson = _storage.getString(_wishlistKey);
      
      if (wishlistJson != null && wishlistJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(wishlistJson);
        wishlistItems.value = decoded
            .map((item) => Product.fromJson(item))
            .toList();
      }
    } catch (e) {
      debugPrint('WishlistController: Error loading wishlist: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Save wishlist to local storage
  Future<void> _saveWishlistToStorage() async {
    try {
      final List<Map<String, dynamic>> wishlistData = wishlistItems
          .map((product) => _productToJson(product))
          .toList();
      await _storage.saveString(_wishlistKey, jsonEncode(wishlistData));
    } catch (e) {
      debugPrint('WishlistController: Error saving wishlist: $e');
    }
  }
  
  /// Convert Product to JSON for storage
  Map<String, dynamic> _productToJson(Product product) {
    return {
      'id': product.id,
      'name': product.name,
      'slug': product.slug,
      'description': product.description,
      'mrp': product.mrp,
      'selling_price': product.sellingPrice,
      'in_stock': product.inStock,
      'stock_quantity': product.stockQuantity,
      'status': product.status,
      'main_photo_id': product.mainPhotoId,
      'product_gallery': product.productGallery,
      'product_categories': product.productCategories,
      'meta_title': product.metaTitle,
      'meta_description': product.metaDescription,
      'meta_keywords': product.metaKeywords,
      'created_at': product.createdAt.toIso8601String(),
      'updated_at': product.updatedAt.toIso8601String(),
      'main_photo': product.mainPhoto != null ? {
        'id': product.mainPhoto!.id,
        'name': product.mainPhoto!.name,
        'file_name': product.mainPhoto!.fileName,
        'mime_type': product.mainPhoto!.mimeType,
        'path': product.mainPhoto!.path,
        'size': product.mainPhoto!.size,
        'created_at': product.mainPhoto!.createdAt.toIso8601String(),
        'updated_at': product.mainPhoto!.updatedAt.toIso8601String(),
      } : null,
    };
  }
  
  /// Check if a product is in the wishlist
  bool isInWishlist(int productId) {
    return wishlistItems.any((item) => item.id == productId);
  }
  
  /// Toggle wishlist status for a product
  void toggleWishlist(Product product) {
    if (isInWishlist(product.id)) {
      removeFromWishlist(product.id);
    } else {
      addToWishlist(product);
    }
  }
  
  /// Add a product to the wishlist
  void addToWishlist(Product product) {
    // Check for duplicates
    if (isInWishlist(product.id)) {
      _showSnackbar('Already in Wishlist', 'This product is already in your wishlist');
      return;
    }
    
    wishlistItems.add(product);
    _saveWishlistToStorage();
    
    _showSnackbar(
      'Added to Wishlist',
      '${product.name} has been added to your wishlist',
      icon: Icons.favorite,
      iconColor: Colors.red,
    );
  }
  
  /// Remove a product from the wishlist
  void removeFromWishlist(int productId) {
    final product = wishlistItems.firstWhereOrNull((item) => item.id == productId);
    if (product != null) {
      wishlistItems.removeWhere((item) => item.id == productId);
      _saveWishlistToStorage();
      
      _showSnackbar(
        'Removed from Wishlist',
        '${product.name} has been removed from your wishlist',
        icon: Icons.favorite_border,
      );
    }
  }
  
  /// Clear all wishlist items
  void clearWishlist() {
    wishlistItems.clear();
    _saveWishlistToStorage();
    
    _showSnackbar(
      'Wishlist Cleared',
      'All items have been removed from your wishlist',
    );
  }
  
  /// Get wishlist count
  int get wishlistCount => wishlistItems.length;
  
  /// Check if wishlist is empty
  bool get isEmpty => wishlistItems.isEmpty;
  
  /// Show snackbar notification
  void _showSnackbar(
    String title,
    String message, {
    IconData? icon,
    Color? iconColor,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(12),
      borderRadius: 8,
      icon: icon != null
          ? Icon(icon, color: iconColor ?? Colors.white)
          : null,
    );
  }
}
