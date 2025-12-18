import '../providers/api_provider.dart';
import '../models/models.dart';

/// Auth Response Model
class AuthResponse {
  final UserModel user;
  final String accessToken;
  final String tokenType;
  final DateTime? expiresAt;

  AuthResponse({
    required this.user,
    required this.accessToken,
    this.tokenType = 'Bearer',
    this.expiresAt,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: UserModel.fromJson(json['user'] ?? json),
      accessToken: json['access_token'] ?? json['token'] ?? '',
      tokenType: json['token_type'] ?? 'Bearer',
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'])
          : null,
    );
  }
}

/// Auth Repository - Handles authentication API calls
class AuthRepository {
  final ApiProvider _api;

  AuthRepository(this._api);

  /// Login with email and password
  Future<AuthResponse> login({
    required String email,
    required String password,
    String? deviceName,
    String? fcmToken,
  }) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/api/v1/login',
      body: {
        'email': email,
        'password': password,
        if (deviceName != null) 'device_name': deviceName,
        if (fcmToken != null) 'fcm_token': fcmToken,
      },
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        message: response.message ?? 'Login failed',
        statusCode: response.statusCode,
        errors: response.errors,
      );
    }

    final authResponse = AuthResponse.fromJson(response.data!);
    _api.setAuthToken(authResponse.accessToken);
    return authResponse;
  }

  /// Register new user
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
    String? companyName,
    String? gstNumber,
    String? address,
    String? city,
    String? state,
    String? pincode,
    String? fcmToken,
  }) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/api/v1/register',
      body: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        if (phone != null) 'phone': phone,
        if (companyName != null) 'company_name': companyName,
        if (gstNumber != null) 'gst_number': gstNumber,
        if (address != null) 'address': address,
        if (city != null) 'city': city,
        if (state != null) 'state': state,
        if (pincode != null) 'pincode': pincode,
        if (fcmToken != null) 'fcm_token': fcmToken,
      },
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        message: response.message ?? 'Registration failed',
        statusCode: response.statusCode,
        errors: response.errors,
      );
    }

    final authResponse = AuthResponse.fromJson(response.data!);
    _api.setAuthToken(authResponse.accessToken);
    return authResponse;
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _api.post('/api/v1/logout');
    } finally {
      _api.setAuthToken(null);
    }
  }

  /// Refresh token
  Future<AuthResponse> refreshToken() async {
    final response = await _api.post<Map<String, dynamic>>(
      '/api/v1/refresh-token',
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        message: response.message ?? 'Token refresh failed',
        statusCode: response.statusCode,
      );
    }

    final authResponse = AuthResponse.fromJson(response.data!);
    _api.setAuthToken(authResponse.accessToken);
    return authResponse;
  }

  /// Get current user profile
  Future<UserModel> getProfile() async {
    final response = await _api.get<Map<String, dynamic>>(
      '/api/v1/profile',
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        message: response.message ?? 'Failed to get profile',
        statusCode: response.statusCode,
      );
    }

    return UserModel.fromJson(response.data!);
  }

  /// Update profile
  Future<UserModel> updateProfile({
    String? name,
    String? phone,
    String? companyName,
    String? gstNumber,
    String? address,
    String? city,
    String? state,
    String? pincode,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (phone != null) body['phone'] = phone;
    if (companyName != null) body['company_name'] = companyName;
    if (gstNumber != null) body['gst_number'] = gstNumber;
    if (address != null) body['address'] = address;
    if (city != null) body['city'] = city;
    if (state != null) body['state'] = state;
    if (pincode != null) body['pincode'] = pincode;

    final response = await _api.put<Map<String, dynamic>>(
      '/api/v1/profile',
      body: body,
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        message: response.message ?? 'Failed to update profile',
        statusCode: response.statusCode,
        errors: response.errors,
      );
    }

    return UserModel.fromJson(response.data!);
  }

  /// Update avatar
  Future<UserModel> updateAvatar(String filePath) async {
    final response = await _api.uploadFile<Map<String, dynamic>>(
      '/api/v1/profile/avatar',
      filePath: filePath,
      fileField: 'avatar',
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        message: response.message ?? 'Failed to update avatar',
        statusCode: response.statusCode,
      );
    }

    return UserModel.fromJson(response.data!);
  }

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    final response = await _api.put(
      '/api/v1/profile/password',
      body: {
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': newPasswordConfirmation,
      },
    );

    if (!response.success) {
      throw ApiException(
        message: response.message ?? 'Failed to change password',
        statusCode: response.statusCode,
        errors: response.errors,
      );
    }
  }

  /// Forgot password - Request OTP
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/api/v1/forgot-password',
      body: {'email': email},
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success) {
      throw ApiException(
        message: response.message ?? 'Failed to send OTP',
        statusCode: response.statusCode,
        errors: response.errors,
      );
    }

    return response.data ?? {};
  }

  /// Verify OTP
  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/api/v1/verify-otp',
      body: {
        'email': email,
        'otp': otp,
      },
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success) {
      throw ApiException(
        message: response.message ?? 'Invalid OTP',
        statusCode: response.statusCode,
        errors: response.errors,
      );
    }

    return response.data ?? {};
  }

  /// Resend OTP
  Future<Map<String, dynamic>> resendOtp(String email) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/api/v1/resend-otp',
      body: {'email': email},
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success) {
      throw ApiException(
        message: response.message ?? 'Failed to resend OTP',
        statusCode: response.statusCode,
        errors: response.errors,
      );
    }

    return response.data ?? {};
  }

  /// Reset password with token
  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _api.post(
      '/api/v1/reset-password',
      body: {
        'email': email,
        'token': token,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );

    if (!response.success) {
      throw ApiException(
        message: response.message ?? 'Failed to reset password',
        statusCode: response.statusCode,
        errors: response.errors,
      );
    }
  }

  /// Verify email
  Future<void> verifyEmail(String token) async {
    final response = await _api.post(
      '/api/v1/verify-email',
      body: {'token': token},
    );

    if (!response.success) {
      throw ApiException(
        message: response.message ?? 'Failed to verify email',
        statusCode: response.statusCode,
      );
    }
  }

  /// Resend verification email
  Future<void> resendVerificationEmail() async {
    final response = await _api.post('/api/v1/resend-verification');

    if (!response.success) {
      throw ApiException(
        message: response.message ?? 'Failed to resend verification email',
        statusCode: response.statusCode,
      );
    }
  }

  /// Update FCM token
  Future<void> updateFcmToken(String fcmToken) async {
    await _api.post(
      '/api/v1/fcm-token',
      body: {'fcm_token': fcmToken},
    );
  }

  /// Delete account
  Future<void> deleteAccount({String? password}) async {
    final response = await _api.delete(
      '/api/v1/profile',
      body: password != null ? {'password': password} : null,
    );

    if (!response.success) {
      throw ApiException(
        message: response.message ?? 'Failed to delete account',
        statusCode: response.statusCode,
        errors: response.errors,
      );
    }

    _api.setAuthToken(null);
  }

  /// Check if email exists
  Future<bool> checkEmailExists(String email) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/api/v1/check-email',
      body: {'email': email},
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    return response.data?['exists'] == true;
  }

  /// Set auth token (for restoring session)
  void setAuthToken(String? token) {
    _api.setAuthToken(token);
  }

  /// Check if authenticated
  bool get isAuthenticated => _api.isAuthenticated;
}
