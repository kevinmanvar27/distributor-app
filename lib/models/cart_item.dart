// Cart Item Model
// 
// Represents an item in the shopping cart.
// Contains product reference and quantity.

import '../core/utils/image_utils.dart';
import 'product.dart';

class CartItem {
  final int id;
  final int productId;
  final int quantity;
  final double price;
  final double? salePrice;
  final double? originalPrice;
  final int stock;
  final String? _name;
  final String? _imageUrl;
  final Product? product;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  CartItem({
    this.id = 0,
    required this.productId,
    required this.quantity,
    required this.price,
    this.salePrice,
    this.originalPrice,
    this.stock = 0,
    String? name,
    String? imageUrl,
    this.product,
    this.createdAt,
    this.updatedAt,
  }) : _name = name,
       _imageUrl = imageUrl;
  
  /// Create CartItem from JSON
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? json['product']?['id'] ?? 0,
      quantity: json['quantity'] ?? 1,
      price: _parseDouble(json['price'] ?? json['product']?['price']),
      salePrice: json['sale_price'] != null 
          ? _parseDouble(json['sale_price']) 
          : (json['product']?['sale_price'] != null 
              ? _parseDouble(json['product']['sale_price']) 
              : null),
      originalPrice: json['original_price'] != null 
          ? _parseDouble(json['original_price']) 
          : null,
      stock: json['stock'] ?? json['product']?['stock'] ?? 0,
      name: json['name'] ?? json['product']?['name'],
      imageUrl: json['image_url'] ?? json['product']?['image'],
      product: json['product'] != null 
          ? Product.fromJson(json['product']) 
          : null,
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at']) 
          : null,
    );
  }
  
  /// Parse double from various types
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
  
  /// Convert CartItem to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'quantity': quantity,
      'price': price,
      'sale_price': salePrice,
      'original_price': originalPrice,
      'stock': stock,
      'name': _name,
      'image_url': _imageUrl,
      // Product is not serialized to avoid circular references
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
  
  /// Get unit price (sale price if available)
  double get unitPrice => salePrice ?? price;
  
  /// Get total price for this cart item
  double get totalPrice => unitPrice * quantity;
  
  /// Get formatted unit price
  String get formattedUnitPrice => '\$${unitPrice.toStringAsFixed(2)}';
  
  /// Get formatted total price
  String get formattedTotalPrice => '\$${totalPrice.toStringAsFixed(2)}';
  
  /// Get product name
  String get productName => _name ?? product?.name ?? 'Unknown Product';
  
  /// Alias for productName (convenience getter)
  String get name => productName;
  
  /// Get product image with storage path prepended
  String? get productImage {
    final rawPath = _imageUrl ?? product?.imageUrl;
    return buildImageUrl(rawPath);
  }
  
  /// Alias for productImage (convenience getter)
  String? get imageUrl => productImage;
  
  /// Check if product is on sale
  bool get isOnSale => salePrice != null && salePrice! < price;
  
  /// Alias for isOnSale (convenience getter)
  bool get hasDiscount => isOnSale;
  
  /// Get the original price (non-nullable, falls back to price)
  double get displayOriginalPrice => originalPrice ?? price;
  
  /// Get discount percentage
  int get discountPercentage {
    if (!isOnSale) return 0;
    return (((price - salePrice!) / price) * 100).round();
  }
  
  /// Get discount amount for this cart item
  double get discountAmount {
    if (!isOnSale) return 0.0;
    return (price - salePrice!) * quantity;
  }
  
  /// Create a copy with updated fields
  CartItem copyWith({
    int? id,
    int? productId,
    int? quantity,
    double? price,
    double? salePrice,
    double? originalPrice,
    int? stock,
    String? name,
    String? imageUrl,
    Product? product,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      salePrice: salePrice ?? this.salePrice,
      originalPrice: originalPrice ?? this.originalPrice,
      stock: stock ?? this.stock,
      name: name ?? _name,
      imageUrl: imageUrl ?? _imageUrl,
      product: product ?? this.product,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  @override
  String toString() {
    return 'CartItem(id: $id, productId: $productId, quantity: $quantity, total: $totalPrice)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}
