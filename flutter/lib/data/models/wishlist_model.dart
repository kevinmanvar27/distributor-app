import 'product_model.dart';

/// Wishlist Item Model
class WishlistItemModel {
  final int id;
  final int? userId;
  final int productId;
  final ProductModel? product;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  WishlistItemModel({
    required this.id,
    this.userId,
    required this.productId,
    this.product,
    this.createdAt,
    this.updatedAt,
  });

  factory WishlistItemModel.fromJson(Map<String, dynamic> json) {
    return WishlistItemModel(
      id: json['id'] ?? 0,
      userId: json['user_id'],
      productId: json['product_id'] ?? 0,
      product: json['product'] != null && json['product'] is Map
          ? ProductModel.fromJson(json['product'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  WishlistItemModel copyWith({
    int? id,
    int? userId,
    int? productId,
    ProductModel? product,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WishlistItemModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      product: product ?? this.product,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get product name
  String get productName => product?.name ?? 'Product #$productId';

  /// Get product image
  String get productImage => product?.displayImage ?? '';

  /// Get product price
  double get productPrice => product?.sellingPrice ?? 0;

  /// Check if product is available
  bool get isAvailable => product?.isAvailable ?? true;

  /// Check if product is in stock
  bool get inStock => product?.inStock ?? true;
}

/// Wishlist Model (contains list of wishlist items)
class WishlistModel {
  final List<WishlistItemModel> items;
  final int totalCount;

  WishlistModel({
    this.items = const [],
    this.totalCount = 0,
  });

  factory WishlistModel.fromJson(Map<String, dynamic> json) {
    List<WishlistItemModel> wishlistItems = [];
    
    if (json['items'] != null && json['items'] is List) {
      wishlistItems = (json['items'] as List)
          .map((e) => WishlistItemModel.fromJson(e))
          .toList();
    } else if (json['data'] != null && json['data'] is List) {
      wishlistItems = (json['data'] as List)
          .map((e) => WishlistItemModel.fromJson(e))
          .toList();
    } else if (json['wishlist'] != null && json['wishlist'] is List) {
      wishlistItems = (json['wishlist'] as List)
          .map((e) => WishlistItemModel.fromJson(e))
          .toList();
    }

    return WishlistModel(
      items: wishlistItems,
      totalCount: json['total_count'] ?? 
                  json['total'] ?? 
                  wishlistItems.length,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((e) => e.toJson()).toList(),
      'total_count': totalCount,
    };
  }

  /// Check if wishlist is empty
  bool get isEmpty => items.isEmpty;

  /// Check if wishlist has items
  bool get isNotEmpty => items.isNotEmpty;

  /// Get count of items
  int get count => items.length;

  /// Check if product is in wishlist
  bool containsProduct(int productId) {
    return items.any((item) => item.productId == productId);
  }

  /// Find wishlist item by product ID
  WishlistItemModel? findByProductId(int productId) {
    try {
      return items.firstWhere((item) => item.productId == productId);
    } catch (_) {
      return null;
    }
  }

  /// Get all product IDs in wishlist
  List<int> get productIds {
    return items.map((item) => item.productId).toList();
  }

  /// Get available items only
  List<WishlistItemModel> get availableItems {
    return items.where((item) => item.isAvailable).toList();
  }

  /// Get unavailable items
  List<WishlistItemModel> get unavailableItems {
    return items.where((item) => !item.isAvailable).toList();
  }

  /// Get total value of wishlist items
  double get totalValue {
    return items.fold(0.0, (sum, item) => sum + item.productPrice);
  }
}
