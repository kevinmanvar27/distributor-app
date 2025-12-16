import 'media_model.dart';

/// SubCategory Model
class SubCategoryModel {
  final int id;
  final String name;
  final String? slug;
  final String? description;
  final String? image;
  final String? imageUrl;
  final int? categoryId;
  final int sortOrder;
  final bool isActive;
  final int productCount;
  final MediaModel? media;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SubCategoryModel({
    required this.id,
    required this.name,
    this.slug,
    this.description,
    this.image,
    this.imageUrl,
    this.categoryId,
    this.sortOrder = 0,
    this.isActive = true,
    this.productCount = 0,
    this.media,
    this.createdAt,
    this.updatedAt,
  });

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'],
      description: json['description'],
      image: json['image'],
      imageUrl: json['image_url'] ?? json['photo_url'],
      categoryId: json['category_id'] ?? json['parent_id'],
      sortOrder: json['sort_order'] ?? json['order'] ?? 0,
      isActive: json['is_active'] ?? json['active'] ?? true,
      productCount: json['products_count'] ?? json['product_count'] ?? 0,
      media: json['media'] != null && json['media'] is Map
          ? MediaModel.fromJson(json['media'])
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
      'name': name,
      'slug': slug,
      'description': description,
      'image': image,
      'image_url': imageUrl,
      'category_id': categoryId,
      'sort_order': sortOrder,
      'is_active': isActive,
      'products_count': productCount,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  SubCategoryModel copyWith({
    int? id,
    String? name,
    String? slug,
    String? description,
    String? image,
    String? imageUrl,
    int? categoryId,
    int? sortOrder,
    bool? isActive,
    int? productCount,
    MediaModel? media,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SubCategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      image: image ?? this.image,
      imageUrl: imageUrl ?? this.imageUrl,
      categoryId: categoryId ?? this.categoryId,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      productCount: productCount ?? this.productCount,
      media: media ?? this.media,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get display image URL
  String get displayImage => imageUrl ?? image ?? '';
}
