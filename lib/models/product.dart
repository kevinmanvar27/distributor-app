// Product Models
//
// Models for /products API response with pagination support
// Includes fromJson factories and computed getters

import '../core/utils/image_utils.dart';

class Products {
  bool success;
  ProductsData data;
  String message;

  Products({
    required this.success,
    required this.data,
    required this.message,
  });

  factory Products.fromJson(Map<String, dynamic> json) {
    return Products(
      success: json['success'] ?? false,
      data: ProductsData.fromJson(json['data'] ?? {}),
      message: json['message'] ?? '',
    );
  }
}

class ProductsData {
  int currentPage;
  List<Product> data;
  String firstPageUrl;
  int from;
  int lastPage;
  String lastPageUrl;
  List<Link> links;
  String? nextPageUrl;
  String path;
  int perPage;
  String? prevPageUrl;
  int to;
  int total;

  ProductsData({
    required this.currentPage,
    required this.data,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    required this.links,
    this.nextPageUrl,
    required this.path,
    required this.perPage,
    this.prevPageUrl,
    required this.to,
    required this.total,
  });

  factory ProductsData.fromJson(Map<String, dynamic> json) {
    return ProductsData(
      currentPage: json['current_page'] ?? 1,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => Product.fromJson(e))
          .toList() ?? [],
      firstPageUrl: json['first_page_url'] ?? '',
      from: json['from'] ?? 0,
      lastPage: json['last_page'] ?? 1,
      lastPageUrl: json['last_page_url'] ?? '',
      links: (json['links'] as List<dynamic>?)
          ?.map((e) => Link.fromJson(e))
          .toList() ?? [],
      nextPageUrl: json['next_page_url'],
      path: json['path'] ?? '',
      perPage: json['per_page'] ?? 10,
      prevPageUrl: json['prev_page_url'],
      to: json['to'] ?? 0,
      total: json['total'] ?? 0,
    );
  }

  /// Check if there are more pages
  bool get hasNextPage => nextPageUrl != null;
  
  /// Check if this is the first page
  bool get isFirstPage => currentPage == 1;
  
  /// Check if this is the last page
  bool get isLastPage => currentPage == lastPage;
}

class Product {
  int id;
  String name;
  String slug;
  String description;
  String mrp;
  String sellingPrice;
  bool inStock;
  int stockQuantity;
  String status;
  int? mainPhotoId;
  List<int> productGallery;
  dynamic productCategories;
  String? metaTitle;
  String? metaDescription;
  String? metaKeywords;
  DateTime createdAt;
  DateTime updatedAt;
  MainPhoto? mainPhoto;

  Product({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.mrp,
    required this.sellingPrice,
    required this.inStock,
    required this.stockQuantity,
    required this.status,
    this.mainPhotoId,
    required this.productGallery,
    this.productCategories,
    this.metaTitle,
    this.metaDescription,
    this.metaKeywords,
    required this.createdAt,
    required this.updatedAt,
    this.mainPhoto,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Parse product gallery
    List<int> gallery = [];
    if (json['product_gallery'] is List) {
      gallery = (json['product_gallery'] as List)
          .map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0)
          .toList();
    }

    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      mrp: json['mrp']?.toString() ?? '0',
      sellingPrice: json['selling_price']?.toString() ?? '0',
      inStock: json['in_stock'] ?? true,
      stockQuantity: json['stock_quantity'] ?? 0,
      status: json['status'] ?? '',
      mainPhotoId: json['main_photo_id'],
      productGallery: gallery,
      productCategories: json['product_categories'],
      metaTitle: json['meta_title'],
      metaDescription: json['meta_description'],
      metaKeywords: json['meta_keywords'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      mainPhoto: json['main_photo'] != null 
          ? MainPhoto.fromJson(json['main_photo']) 
          : null,
    );
  }

  /// Get full image URL using centralized helper
  String? get imageUrl => buildImageUrl(mainPhoto?.path);

  /// Get MRP as double
  double get mrpValue => double.tryParse(mrp) ?? 0;

  /// Alias for mrpValue (backwards compatibility)
  double get price => mrpValue;

  /// Get selling price as double
  double get sellingPriceValue => double.tryParse(sellingPrice) ?? 0;

  /// Alias for sellingPriceValue (backwards compatibility)
  double get salePrice => sellingPriceValue;

  /// Get display price (selling price)
  double get displayPrice => sellingPriceValue;

  /// Check if product has discount
  bool get hasDiscount => sellingPriceValue < mrpValue;

  /// Alias for hasDiscount
  bool get isOnSale => hasDiscount;

  /// Get discount percentage
  double get discountPercent {
    if (mrpValue <= 0) return 0;
    return ((mrpValue - sellingPriceValue) / mrpValue * 100).roundToDouble();
  }

  /// Get discount percentage as int
  int get discountPercentage => discountPercent.toInt();

  /// Check if product is in stock
  bool get isInStock => inStock && stockQuantity > 0;

  /// Check if product is out of stock
  bool get isOutOfStock => !isInStock;

  /// Get stock status
  int get stock => stockQuantity;

  /// Get primary image (alias for imageUrl)
  String? get primaryImage => imageUrl;

  /// Get formatted price string
  String get formattedPrice => '₹${mrpValue.toStringAsFixed(0)}';

  /// Get formatted sale price string
  String get formattedSalePrice => '₹${sellingPriceValue.toStringAsFixed(0)}';

  /// Get formatted display price
  String get formattedDisplayPrice => '₹${displayPrice.toStringAsFixed(0)}';

  @override
  String toString() {
    return 'Product(id: $id, name: $name, price: $mrpValue)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class MainPhoto {
  int id;
  String name;
  String fileName;
  String mimeType;
  String path;
  int size;
  DateTime createdAt;
  DateTime updatedAt;

  MainPhoto({
    required this.id,
    required this.name,
    required this.fileName,
    required this.mimeType,
    required this.path,
    required this.size,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MainPhoto.fromJson(Map<String, dynamic> json) {
    return MainPhoto(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      fileName: json['file_name'] ?? '',
      mimeType: json['mime_type'] ?? '',
      path: json['path'] ?? '',
      size: json['size'] ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  /// Get full URL for image using centralized helper
  String get fullUrl => buildImageUrl(path) ?? '';
}

class ProductCategory {
  String categoryId;
  List<String> subcategoryIds;

  ProductCategory({
    required this.categoryId,
    required this.subcategoryIds,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      categoryId: json['category_id']?.toString() ?? '',
      subcategoryIds: (json['subcategory_ids'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
    );
  }
}

class Link {
  String? url;
  String label;
  int? page;
  bool active;

  Link({
    this.url,
    required this.label,
    this.page,
    required this.active,
  });

  factory Link.fromJson(Map<String, dynamic> json) {
    return Link(
      url: json['url'],
      label: json['label'] ?? '',
      page: json['page'],
      active: json['active'] ?? false,
    );
  }
}
