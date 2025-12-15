// User Model
// 
// Represents a user in the system.
// Used for authentication and profile display.

import '../core/utils/image_utils.dart';

class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? _avatar; // Raw avatar path from API
  final String? address;
  final DateTime? emailVerifiedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    String? avatar,
    this.address,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
  }) : _avatar = avatar;
  
  /// Get full avatar URL with storage path prepended
  String? get avatarUrl => buildImageUrl(_avatar);
  
  /// Raw avatar path (for backwards compatibility)
  String? get avatar => _avatar;
  
  /// Create User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      avatar: json['avatar'],
      address: json['address'],
      emailVerifiedAt: json['email_verified_at'] != null 
          ? DateTime.tryParse(json['email_verified_at']) 
          : null,
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at']) 
          : null,
    );
  }
  
  /// Convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': _avatar,
      'address': address,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
  
  /// Get initials for avatar placeholder
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
  
  /// Check if email is verified
  bool get isEmailVerified => emailVerifiedAt != null;
  
  /// Create a copy with updated fields
  User copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? avatar,
    String? address,
    DateTime? emailVerifiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? _avatar,
      address: address ?? this.address,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}
