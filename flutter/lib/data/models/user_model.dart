/// User Model
class UserModel {
  final int id;
  final String name;
  final String email;
  final String? avatar;
  final String? avatarUrl;
  final String? address;
  final String? mobileNumber;
  final DateTime? dateOfBirth;
  final String userRole;
  final double? discountPercentage;
  final bool isApproved;
  final String? deviceToken;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.avatarUrl,
    this.address,
    this.mobileNumber,
    this.dateOfBirth,
    required this.userRole,
    this.discountPercentage,
    required this.isApproved,
    this.deviceToken,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'],
      avatarUrl: json['avatar_url'],
      address: json['address'],
      mobileNumber: json['mobile_number'],
      dateOfBirth: json['date_of_birth'] != null 
          ? DateTime.tryParse(json['date_of_birth']) 
          : null,
      userRole: json['user_role'] ?? 'user',
      discountPercentage: json['discount_percentage'] != null 
          ? double.tryParse(json['discount_percentage'].toString()) 
          : null,
      isApproved: json['is_approved'] ?? false,
      deviceToken: json['device_token'],
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
      'email': email,
      'avatar': avatar,
      'avatar_url': avatarUrl,
      'address': address,
      'mobile_number': mobileNumber,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'user_role': userRole,
      'discount_percentage': discountPercentage,
      'is_approved': isApproved,
      'device_token': deviceToken,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? avatar,
    String? avatarUrl,
    String? address,
    String? mobileNumber,
    DateTime? dateOfBirth,
    String? userRole,
    double? discountPercentage,
    bool? isApproved,
    String? deviceToken,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      address: address ?? this.address,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      userRole: userRole ?? this.userRole,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      isApproved: isApproved ?? this.isApproved,
      deviceToken: deviceToken ?? this.deviceToken,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if user is admin
  bool get isAdmin => userRole == 'admin' || userRole == 'super_admin';

  /// Check if user is super admin
  bool get isSuperAdmin => userRole == 'super_admin';

  /// Get display name (first name)
  String get firstName => name.split(' ').first;

  /// Get initials for avatar placeholder
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }
}
