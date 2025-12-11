import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../constants/app_constants.dart';

/// Storage Service for managing local data persistence
/// Uses Flutter Secure Storage for sensitive data (tokens)
/// Uses Hive for general app data caching
class StorageService extends GetxService {
  late FlutterSecureStorage _secureStorage;
  late Box _cacheBox;

  static const String _cacheBoxName = 'app_cache';

  /// Initialize the storage service
  Future<StorageService> init() async {
    // Initialize secure storage for sensitive data
    _secureStorage = const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    );

    // Initialize Hive box for caching
    _cacheBox = await Hive.openBox(_cacheBoxName);

    return this;
  }

  // ==================== Secure Storage (Tokens) ====================

  /// Save auth token securely
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: AppConstants.tokenKey, value: token);
  }

  /// Get auth token
  Future<String?> getToken() async {
    return await _secureStorage.read(key: AppConstants.tokenKey);
  }

  /// Delete auth token
  Future<void> deleteToken() async {
    await _secureStorage.delete(key: AppConstants.tokenKey);
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ==================== User Data ====================

  /// Save user data
  Future<void> saveUser(Map<String, dynamic> userData) async {
    await _cacheBox.put(AppConstants.userKey, jsonEncode(userData));
  }

  /// Get user data
  Map<String, dynamic>? getUser() {
    final userData = _cacheBox.get(AppConstants.userKey);
    if (userData != null) {
      return jsonDecode(userData);
    }
    return null;
  }

  /// Delete user data
  Future<void> deleteUser() async {
    await _cacheBox.delete(AppConstants.userKey);
  }

  // ==================== Theme Settings ====================

  /// Save theme settings from API
  Future<void> saveThemeSettings(Map<String, dynamic> settings) async {
    await _cacheBox.put(AppConstants.themeKey, jsonEncode(settings));
  }

  /// Get cached theme settings
  Map<String, dynamic>? getThemeSettings() {
    final settings = _cacheBox.get(AppConstants.themeKey);
    if (settings != null) {
      return jsonDecode(settings);
    }
    return null;
  }

  // ==================== App Config ====================

  /// Save app config from API
  Future<void> saveAppConfig(Map<String, dynamic> config) async {
    await _cacheBox.put(AppConstants.configKey, jsonEncode(config));
  }

  /// Get cached app config
  Map<String, dynamic>? getAppConfig() {
    final config = _cacheBox.get(AppConstants.configKey);
    if (config != null) {
      return jsonDecode(config);
    }
    return null;
  }

  // ==================== Dark Mode ====================

  /// Save dark mode preference
  Future<void> saveDarkMode(bool isDark) async {
    await _cacheBox.put(AppConstants.darkModeKey, isDark);
  }

  /// Get dark mode preference
  bool getDarkMode() {
    return _cacheBox.get(AppConstants.darkModeKey, defaultValue: false);
  }

  // ==================== Onboarding ====================

  /// Mark onboarding as completed
  Future<void> setOnboardingCompleted() async {
    await _cacheBox.put(AppConstants.onboardingKey, true);
  }

  /// Check if onboarding is completed
  bool isOnboardingCompleted() {
    return _cacheBox.get(AppConstants.onboardingKey, defaultValue: false);
  }

  // ==================== Generic Cache Methods ====================

  /// Save data to cache with key
  Future<void> saveToCache(String key, dynamic data) async {
    if (data is Map || data is List) {
      await _cacheBox.put(key, jsonEncode(data));
    } else {
      await _cacheBox.put(key, data);
    }
  }

  /// Get data from cache
  T? getFromCache<T>(String key) {
    final data = _cacheBox.get(key);
    if (data == null) return null;
    
    if (T == Map<String, dynamic> || T == List) {
      return jsonDecode(data) as T;
    }
    return data as T;
  }

  /// Delete from cache
  Future<void> deleteFromCache(String key) async {
    await _cacheBox.delete(key);
  }

  /// Check if key exists in cache
  bool hasKey(String key) {
    return _cacheBox.containsKey(key);
  }

  // ==================== Clear All Data ====================

  /// Clear all stored data (on logout)
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    await _cacheBox.clear();
  }

  /// Clear only auth-related data
  Future<void> clearAuthData() async {
    await deleteToken();
    await deleteUser();
  }
}
