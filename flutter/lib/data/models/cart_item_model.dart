import 'product_model.dart';

/// Cart Item Model
class CartItemModel {
  final int id;
  final int? userId;
  final int productId;
  final int quantity;
  final double price;
  final double? discountedPrice;
  final ProductModel? product;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CartItemModel({
    required this.id,
    this.userId,
    required this.productId,
    required this.quantity,
    required this.price,
    this.discountedPrice,
    this.product,
    this.createdAt,
    this.updatedAt,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] ?? 0,
      userId: json['user_id'],
      productId: json['product_id'] ?? 0,
      quantity: json['quantity'] ?? 1,
      price: _parseDouble(json['price']) ?? 
             _parseDouble(json['unit_price']) ?? 0.0,
      discountedPrice: _parseDouble(json['discounted_price']) ?? 
                       _parseDouble(json['sale_price']),
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

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'quantity': quantity,
      'price': price,
      'discounted_price': discountedPrice,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  CartItemModel copyWith({
    int? id,
    int? userId,
    int? productId,
    int? quantity,
    double? price,
    double? discountedPrice,
    ProductModel? product,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      product: product ?? this.product,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get effective unit price
  double get effectivePrice => discountedPrice ?? price;

  /// Get total price for this item
  double get totalPrice => effectivePrice * quantity;

  /// Get total MRP for this item
  double get totalMrp => price * quantity;

  /// Get savings for this item
  double get savings {
    if (discountedPrice == null || discountedPrice! >= price) return 0;
    return (price - discountedPrice!) * quantity;
  }

  /// Get product name
  String get productName => product?.name ?? 'Product #$productId';

  /// Get product image
  String get productImage => product?.displayImage ?? '';

  /// Check if item is available
  bool get isAvailable => product?.isAvailable ?? true;

  /// Check if quantity exceeds stock
  bool get exceedsStock {
    if (product == null) return false;
    return quantity > product!.stockQuantity;
  }

  /// Get maximum available quantity
  int get maxQuantity {
    if (product == null) return 999;
    return product!.maxOrderQuantity ?? product!.stockQuantity;
  }

  /// Get minimum order quantity
  int get minQuantity => product?.minOrderQuantity ?? 1;
}

/// Cart Model (contains list of cart items)
class CartModel {
  final List<CartItemModel> items;
  final double subtotal;
  final double discount;
  final double tax;
  final double shipping;
  final double total;
  final int itemCount;
  final String? couponCode;
  final double? couponDiscount;

  CartModel({
    this.items = const [],
    this.subtotal = 0,
    this.discount = 0,
    this.tax = 0,
    this.shipping = 0,
    this.total = 0,
    this.itemCount = 0,
    this.couponCode,
    this.couponDiscount,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    List<CartItemModel> cartItems = [];
    if (json['items'] != null && json['items'] is List) {
      cartItems = (json['items'] as List)
          .map((e) => CartItemModel.fromJson(e))
          .toList();
    } else if (json['cart_items'] != null && json['cart_items'] is List) {
      cartItems = (json['cart_items'] as List)
          .map((e) => CartItemModel.fromJson(e))
          .toList();
    }

    return CartModel(
      items: cartItems,
      subtotal: _parseDouble(json['subtotal']) ?? 
                _parseDouble(json['sub_total']) ?? 0.0,
      discount: _parseDouble(json['discount']) ?? 0.0,
      tax: _parseDouble(json['tax']) ?? 
           _parseDouble(json['tax_amount']) ?? 0.0,
      shipping: _parseDouble(json['shipping']) ?? 
                _parseDouble(json['shipping_cost']) ?? 0.0,
      total: _parseDouble(json['total']) ?? 
             _parseDouble(json['grand_total']) ?? 0.0,
      itemCount: json['item_count'] ?? json['items_count'] ?? cartItems.length,
      couponCode: json['coupon_code'],
      couponDiscount: _parseDouble(json['coupon_discount']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((e) => e.toJson()).toList(),
      'subtotal': subtotal,
      'discount': discount,
      'tax': tax,
      'shipping': shipping,
      'total': total,
      'item_count': itemCount,
      'coupon_code': couponCode,
      'coupon_discount': couponDiscount,
    };
  }

  /// Check if cart is empty
  bool get isEmpty => items.isEmpty;

  /// Check if cart has items
  bool get isNotEmpty => items.isNotEmpty;

  /// Get total quantity of all items
  int get totalQuantity {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  /// Get total savings
  double get totalSavings {
    return items.fold(0.0, (sum, item) => sum + item.savings) + discount;
  }

  /// Calculate subtotal from items
  double get calculatedSubtotal {
    return items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  /// Check if any item is unavailable
  bool get hasUnavailableItems {
    return items.any((item) => !item.isAvailable);
  }

  /// Get unavailable items
  List<CartItemModel> get unavailableItems {
    return items.where((item) => !item.isAvailable).toList();
  }

  /// Find cart item by product ID
  CartItemModel? findByProductId(int productId) {
    try {
      return items.firstWhere((item) => item.productId == productId);
    } catch (_) {
      return null;
    }
  }

  /// Check if product is in cart
  bool containsProduct(int productId) {
    return items.any((item) => item.productId == productId);
  }

  /// Get quantity of a product in cart
  int getProductQuantity(int productId) {
    final item = findByProductId(productId);
    return item?.quantity ?? 0;
  }
}
