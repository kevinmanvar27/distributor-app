import 'user_model.dart';
import 'product_model.dart';

/// Invoice Status Enum
enum InvoiceStatus {
  draft,
  approved,
  dispatch,
  outForDelivery,
  delivered,
  returned,
  cancelled;

  static InvoiceStatus fromString(String? status) {
    switch (status?.toLowerCase()) {
      case 'draft':
        return InvoiceStatus.draft;
      case 'approved':
        return InvoiceStatus.approved;
      case 'dispatch':
      case 'dispatched':
        return InvoiceStatus.dispatch;
      case 'out_for_delivery':
      case 'out for delivery':
      case 'outfordelivery':
        return InvoiceStatus.outForDelivery;
      case 'delivered':
        return InvoiceStatus.delivered;
      case 'return':
      case 'returned':
        return InvoiceStatus.returned;
      case 'cancelled':
      case 'canceled':
        return InvoiceStatus.cancelled;
      default:
        return InvoiceStatus.draft;
    }
  }

  String get displayName {
    switch (this) {
      case InvoiceStatus.draft:
        return 'Draft';
      case InvoiceStatus.approved:
        return 'Approved';
      case InvoiceStatus.dispatch:
        return 'Dispatched';
      case InvoiceStatus.outForDelivery:
        return 'Out for Delivery';
      case InvoiceStatus.delivered:
        return 'Delivered';
      case InvoiceStatus.returned:
        return 'Returned';
      case InvoiceStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get apiValue {
    switch (this) {
      case InvoiceStatus.draft:
        return 'Draft';
      case InvoiceStatus.approved:
        return 'Approved';
      case InvoiceStatus.dispatch:
        return 'Dispatch';
      case InvoiceStatus.outForDelivery:
        return 'Out for Delivery';
      case InvoiceStatus.delivered:
        return 'Delivered';
      case InvoiceStatus.returned:
        return 'Return';
      case InvoiceStatus.cancelled:
        return 'Cancelled';
    }
  }

  bool get isActive => this != InvoiceStatus.cancelled && 
                       this != InvoiceStatus.delivered && 
                       this != InvoiceStatus.returned;

  bool get canCancel => this == InvoiceStatus.draft || 
                        this == InvoiceStatus.approved;

  bool get canReturn => this == InvoiceStatus.delivered;
}

/// Invoice Item Model
class InvoiceItemModel {
  final int id;
  final int? invoiceId;
  final int productId;
  final String productName;
  final String? productSku;
  final String? productImage;
  final int quantity;
  final double unitPrice;
  final double? discountedPrice;
  final double totalPrice;
  final ProductModel? product;

  InvoiceItemModel({
    required this.id,
    this.invoiceId,
    required this.productId,
    required this.productName,
    this.productSku,
    this.productImage,
    required this.quantity,
    required this.unitPrice,
    this.discountedPrice,
    required this.totalPrice,
    this.product,
  });

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return InvoiceItemModel(
      id: json['id'] ?? 0,
      invoiceId: json['invoice_id'] ?? json['proforma_invoice_id'],
      productId: json['product_id'] ?? 0,
      productName: json['product_name'] ?? json['name'] ?? '',
      productSku: json['product_sku'] ?? json['sku'],
      productImage: json['product_image'] ?? json['image'],
      quantity: json['quantity'] ?? 1,
      unitPrice: _parseDouble(json['unit_price']) ?? 
                 _parseDouble(json['price']) ?? 0.0,
      discountedPrice: _parseDouble(json['discounted_price']),
      totalPrice: _parseDouble(json['total_price']) ?? 
                  _parseDouble(json['total']) ?? 0.0,
      product: json['product'] != null && json['product'] is Map
          ? ProductModel.fromJson(json['product'])
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
      'invoice_id': invoiceId,
      'product_id': productId,
      'product_name': productName,
      'product_sku': productSku,
      'product_image': productImage,
      'quantity': quantity,
      'unit_price': unitPrice,
      'discounted_price': discountedPrice,
      'total_price': totalPrice,
    };
  }

  /// Get effective unit price
  double get effectivePrice => discountedPrice ?? unitPrice;

  /// Get savings
  double get savings {
    if (discountedPrice == null || discountedPrice! >= unitPrice) return 0;
    return (unitPrice - discountedPrice!) * quantity;
  }
}

/// Proforma Invoice Model
class ProformaInvoiceModel {
  final int id;
  final String invoiceNumber;
  final int? userId;
  final UserModel? user;
  final List<InvoiceItemModel> items;
  final double subtotal;
  final double discount;
  final double? discountPercentage;
  final double tax;
  final double? taxPercentage;
  final double shipping;
  final double totalAmount;
  final InvoiceStatus status;
  final String? notes;
  final String? shippingAddress;
  final String? billingAddress;
  final String? paymentMethod;
  final String? paymentStatus;
  final String? trackingNumber;
  final String? courierName;
  final Map<String, dynamic>? invoiceData;
  final DateTime? invoiceDate;
  final DateTime? approvedAt;
  final DateTime? dispatchedAt;
  final DateTime? deliveredAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProformaInvoiceModel({
    required this.id,
    required this.invoiceNumber,
    this.userId,
    this.user,
    this.items = const [],
    this.subtotal = 0,
    this.discount = 0,
    this.discountPercentage,
    this.tax = 0,
    this.taxPercentage,
    this.shipping = 0,
    required this.totalAmount,
    required this.status,
    this.notes,
    this.shippingAddress,
    this.billingAddress,
    this.paymentMethod,
    this.paymentStatus,
    this.trackingNumber,
    this.courierName,
    this.invoiceData,
    this.invoiceDate,
    this.approvedAt,
    this.dispatchedAt,
    this.deliveredAt,
    this.createdAt,
    this.updatedAt,
  });

  factory ProformaInvoiceModel.fromJson(Map<String, dynamic> json) {
    List<InvoiceItemModel> invoiceItems = [];
    
    if (json['items'] != null && json['items'] is List) {
      invoiceItems = (json['items'] as List)
          .map((e) => InvoiceItemModel.fromJson(e))
          .toList();
    } else if (json['invoice_items'] != null && json['invoice_items'] is List) {
      invoiceItems = (json['invoice_items'] as List)
          .map((e) => InvoiceItemModel.fromJson(e))
          .toList();
    } else if (json['invoice_data'] != null && 
               json['invoice_data'] is Map &&
               json['invoice_data']['items'] != null) {
      invoiceItems = (json['invoice_data']['items'] as List)
          .map((e) => InvoiceItemModel.fromJson(e))
          .toList();
    }

    return ProformaInvoiceModel(
      id: json['id'] ?? 0,
      invoiceNumber: json['invoice_number'] ?? json['order_number'] ?? '',
      userId: json['user_id'],
      user: json['user'] != null && json['user'] is Map
          ? UserModel.fromJson(json['user'])
          : null,
      items: invoiceItems,
      subtotal: _parseDouble(json['subtotal']) ?? 
                _parseDouble(json['sub_total']) ?? 0.0,
      discount: _parseDouble(json['discount']) ?? 
                _parseDouble(json['discount_amount']) ?? 0.0,
      discountPercentage: _parseDouble(json['discount_percentage']),
      tax: _parseDouble(json['tax']) ?? 
           _parseDouble(json['tax_amount']) ?? 0.0,
      taxPercentage: _parseDouble(json['tax_percentage']),
      shipping: _parseDouble(json['shipping']) ?? 
                _parseDouble(json['shipping_cost']) ?? 0.0,
      totalAmount: _parseDouble(json['total_amount']) ?? 
                   _parseDouble(json['total']) ?? 
                   _parseDouble(json['grand_total']) ?? 0.0,
      status: InvoiceStatus.fromString(json['status']),
      notes: json['notes'] ?? json['remarks'],
      shippingAddress: json['shipping_address'],
      billingAddress: json['billing_address'],
      paymentMethod: json['payment_method'],
      paymentStatus: json['payment_status'],
      trackingNumber: json['tracking_number'],
      courierName: json['courier_name'] ?? json['courier'],
      invoiceData: json['invoice_data'] != null && json['invoice_data'] is Map
          ? Map<String, dynamic>.from(json['invoice_data'])
          : null,
      invoiceDate: json['invoice_date'] != null
          ? DateTime.tryParse(json['invoice_date'])
          : null,
      approvedAt: json['approved_at'] != null
          ? DateTime.tryParse(json['approved_at'])
          : null,
      dispatchedAt: json['dispatched_at'] != null
          ? DateTime.tryParse(json['dispatched_at'])
          : null,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.tryParse(json['delivered_at'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
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
      'id': id,
      'invoice_number': invoiceNumber,
      'user_id': userId,
      'items': items.map((e) => e.toJson()).toList(),
      'subtotal': subtotal,
      'discount': discount,
      'discount_percentage': discountPercentage,
      'tax': tax,
      'tax_percentage': taxPercentage,
      'shipping': shipping,
      'total_amount': totalAmount,
      'status': status.apiValue,
      'notes': notes,
      'shipping_address': shippingAddress,
      'billing_address': billingAddress,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'tracking_number': trackingNumber,
      'courier_name': courierName,
      'invoice_data': invoiceData,
      'invoice_date': invoiceDate?.toIso8601String(),
      'approved_at': approvedAt?.toIso8601String(),
      'dispatched_at': dispatchedAt?.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  ProformaInvoiceModel copyWith({
    int? id,
    String? invoiceNumber,
    int? userId,
    UserModel? user,
    List<InvoiceItemModel>? items,
    double? subtotal,
    double? discount,
    double? discountPercentage,
    double? tax,
    double? taxPercentage,
    double? shipping,
    double? totalAmount,
    InvoiceStatus? status,
    String? notes,
    String? shippingAddress,
    String? billingAddress,
    String? paymentMethod,
    String? paymentStatus,
    String? trackingNumber,
    String? courierName,
    Map<String, dynamic>? invoiceData,
    DateTime? invoiceDate,
    DateTime? approvedAt,
    DateTime? dispatchedAt,
    DateTime? deliveredAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProformaInvoiceModel(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      userId: userId ?? this.userId,
      user: user ?? this.user,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      tax: tax ?? this.tax,
      taxPercentage: taxPercentage ?? this.taxPercentage,
      shipping: shipping ?? this.shipping,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      billingAddress: billingAddress ?? this.billingAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      courierName: courierName ?? this.courierName,
      invoiceData: invoiceData ?? this.invoiceData,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      approvedAt: approvedAt ?? this.approvedAt,
      dispatchedAt: dispatchedAt ?? this.dispatchedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get total item count
  int get itemCount => items.length;

  /// Get total quantity
  int get totalQuantity {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  /// Get total savings
  double get totalSavings {
    return items.fold(0.0, (sum, item) => sum + item.savings) + discount;
  }

  /// Check if invoice can be cancelled
  bool get canCancel => status.canCancel;

  /// Check if invoice can be returned
  bool get canReturn => status.canReturn;

  /// Check if invoice is active (not completed/cancelled)
  bool get isActive => status.isActive;

  /// Get status color (returns hex string)
  String get statusColor {
    switch (status) {
      case InvoiceStatus.draft:
        return '#9E9E9E'; // Grey
      case InvoiceStatus.approved:
        return '#2196F3'; // Blue
      case InvoiceStatus.dispatch:
        return '#FF9800'; // Orange
      case InvoiceStatus.outForDelivery:
        return '#9C27B0'; // Purple
      case InvoiceStatus.delivered:
        return '#4CAF50'; // Green
      case InvoiceStatus.returned:
        return '#F44336'; // Red
      case InvoiceStatus.cancelled:
        return '#757575'; // Dark Grey
    }
  }

  /// Get formatted date
  String get formattedDate {
    final date = invoiceDate ?? createdAt;
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Get user name
  String get userName => user?.name ?? '';
}
