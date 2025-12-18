import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../data/data.dart';

/// Auth Controller
/// Manages user authentication state, login, registration, profile
class AuthController extends GetxController {
  final AuthRepository _authRepository;
  final GetStorage _storage;

  AuthController({
    AuthRepository? authRepository,
    GetStorage? storage,
  })  : _authRepository = authRepository ?? AuthRepository(Get.find()),
        _storage = storage ?? GetStorage();

  // Storage keys
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';

  // Observable state
  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxString token = ''.obs;
  final RxString refreshToken = ''.obs;
  
  final RxBool isLoading = false.obs;
  final RxBool isLoggedIn = false.obs;
  final RxBool isEmailVerified = false.obs;
  
  final RxString errorMessage = ''.obs;
  final RxMap<String, String> fieldErrors = <String, String>{}.obs;

  // Getters
  bool get hasToken => token.value.isNotEmpty;
  String get userName => user.value?.name ?? '';
  String get userEmail => user.value?.email ?? '';
  String get userPhone => user.value?.phone ?? '';
  String? get userAvatar => user.value?.avatarUrl;
  String get userInitials => user.value?.initials ?? '';
  bool get isDistributor => user.value?.isDistributor ?? false;
  bool get isApproved => user.value?.isApproved ?? false;

  @override
  void onInit() {
    super.onInit();
    _loadStoredAuth();
  }

  /// Load stored authentication data
  void _loadStoredAuth() {
    final storedToken = _storage.read<String>(_tokenKey);
    final storedRefreshToken = _storage.read<String>(_refreshTokenKey);
    final storedUser = _storage.read<Map<String, dynamic>>(_userKey);

    if (storedToken != null && storedToken.isNotEmpty) {
      token.value = storedToken;
      refreshToken.value = storedRefreshToken ?? '';
      
      // Update API provider with token
      final apiProvider = Get.find<ApiProvider>();
      apiProvider.setAuthToken(storedToken);

      if (storedUser != null) {
        user.value = UserModel.fromJson(storedUser);
        isEmailVerified.value = user.value?.isEmailVerified ?? false;
      }

      isLoggedIn.value = true;
      
      // Refresh user profile in background
      _refreshUserProfile();
    }
  }

  /// Save authentication data to storage
  void _saveAuth(String authToken, String? authRefreshToken, UserModel userData) {
    _storage.write(_tokenKey, authToken);
    if (authRefreshToken != null) {
      _storage.write(_refreshTokenKey, authRefreshToken);
    }
    _storage.write(_userKey, userData.toJson());

    token.value = authToken;
    refreshToken.value = authRefreshToken ?? '';
    user.value = userData;
    isLoggedIn.value = true;
    isEmailVerified.value = userData.isEmailVerified;

    // Update API provider with token
    final apiProvider = Get.find<ApiProvider>();
    apiProvider.setAuthToken(authToken);
  }

  /// Clear authentication data
  void _clearAuth() {
    _storage.remove(_tokenKey);
    _storage.remove(_refreshTokenKey);
    _storage.remove(_userKey);

    token.value = '';
    refreshToken.value = '';
    user.value = null;
    isLoggedIn.value = false;
    isEmailVerified.value = false;

    // Clear API provider token
    final apiProvider = Get.find<ApiProvider>();
    apiProvider.clearAuthToken();
  }

  /// Clear errors
  void clearErrors() {
    errorMessage.value = '';
    fieldErrors.clear();
  }

  /// Login with email and password
  Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    clearErrors();
    isLoading.value = true;

    try {
      final response = await _authRepository.login(
        email: email,
        password: password,
      );

      final authToken = response['token'] as String?;
      final authRefreshToken = response['refresh_token'] as String?;
      final userData = response['user'] as UserModel?;

      if (authToken == null || userData == null) {
        throw ApiException(message: 'Invalid login response');
      }

      _saveAuth(authToken, authRefreshToken, userData);

      // Check if user needs approval
      if (!userData.isApproved) {
        Get.snackbar(
          'Pending Approval',
          'Your account is pending approval. You will be notified once approved.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.orange.shade900,
          duration: const Duration(seconds: 5),
        );
      }

      return true;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      if (e.errors != null) {
        fieldErrors.addAll(Map<String, String>.from(
          e.errors!.map((key, value) => MapEntry(key, value.toString())),
        ));
      }
      return false;
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Register new user
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
    String? companyName,
    String? businessType,
    String? taxId,
    String? address,
    String? city,
    String? state,
    String? postalCode,
    String? country,
  }) async {
    clearErrors();
    isLoading.value = true;

    try {
      final response = await _authRepository.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        phone: phone,
        companyName: companyName,
        businessType: businessType,
        taxId: taxId,
        address: address,
        city: city,
        state: state,
        postalCode: postalCode,
        country: country,
      );

      final authToken = response['token'] as String?;
      final authRefreshToken = response['refresh_token'] as String?;
      final userData = response['user'] as UserModel?;

      if (authToken != null && userData != null) {
        _saveAuth(authToken, authRefreshToken, userData);
      }

      Get.snackbar(
        'Registration Successful',
        'Please check your email to verify your account.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        duration: const Duration(seconds: 5),
      );

      return true;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      if (e.errors != null) {
        fieldErrors.addAll(Map<String, String>.from(
          e.errors!.map((key, value) => MapEntry(key, value.toString())),
        ));
      }
      return false;
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Logout
  Future<void> logout() async {
    isLoading.value = true;

    try {
      await _authRepository.logout();
    } catch (e) {
      // Ignore logout errors, clear local data anyway
    } finally {
      _clearAuth();
      isLoading.value = false;
      
      // Navigate to login screen
      Get.offAllNamed('/login');
    }
  }

  /// Refresh user profile
  Future<void> _refreshUserProfile() async {
    try {
      final userData = await _authRepository.getProfile();
      user.value = userData;
      isEmailVerified.value = userData.isEmailVerified;
      _storage.write(_userKey, userData.toJson());
    } on ApiException catch (e) {
      if (e.isUnauthorized) {
        // Token expired, try to refresh
        await _tryRefreshToken();
      }
    }
  }

  /// Try to refresh token
  Future<bool> _tryRefreshToken() async {
    if (refreshToken.value.isEmpty) {
      _clearAuth();
      return false;
    }

    try {
      final response = await _authRepository.refreshToken(refreshToken.value);
      final newToken = response['token'] as String?;
      final newRefreshToken = response['refresh_token'] as String?;

      if (newToken != null) {
        token.value = newToken;
        _storage.write(_tokenKey, newToken);
        
        if (newRefreshToken != null) {
          refreshToken.value = newRefreshToken;
          _storage.write(_refreshTokenKey, newRefreshToken);
        }

        final apiProvider = Get.find<ApiProvider>();
        apiProvider.setAuthToken(newToken);

        return true;
      }
    } catch (e) {
      _clearAuth();
    }

    return false;
  }

  /// Update profile
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? companyName,
    String? businessType,
    String? taxId,
    String? address,
    String? city,
    String? state,
    String? postalCode,
    String? country,
  }) async {
    clearErrors();
    isLoading.value = true;

    try {
      final userData = await _authRepository.updateProfile(
        name: name,
        phone: phone,
        companyName: companyName,
        businessType: businessType,
        taxId: taxId,
        address: address,
        city: city,
        state: state,
        postalCode: postalCode,
        country: country,
      );

      user.value = userData;
      _storage.write(_userKey, userData.toJson());

      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );

      return true;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      if (e.errors != null) {
        fieldErrors.addAll(Map<String, String>.from(
          e.errors!.map((key, value) => MapEntry(key, value.toString())),
        ));
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Update avatar
  Future<bool> updateAvatar(File imageFile) async {
    isLoading.value = true;

    try {
      final avatarUrl = await _authRepository.updateAvatar(imageFile);
      
      if (user.value != null) {
        // Create updated user with new avatar
        final updatedUser = UserModel(
          id: user.value!.id,
          name: user.value!.name,
          email: user.value!.email,
          phone: user.value!.phone,
          avatarUrl: avatarUrl,
          companyName: user.value!.companyName,
          businessType: user.value!.businessType,
          taxId: user.value!.taxId,
          address: user.value!.address,
          city: user.value!.city,
          state: user.value!.state,
          postalCode: user.value!.postalCode,
          country: user.value!.country,
          role: user.value!.role,
          status: user.value!.status,
          isEmailVerified: user.value!.isEmailVerified,
          isPhoneVerified: user.value!.isPhoneVerified,
          emailVerifiedAt: user.value!.emailVerifiedAt,
          phoneVerifiedAt: user.value!.phoneVerifiedAt,
          lastLoginAt: user.value!.lastLoginAt,
          createdAt: user.value!.createdAt,
          updatedAt: DateTime.now(),
        );
        
        user.value = updatedUser;
        _storage.write(_userKey, updatedUser.toJson());
      }

      Get.snackbar(
        'Success',
        'Avatar updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );

      return true;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    clearErrors();
    isLoading.value = true;

    try {
      await _authRepository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );

      Get.snackbar(
        'Success',
        'Password changed successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );

      return true;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      if (e.errors != null) {
        fieldErrors.addAll(Map<String, String>.from(
          e.errors!.map((key, value) => MapEntry(key, value.toString())),
        ));
      }
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Password Reset State
  final RxString resetEmail = ''.obs;
  final RxString resetToken = ''.obs;
  final RxString maskedEmail = ''.obs;
  final RxInt otpExpiresIn = 0.obs;
  final RxInt resendCooldown = 0.obs;

  /// Forgot password - Request OTP
  Future<bool> forgotPassword(String email) async {
    clearErrors();
    isLoading.value = true;

    try {
      final response = await _authRepository.forgotPassword(email);
      
      resetEmail.value = email;
      maskedEmail.value = response['email'] ?? '';
      otpExpiresIn.value = response['expires_in'] ?? 10;

      Get.snackbar(
        'OTP Sent',
        'A verification code has been sent to your email',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        duration: const Duration(seconds: 3),
      );

      return true;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Verify OTP
  Future<bool> verifyOtp(String otp) async {
    clearErrors();
    isLoading.value = true;

    try {
      final response = await _authRepository.verifyOtp(
        email: resetEmail.value,
        otp: otp,
      );

      resetToken.value = response['reset_token'] ?? '';

      Get.snackbar(
        'Verified',
        'OTP verified successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );

      return true;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Resend OTP
  Future<bool> resendOtp() async {
    if (resendCooldown.value > 0) {
      Get.snackbar(
        'Please Wait',
        'You can resend OTP in ${resendCooldown.value} seconds',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
      );
      return false;
    }

    clearErrors();
    isLoading.value = true;

    try {
      final response = await _authRepository.resendOtp(resetEmail.value);
      
      maskedEmail.value = response['email'] ?? maskedEmail.value;
      otpExpiresIn.value = response['expires_in'] ?? 10;
      
      // Start cooldown timer
      _startResendCooldown();

      Get.snackbar(
        'OTP Resent',
        'A new verification code has been sent to your email',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );

      return true;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Start resend cooldown timer
  void _startResendCooldown() {
    resendCooldown.value = 60;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (resendCooldown.value > 0) {
        resendCooldown.value--;
        return true;
      }
      return false;
    });
  }

  /// Reset password
  Future<bool> resetPassword({
    required String password,
    required String passwordConfirmation,
  }) async {
    clearErrors();
    isLoading.value = true;

    try {
      await _authRepository.resetPassword(
        email: resetEmail.value,
        token: resetToken.value,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      // Clear reset state
      resetEmail.value = '';
      resetToken.value = '';
      maskedEmail.value = '';

      Get.snackbar(
        'Success',
        'Password has been reset successfully. Please login.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );

      return true;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      if (e.errors != null) {
        fieldErrors.addAll(Map<String, String>.from(
          e.errors!.map((key, value) => MapEntry(key, value.toString())),
        ));
      }
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Clear password reset state
  void clearResetState() {
    resetEmail.value = '';
    resetToken.value = '';
    maskedEmail.value = '';
    otpExpiresIn.value = 0;
    resendCooldown.value = 0;
  }

  /// Resend verification email
  Future<bool> resendVerificationEmail() async {
    isLoading.value = true;

    try {
      await _authRepository.resendVerificationEmail();

      Get.snackbar(
        'Email Sent',
        'Verification email has been sent',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );

      return true;
    } on ApiException catch (e) {
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Verify email with token
  Future<bool> verifyEmail(String verificationToken) async {
    isLoading.value = true;

    try {
      await _authRepository.verifyEmail(verificationToken);
      
      isEmailVerified.value = true;
      if (user.value != null) {
        // Update user verification status
        await _refreshUserProfile();
      }

      Get.snackbar(
        'Success',
        'Email verified successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );

      return true;
    } on ApiException catch (e) {
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete account
  Future<bool> deleteAccount({required String password}) async {
    isLoading.value = true;

    try {
      await _authRepository.deleteAccount(password: password);
      
      _clearAuth();

      Get.snackbar(
        'Account Deleted',
        'Your account has been deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );

      Get.offAllNamed('/login');
      return true;
    } on ApiException catch (e) {
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Register FCM token for push notifications
  Future<void> registerFcmToken(String fcmToken) async {
    if (!isLoggedIn.value) return;

    try {
      await _authRepository.registerFcmToken(fcmToken);
    } catch (e) {
      // Silently fail FCM registration
    }
  }

  /// Check if email exists
  Future<bool> checkEmailExists(String email) async {
    try {
      return await _authRepository.checkEmailExists(email);
    } catch (e) {
      return false;
    }
  }
}
