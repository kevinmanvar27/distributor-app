// Profile Controller
// 
// Manages user profile state and operations:
// - Load and display user information
// - Edit profile functionality
// - Logout with confirmation
// - Account settings management

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/user.dart';
import '../../core/services/api_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/app_theme.dart';

class ProfileController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();

  // ─────────────────────────────────────────────────────────────────────────────
  // Reactive State
  // ─────────────────────────────────────────────────────────────────────────────

  final Rx<User?> user = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // Edit mode state
  final RxBool isEditMode = false.obs;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  // ─────────────────────────────────────────────────────────────────────────────
  // Computed Properties
  // ─────────────────────────────────────────────────────────────────────────────

  bool get isLoggedIn => user.value != null;
  String get userName => user.value?.name ?? 'Guest';
  String get userEmail => user.value?.email ?? '';
  String get userPhone => user.value?.phone ?? '';
  String get userInitials {
    final name = user.value?.name ?? 'G';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Profile Operations
  // ─────────────────────────────────────────────────────────────────────────────

  /// Load user profile from storage or API
  Future<void> loadUserProfile() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      // First, try to load from local storage (cached)
      final cachedUser = _loadUserFromStorage();
      if (cachedUser != null) {
        user.value = cachedUser;
        _populateEditFields();
      }

      // Then fetch fresh data from API
      await _fetchUserFromApi();
    } catch (e) {
      if (user.value == null) {
        hasError.value = true;
        errorMessage.value = 'Failed to load profile. Please try again.';
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch user profile from API
  Future<void> _fetchUserFromApi() async {
    try {
      final response = await _apiService.get('/user');
      
      if (response.statusCode == 200 && response.data != null) {
        final userData = response.data['data'] ?? response.data['user'] ?? response.data;
        user.value = User.fromJson(userData);
        _populateEditFields();
        _saveUserToStorage(user.value!);
      }
    } catch (e) {
      // Silent fail if we have cached data
      if (user.value == null) {
        rethrow;
      }
    }
  }

  /// Refresh profile data
  Future<void> refreshProfile() async {
    await loadUserProfile();
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Edit Profile
  // ─────────────────────────────────────────────────────────────────────────────

  /// Enter edit mode
  void enterEditMode() {
    _populateEditFields();
    isEditMode.value = true;
  }

  /// Cancel edit mode
  void cancelEditMode() {
    _populateEditFields();
    isEditMode.value = false;
  }

  /// Populate edit fields with current user data
  void _populateEditFields() {
    nameController.text = user.value?.name ?? '';
    emailController.text = user.value?.email ?? '';
    phoneController.text = user.value?.phone ?? '';
  }

  /// Save profile changes
  Future<void> saveProfile() async {
    if (!_validateEditFields()) return;

    isSaving.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final updateData = {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
      };

      final response = await _apiService.put('/user', data: updateData);

      if (response.statusCode == 200) {
        // Update local user data
        final userData = response.data['data'] ?? response.data['user'] ?? response.data;
        user.value = User.fromJson(userData);
        _saveUserToStorage(user.value!);
        
        isEditMode.value = false;
        _showSnackbar('Profile Updated', 'Your profile has been updated successfully');
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to update profile. Please try again.';
      _showSnackbar('Update Failed', errorMessage.value, isError: true);
    } finally {
      isSaving.value = false;
    }
  }

  /// Validate edit fields
  bool _validateEditFields() {
    if (nameController.text.trim().isEmpty) {
      _showSnackbar('Validation Error', 'Name is required', isError: true);
      return false;
    }
    if (emailController.text.trim().isEmpty) {
      _showSnackbar('Validation Error', 'Email is required', isError: true);
      return false;
    }
    if (!GetUtils.isEmail(emailController.text.trim())) {
      _showSnackbar('Validation Error', 'Please enter a valid email', isError: true);
      return false;
    }
    return true;
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Logout
  // ─────────────────────────────────────────────────────────────────────────────

  /// Logout with confirmation dialog
  Future<void> logout() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _performLogout();
    }
  }

  /// Perform logout operation
  Future<void> _performLogout() async {
    isLoading.value = true;

    try {
      // Call logout API (optional, depends on backend)
      try {
        await _apiService.post('/logout');
      } catch (_) {
        // Silent fail for logout API
      }

      // Clear local storage
      await _storageService.remove('auth_token');
      await _storageService.remove('user_data');
      await _storageService.remove('cart_items');

      // Clear user state
      user.value = null;

      // Navigate to login
      Get.offAllNamed('/login');
      _showSnackbar('Logged Out', 'You have been logged out successfully');
    } catch (e) {
      _showSnackbar('Logout Failed', 'Failed to logout. Please try again.', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Local Storage
  // ─────────────────────────────────────────────────────────────────────────────

  /// Load user from local storage
  User? _loadUserFromStorage() {
    try {
      final userJson = _storageService.getString('user_data');
      if (userJson != null && userJson.isNotEmpty) {
        final decoded = json.decode(userJson) as Map<String, dynamic>;
        return User.fromJson(decoded);
      }
    } catch (e) {
      // Silent fail - corrupted data or parse error
    }
    return null;
  }

  /// Save user to local storage
  Future<void> _saveUserToStorage(User user) async {
    try {
      final encoded = json.encode(user.toJson());
      await _storageService.saveString('user_data', encoded);
    } catch (e) {
      // Silent fail
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────────

  void _showSnackbar(String title, String message, {bool isError = false}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError 
          ? AppTheme.errorColor.withValues(alpha: 0.9)
          : AppTheme.successColor.withValues(alpha: 0.9),
      colorText: Colors.white,
      margin: const EdgeInsets.all(AppTheme.spacingMD),
      borderRadius: AppTheme.radiusMD,
      duration: const Duration(seconds: 2),
      icon: Icon(
        isError ? Icons.error_outline : Icons.check_circle_outline,
        color: Colors.white,
      ),
    );
  }
}
