import 'subcategory_model.dart';
import 'media_model.dart';

/// Category Model
class CategoryModel {
  final int id;
  final String name;
  final String? slug;
  final String? description;
  final String? image;
  final String? imageUrl;
  final int? parentId;
  final int sortOrder;
  final bool isActive;
  final int productCount;
  final List<SubCategoryModel> subcategories;
  final MediaModel? media;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CategoryModel({
    required this.id,
    required this.name,
    this.slug,
    this.description,
    this.image,
    this.imageUrl,
    this.parentId,
    this.sortOrder = 0,
    this.isActive = true,
    this.productCount = 0,
    this.subcategories = const [],
    this.media,
    this.createdAt,
    this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    List<SubCategoryModel> subs = [];
    if (json['subcategories'] != null) {
      subs = (json['subcategories'] as List)
          .map((e) => SubCategoryModel.fromJson(e))
          .toList();
    } else if (json['children'] != null) {
      subs = (json['children'] as List)
          .map((e) => SubCategoryModel.fromJson(e))
          .toList();
    }

    return CategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'],
      description: json['description'],
      image: json['image'],
      imageUrl: json['image_url'] ?? json['photo_url'],
      parentId: json['parent_id'],
      sortOrder: json['sort_order'] ?? json['order'] ?? 0,
      isActive: json['is_active'] ?? json['active'] ?? true,
      productCount: json['products_count'] ?? json['product_count'] ?? 0,
      subcategories: subs,
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
      'parent_id': parentId,
      'sort_order': sortOrder,
      'is_active': isActive,
      'products_count': productCount,
      'subcategories': subcategories.map((e) => e.toJson()).toList(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  CategoryModel copyWith({
    int? id,
    String? name,
    String? slug,
    String? description,
    String? image,
    String? imageUrl,
    int? parentId,
    int? sortOrder,
    bool? isActive,
    int? productCount,
    List<SubCategoryModel>? subcategories,
    MediaModel? media,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      image: image ?? this.image,
      imageUrl: imageUrl ?? this.imageUrl,
      parentId: parentId ?? this.parentId,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      productCount: productCount ?? this.productCount,
      subcategories: subcategories ?? this.subcategories,
      media: media ?? this.media,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get display image URL
  String get displayImage => imageUrl ?? image ?? '';

  /// Check if category has subcategories
  bool get hasSubcategories => subcategories.isNotEmpty;

  /// Get total products including subcategories
  int get totalProducts {
    int total = productCount;
    for (var sub in subcategories) {
      total += sub.productCount;
    }
    return total;
  }
}
