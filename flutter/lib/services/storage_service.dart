import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/constants.dart';

/// Storage Service - Handles local data persistence
/// Uses SharedPreferences for general data and FlutterSecureStorage for sensitive data
class StorageService extends GetxService {
  late SharedPreferences _prefs;
  late FlutterSecureStorage _secureStorage;

  /// Initialize storage service
  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    _secureStorage = const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    );
    return this;
  }

  // ============ Secure Storage (for sensitive data) ============

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

  /// Save refresh token securely
  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: AppConstants.refreshTokenKey, value: token);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: AppConstants.refreshTokenKey);
  }

  /// Delete refresh token
  Future<void> deleteRefreshToken() async {
    await _secureStorage.delete(key: AppConstants.refreshTokenKey);
  }

  /// Clear all secure storage
  Future<void> clearSecureStorage() async {
    await _secureStorage.deleteAll();
  }

  // ============ Shared Preferences (for general data) ============

  /// Save string value
  Future<bool> saveString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  /// Get string value
  String? getString(String key) {
    return _prefs.getString(key);
  }

  /// Save int value
  Future<bool> saveInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }

  /// Get int value
  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  /// Save double value
  Future<bool> saveDouble(String key, double value) async {
    return await _prefs.setDouble(key, value);
  }

  /// Get double value
  double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  /// Save bool value
  Future<bool> saveBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  /// Get bool value
  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  /// Save string list
  Future<bool> saveStringList(String key, List<String> value) async {
    return await _prefs.setStringList(key, value);
  }

  /// Get string list
  List<String>? getStringList(String key) {
    return _prefs.getStringList(key);
  }

  /// Save JSON object
  Future<bool> saveJson(String key, Map<String, dynamic> value) async {
    return await _prefs.setString(key, jsonEncode(value));
  }

  /// Get JSON object
  Map<String, dynamic>? getJson(String key) {
    final jsonString = _prefs.getString(key);
    if (jsonString != null) {
      try {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Save JSON list
  Future<bool> saveJsonList(String key, List<Map<String, dynamic>> value) async {
    return await _prefs.setString(key, jsonEncode(value));
  }

  /// Get JSON list
  List<Map<String, dynamic>>? getJsonList(String key) {
    final jsonString = _prefs.getString(key);
    if (jsonString != null) {
      try {
        final list = jsonDecode(jsonString) as List;
        return list.map((e) => e as Map<String, dynamic>).toList();
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Remove a key
  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  /// Check if key exists
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  /// Clear all shared preferences
  Future<bool> clearAll() async {
    return await _prefs.clear();
  }

  // ============ User Data ============

  /// Save user data
  Future<bool> saveUser(Map<String, dynamic> userData) async {
    return await saveJson(AppConstants.userKey, userData);
  }

  /// Get user data
  Map<String, dynamic>? getUser() {
    return getJson(AppConstants.userKey);
  }

  /// Delete user data
  Future<bool> deleteUser() async {
    return await remove(AppConstants.userKey);
  }

  // ============ App Settings ============

  /// Save app settings
  Future<bool> saveAppSettings(Map<String, dynamic> settings) async {
    return await saveJson(AppConstants.appSettingsKey, settings);
  }

  /// Get app settings
  Map<String, dynamic>? getAppSettings() {
    return getJson(AppConstants.appSettingsKey);
  }

  // ============ Theme ============

  /// Save theme mode
  Future<bool> saveThemeMode(String mode) async {
    return await saveString(AppConstants.themeKey, mode);
  }

  /// Get theme mode
  String? getThemeMode() {
    return getString(AppConstants.themeKey);
  }

  // ============ Language ============

  /// Save language
  Future<bool> saveLanguage(String languageCode) async {
    return await saveString(AppConstants.languageKey, languageCode);
  }

  /// Get language
  String? getLanguage() {
    return getString(AppConstants.languageKey);
  }

  // ============ Currency ============

  /// Save currency
  Future<bool> saveCurrency(String currencyCode) async {
    return await saveString(AppConstants.currencyKey, currencyCode);
  }

  /// Get currency
  String? getCurrency() {
    return getString(AppConstants.currencyKey);
  }

  // ============ Onboarding ============

  /// Set onboarding completed
  Future<bool> setOnboardingCompleted() async {
    return await saveBool(AppConstants.onboardingKey, true);
  }

  /// Check if onboarding completed
  bool isOnboardingCompleted() {
    return getBool(AppConstants.onboardingKey) ?? false;
  }

  // ============ Search History ============

  /// Save search history
  Future<bool> saveSearchHistory(List<String> history) async {
    // Keep only the last N items
    final limitedHistory = history.length > AppConstants.maxSearchHistory
        ? history.sublist(0, AppConstants.maxSearchHistory)
        : history;
    return await saveStringList(AppConstants.searchHistoryKey, limitedHistory);
  }

  /// Get search history
  List<String> getSearchHistory() {
    return getStringList(AppConstants.searchHistoryKey) ?? [];
  }

  /// Add to search history
  Future<bool> addToSearchHistory(String query) async {
    final history = getSearchHistory();
    // Remove if already exists
    history.remove(query);
    // Add to beginning
    history.insert(0, query);
    return await saveSearchHistory(history);
  }

  /// Remove from search history
  Future<bool> removeFromSearchHistory(String query) async {
    final history = getSearchHistory();
    history.remove(query);
    return await saveSearchHistory(history);
  }

  /// Clear search history
  Future<bool> clearSearchHistory() async {
    return await remove(AppConstants.searchHistoryKey);
  }

  // ============ Recent Products ============

  /// Save recent products
  Future<bool> saveRecentProducts(List<String> productIds) async {
    final limitedProducts = productIds.length > AppConstants.maxRecentProducts
        ? productIds.sublist(0, AppConstants.maxRecentProducts)
        : productIds;
    return await saveStringList(AppConstants.recentProductsKey, limitedProducts);
  }

  /// Get recent products
  List<String> getRecentProducts() {
    return getStringList(AppConstants.recentProductsKey) ?? [];
  }

  /// Add to recent products
  Future<bool> addToRecentProducts(String productId) async {
    final products = getRecentProducts();
    // Remove if already exists
    products.remove(productId);
    // Add to beginning
    products.insert(0, productId);
    return await saveRecentProducts(products);
  }

  /// Clear recent products
  Future<bool> clearRecentProducts() async {
    return await remove(AppConstants.recentProductsKey);
  }

  // ============ Cart (Offline) ============

  /// Save cart items (for offline support)
  Future<bool> saveCartItems(List<Map<String, dynamic>> items) async {
    return await saveJsonList(AppConstants.cartKey, items);
  }

  /// Get cart items
  List<Map<String, dynamic>> getCartItems() {
    return getJsonList(AppConstants.cartKey) ?? [];
  }

  /// Clear cart items
  Future<bool> clearCartItems() async {
    return await remove(AppConstants.cartKey);
  }

  // ============ Logout ============

  /// Clear all user-related data on logout
  Future<void> clearUserData() async {
    await deleteToken();
    await deleteRefreshToken();
    await deleteUser();
    await clearCartItems();
    await clearSearchHistory();
    await clearRecentProducts();
  }
}
