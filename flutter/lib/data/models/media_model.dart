/// Media Model for handling images and files
class MediaModel {
  final int id;
  final String? modelType;
  final int? modelId;
  final String? uuid;
  final String collectionName;
  final String name;
  final String fileName;
  final String? mimeType;
  final String? disk;
  final String? conversionsDisk;
  final int size;
  final Map<String, dynamic>? manipulations;
  final Map<String, dynamic>? customProperties;
  final Map<String, dynamic>? generatedConversions;
  final Map<String, dynamic>? responsiveImages;
  final int? orderColumn;
  final String? url;
  final String? thumbnailUrl;
  final String? previewUrl;
  final String? originalUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MediaModel({
    required this.id,
    this.modelType,
    this.modelId,
    this.uuid,
    required this.collectionName,
    required this.name,
    required this.fileName,
    this.mimeType,
    this.disk,
    this.conversionsDisk,
    required this.size,
    this.manipulations,
    this.customProperties,
    this.generatedConversions,
    this.responsiveImages,
    this.orderColumn,
    this.url,
    this.thumbnailUrl,
    this.previewUrl,
    this.originalUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    return MediaModel(
      id: json['id'] ?? 0,
      modelType: json['model_type'],
      modelId: json['model_id'],
      uuid: json['uuid'],
      collectionName: json['collection_name'] ?? 'default',
      name: json['name'] ?? '',
      fileName: json['file_name'] ?? '',
      mimeType: json['mime_type'],
      disk: json['disk'],
      conversionsDisk: json['conversions_disk'],
      size: json['size'] ?? 0,
      manipulations: json['manipulations'] != null
          ? Map<String, dynamic>.from(json['manipulations'])
          : null,
      customProperties: json['custom_properties'] != null
          ? Map<String, dynamic>.from(json['custom_properties'])
          : null,
      generatedConversions: json['generated_conversions'] != null
          ? Map<String, dynamic>.from(json['generated_conversions'])
          : null,
      responsiveImages: json['responsive_images'] != null
          ? Map<String, dynamic>.from(json['responsive_images'])
          : null,
      orderColumn: json['order_column'],
      url: json['url'],
      thumbnailUrl: json['thumbnail_url'] ?? json['thumb_url'],
      previewUrl: json['preview_url'],
      originalUrl: json['original_url'],
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
      'model_type': modelType,
      'model_id': modelId,
      'uuid': uuid,
      'collection_name': collectionName,
      'name': name,
      'file_name': fileName,
      'mime_type': mimeType,
      'disk': disk,
      'conversions_disk': conversionsDisk,
      'size': size,
      'manipulations': manipulations,
      'custom_properties': customProperties,
      'generated_conversions': generatedConversions,
      'responsive_images': responsiveImages,
      'order_column': orderColumn,
      'url': url,
      'thumbnail_url': thumbnailUrl,
      'preview_url': previewUrl,
      'original_url': originalUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Get the best available URL for display
  String get displayUrl => url ?? originalUrl ?? thumbnailUrl ?? '';

  /// Get thumbnail or fallback to main URL
  String get thumbUrl => thumbnailUrl ?? url ?? originalUrl ?? '';

  /// Check if media is an image
  bool get isImage {
    final mime = mimeType?.toLowerCase() ?? '';
    return mime.startsWith('image/');
  }

  /// Check if media is a video
  bool get isVideo {
    final mime = mimeType?.toLowerCase() ?? '';
    return mime.startsWith('video/');
  }

  /// Check if media is a PDF
  bool get isPdf {
    final mime = mimeType?.toLowerCase() ?? '';
    return mime == 'application/pdf';
  }

  /// Get human readable file size
  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Get file extension
  String get extension {
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }
}

/// Simple image URL model for product galleries
class ImageUrl {
  final String url;
  final String? thumbnailUrl;
  final String? alt;

  ImageUrl({
    required this.url,
    this.thumbnailUrl,
    this.alt,
  });

  factory ImageUrl.fromJson(dynamic json) {
    if (json is String) {
      return ImageUrl(url: json);
    }
    if (json is Map<String, dynamic>) {
      return ImageUrl(
        url: json['url'] ?? json['original_url'] ?? '',
        thumbnailUrl: json['thumbnail_url'] ?? json['thumb_url'],
        alt: json['alt'] ?? json['name'],
      );
    }
    return ImageUrl(url: '');
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'thumbnail_url': thumbnailUrl,
      'alt': alt,
    };
  }

  String get displayUrl => url.isNotEmpty ? url : thumbnailUrl ?? '';
  String get thumbUrl => thumbnailUrl ?? url;
}
