import 'category_model.dart';
import 'subcategory_model.dart';
import 'media_model.dart';

/// Product Model
class ProductModel {
  final int id;
  final String name;
  final String? slug;
  final String? description;
  final String? shortDescription;
  final String? sku;
  final String? barcode;
  final double mrp;
  final double sellingPrice;
  final double? discountPrice;
  final double? discountPercentage;
  final bool inStock;
  final int stockQuantity;
  final int? minOrderQuantity;
  final int? maxOrderQuantity;
  final String? unit;
  final String? mainPhoto;
  final String? mainPhotoUrl;
  final List<ImageUrl> gallery;
  final int? categoryId;
  final int? subcategoryId;
  final CategoryModel? category;
  final SubCategoryModel? subcategory;
  final List<String> tags;
  final bool isFeatured;
  final bool isActive;
  final bool isWishlisted;
  final int viewCount;
  final int orderCount;
  final double? rating;
  final int reviewCount;
  final Map<String, dynamic>? specifications;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    this.slug,
    this.description,
    this.shortDescription,
    this.sku,
    this.barcode,
    required this.mrp,
    required this.sellingPrice,
    this.discountPrice,
    this.discountPercentage,
    this.inStock = true,
    this.stockQuantity = 0,
    this.minOrderQuantity,
    this.maxOrderQuantity,
    this.unit,
    this.mainPhoto,
    this.mainPhotoUrl,
    this.gallery = const [],
    this.categoryId,
    this.subcategoryId,
    this.category,
    this.subcategory,
    this.tags = const [],
    this.isFeatured = false,
    this.isActive = true,
    this.isWishlisted = false,
    this.viewCount = 0,
    this.orderCount = 0,
    this.rating,
    this.reviewCount = 0,
    this.specifications,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Parse gallery images
    List<ImageUrl> galleryImages = [];
    if (json['gallery'] != null) {
      if (json['gallery'] is List) {
        galleryImages = (json['gallery'] as List)
            .map((e) => ImageUrl.fromJson(e))
            .toList();
      }
    } else if (json['images'] != null && json['images'] is List) {
      galleryImages = (json['images'] as List)
          .map((e) => ImageUrl.fromJson(e))
          .toList();
    } else if (json['media'] != null && json['media'] is List) {
      galleryImages = (json['media'] as List)
          .where((e) => e['collection_name'] == 'gallery' || e['collection_name'] == 'images')
          .map((e) => ImageUrl(
                url: e['url'] ?? e['original_url'] ?? '',
                thumbnailUrl: e['thumbnail_url'] ?? e['thumb_url'],
              ))
          .toList();
    }

    // Parse tags
    List<String> tagsList = [];
    if (json['tags'] != null) {
      if (json['tags'] is List) {
        tagsList = (json['tags'] as List).map((e) => e.toString()).toList();
      } else if (json['tags'] is String) {
        tagsList = (json['tags'] as String).split(',').map((e) => e.trim()).toList();
      }
    }

    return ProductModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'],
      description: json['description'],
      shortDescription: json['short_description'],
      sku: json['sku'],
      barcode: json['barcode'],
      mrp: _parseDouble(json['mrp']) ?? _parseDouble(json['price']) ?? 0.0,
      sellingPrice: _parseDouble(json['selling_price']) ?? 
                   _parseDouble(json['sale_price']) ?? 
                   _parseDouble(json['price']) ?? 0.0,
      discountPrice: _parseDouble(json['discount_price']),
      discountPercentage: _parseDouble(json['discount_percentage']),
      inStock: json['in_stock'] ?? json['is_in_stock'] ?? true,
      stockQuantity: json['stock_quantity'] ?? json['stock'] ?? json['quantity'] ?? 0,
      minOrderQuantity: json['min_order_quantity'] ?? json['min_qty'],
      maxOrderQuantity: json['max_order_quantity'] ?? json['max_qty'],
      unit: json['unit'],
      mainPhoto: json['main_photo'] ?? json['image'],
      mainPhotoUrl: json['main_photo_url'] ?? json['image_url'] ?? json['photo_url'],
      gallery: galleryImages,
      categoryId: json['category_id'],
      subcategoryId: json['subcategory_id'] ?? json['sub_category_id'],
      category: json['category'] != null && json['category'] is Map
          ? CategoryModel.fromJson(json['category'])
          : null,
      subcategory: json['subcategory'] != null && json['subcategory'] is Map
          ? SubCategoryModel.fromJson(json['subcategory'])
          : (json['sub_category'] != null && json['sub_category'] is Map
              ? SubCategoryModel.fromJson(json['sub_category'])
              : null),
      tags: tagsList,
      isFeatured: json['is_featured'] ?? json['featured'] ?? false,
      isActive: json['is_active'] ?? json['active'] ?? true,
      isWishlisted: json['is_wishlisted'] ?? json['in_wishlist'] ?? false,
      viewCount: json['view_count'] ?? json['views'] ?? 0,
      orderCount: json['order_count'] ?? json['orders'] ?? 0,
      rating: _parseDouble(json['rating']) ?? _parseDouble(json['average_rating']),
      reviewCount: json['review_count'] ?? json['reviews_count'] ?? 0,
      specifications: json['specifications'] != null && json['specifications'] is Map
          ? Map<String, dynamic>.from(json['specifications'])
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
      'name': name,
      'slug': slug,
      'description': description,
      'short_description': shortDescription,
      'sku': sku,
      'barcode': barcode,
      'mrp': mrp,
      'selling_price': sellingPrice,
      'discount_price': discountPrice,
      'discount_percentage': discountPercentage,
      'in_stock': inStock,
      'stock_quantity': stockQuantity,
      'min_order_quantity': minOrderQuantity,
      'max_order_quantity': maxOrderQuantity,
      'unit': unit,
      'main_photo': mainPhoto,
      'main_photo_url': mainPhotoUrl,
      'gallery': gallery.map((e) => e.toJson()).toList(),
      'category_id': categoryId,
      'subcategory_id': subcategoryId,
      'tags': tags,
      'is_featured': isFeatured,
      'is_active': isActive,
      'is_wishlisted': isWishlisted,
      'view_count': viewCount,
      'order_count': orderCount,
      'rating': rating,
      'review_count': reviewCount,
      'specifications': specifications,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  ProductModel copyWith({
    int? id,
    String? name,
    String? slug,
    String? description,
    String? shortDescription,
    String? sku,
    String? barcode,
    double? mrp,
    double? sellingPrice,
    double? discountPrice,
    double? discountPercentage,
    bool? inStock,
    int? stockQuantity,
    int? minOrderQuantity,
    int? maxOrderQuantity,
    String? unit,
    String? mainPhoto,
    String? mainPhotoUrl,
    List<ImageUrl>? gallery,
    int? categoryId,
    int? subcategoryId,
    CategoryModel? category,
    SubCategoryModel? subcategory,
    List<String>? tags,
    bool? isFeatured,
    bool? isActive,
    bool? isWishlisted,
    int? viewCount,
    int? orderCount,
    double? rating,
    int? reviewCount,
    Map<String, dynamic>? specifications,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      shortDescription: shortDescription ?? this.shortDescription,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      mrp: mrp ?? this.mrp,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      discountPrice: discountPrice ?? this.discountPrice,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      inStock: inStock ?? this.inStock,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      minOrderQuantity: minOrderQuantity ?? this.minOrderQuantity,
      maxOrderQuantity: maxOrderQuantity ?? this.maxOrderQuantity,
      unit: unit ?? this.unit,
      mainPhoto: mainPhoto ?? this.mainPhoto,
      mainPhotoUrl: mainPhotoUrl ?? this.mainPhotoUrl,
      gallery: gallery ?? this.gallery,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      tags: tags ?? this.tags,
      isFeatured: isFeatured ?? this.isFeatured,
      isActive: isActive ?? this.isActive,
      isWishlisted: isWishlisted ?? this.isWishlisted,
      viewCount: viewCount ?? this.viewCount,
      orderCount: orderCount ?? this.orderCount,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      specifications: specifications ?? this.specifications,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get display image URL
  String get displayImage => mainPhotoUrl ?? mainPhoto ?? '';

  /// Get all images including main photo
  List<String> get allImages {
    final images = <String>[];
    if (displayImage.isNotEmpty) {
      images.add(displayImage);
    }
    for (var img in gallery) {
      if (img.url.isNotEmpty && !images.contains(img.url)) {
        images.add(img.url);
      }
    }
    return images;
  }

  /// Check if product has discount
  bool get hasDiscount => sellingPrice < mrp;

  /// Get discount percentage
  double get calculatedDiscountPercentage {
    if (discountPercentage != null) return discountPercentage!;
    if (!hasDiscount || mrp <= 0) return 0;
    return ((mrp - sellingPrice) / mrp * 100);
  }

  /// Get formatted discount percentage
  String get formattedDiscountPercentage {
    final discount = calculatedDiscountPercentage;
    if (discount <= 0) return '';
    return '${discount.toStringAsFixed(0)}% OFF';
  }

  /// Get savings amount
  double get savings => hasDiscount ? mrp - sellingPrice : 0;

  /// Get effective price (considering user discount if any)
  double getEffectivePrice(double? userDiscountPercentage) {
    if (userDiscountPercentage == null || userDiscountPercentage <= 0) {
      return sellingPrice;
    }
    return sellingPrice * (1 - userDiscountPercentage / 100);
  }

  /// Check if product is available for order
  bool get isAvailable => isActive && inStock && stockQuantity > 0;

  /// Get stock status text
  String get stockStatus {
    if (!inStock || stockQuantity <= 0) return 'Out of Stock';
    if (stockQuantity <= 5) return 'Low Stock';
    return 'In Stock';
  }

  /// Get category name
  String get categoryName => category?.name ?? '';

  /// Get subcategory name
  String get subcategoryName => subcategory?.name ?? '';
}
