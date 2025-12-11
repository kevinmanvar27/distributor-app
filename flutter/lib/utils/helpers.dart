import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/constants.dart';

/// Validation Helpers
class Validators {
  /// Email validation
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Password validation
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }
    return null;
  }

  /// Strong password validation
  static String? strongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  /// Confirm password validation
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Phone validation
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final cleanPhone = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleanPhone.length < AppConstants.minPhoneLength ||
        cleanPhone.length > AppConstants.maxPhoneLength) {
      return 'Please enter a valid phone number';
    }
    if (!RegExp(r'^[\+]?[0-9]+$').hasMatch(cleanPhone)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  /// Required field validation
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Name validation
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  /// OTP validation
  static String? otp(String? value) {
    if (value == null || value.isEmpty) {
      return 'OTP is required';
    }
    if (value.length != AppConstants.otpLength) {
      return 'Please enter a valid ${AppConstants.otpLength}-digit OTP';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'OTP must contain only numbers';
    }
    return null;
  }

  /// Postal code validation
  static String? postalCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Postal code is required';
    }
    if (value.length < 4 || value.length > 10) {
      return 'Please enter a valid postal code';
    }
    return null;
  }

  /// Min length validation
  static String? minLength(String? value, int minLength, [String fieldName = 'This field']) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    return null;
  }

  /// Max length validation
  static String? maxLength(String? value, int maxLength, [String fieldName = 'This field']) {
    if (value != null && value.length > maxLength) {
      return '$fieldName must not exceed $maxLength characters';
    }
    return null;
  }

  /// Numeric validation
  static String? numeric(String? value, [String fieldName = 'This field']) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    if (double.tryParse(value) == null) {
      return '$fieldName must be a valid number';
    }
    return null;
  }

  /// URL validation
  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL is optional
    }
    final urlRegex = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
      caseSensitive: false,
    );
    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    return null;
  }
}

/// Format Helpers
class Formatters {
  /// Format currency
  static String currency(
    double amount, {
    String symbol = '\$',
    int decimalDigits = 2,
    String locale = 'en_US',
  }) {
    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: decimalDigits,
      locale: locale,
    );
    return formatter.format(amount);
  }

  /// Format number with commas
  static String number(num value, {int decimalDigits = 0}) {
    final formatter = NumberFormat.decimalPattern();
    if (decimalDigits > 0) {
      return value.toStringAsFixed(decimalDigits);
    }
    return formatter.format(value);
  }

  /// Format percentage
  static String percentage(double value, {int decimalDigits = 0}) {
    return '${value.toStringAsFixed(decimalDigits)}%';
  }

  /// Format date
  static String date(DateTime date, {String format = 'MMM dd, yyyy'}) {
    return DateFormat(format).format(date);
  }

  /// Format time
  static String time(DateTime date, {String format = 'hh:mm a'}) {
    return DateFormat(format).format(date);
  }

  /// Format date and time
  static String dateTime(DateTime date, {String format = 'MMM dd, yyyy hh:mm a'}) {
    return DateFormat(format).format(date);
  }

  /// Format relative time (e.g., "2 hours ago")
  static String relativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  /// Format phone number
  static String phone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.length == 10) {
      return '(${cleaned.substring(0, 3)}) ${cleaned.substring(3, 6)}-${cleaned.substring(6)}';
    }
    return phone;
  }

  /// Format file size
  static String fileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Title case
  static String titleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }

  /// Truncate text
  static String truncate(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - suffix.length)}$suffix';
  }

  /// Format order ID
  static String orderId(String id) {
    if (id.length > 8) {
      return '#${id.substring(0, 8).toUpperCase()}';
    }
    return '#${id.toUpperCase()}';
  }

  /// Format address
  static String address({
    String? street,
    String? city,
    String? state,
    String? postalCode,
    String? country,
  }) {
    final parts = <String>[];
    if (street != null && street.isNotEmpty) parts.add(street);
    if (city != null && city.isNotEmpty) parts.add(city);
    if (state != null && state.isNotEmpty) parts.add(state);
    if (postalCode != null && postalCode.isNotEmpty) parts.add(postalCode);
    if (country != null && country.isNotEmpty) parts.add(country);
    return parts.join(', ');
  }
}

/// UI Helpers
class UIHelpers {
  /// Show snackbar
  static void showSnackbar({
    required String message,
    String? title,
    bool isError = false,
    bool isSuccess = false,
    Duration duration = const Duration(seconds: 3),
    SnackPosition position = SnackPosition.BOTTOM,
  }) {
    Get.snackbar(
      title ?? (isError ? 'Error' : isSuccess ? 'Success' : 'Info'),
      message,
      snackPosition: position,
      duration: duration,
      backgroundColor: isError
          ? Colors.red.shade600
          : isSuccess
              ? Colors.green.shade600
              : Colors.grey.shade800,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: Icon(
        isError
            ? Icons.error_outline
            : isSuccess
                ? Icons.check_circle_outline
                : Icons.info_outline,
        color: Colors.white,
      ),
    );
  }

  /// Show error snackbar
  static void showError(String message, {String? title}) {
    showSnackbar(message: message, title: title, isError: true);
  }

  /// Show success snackbar
  static void showSuccess(String message, {String? title}) {
    showSnackbar(message: message, title: title, isSuccess: true);
  }

  /// Show loading dialog
  static void showLoading({String? message}) {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Get.theme.cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: Get.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Hide loading dialog
  static void hideLoading() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  /// Show confirmation dialog
  static Future<bool> showConfirmDialog({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDangerous = false,
  }) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: isDangerous
                ? ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  )
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Show bottom sheet
  static Future<T?> showBottomSheet<T>({
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
    bool isScrollControlled = true,
  }) {
    return Get.bottomSheet<T>(
      child,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: isScrollControlled,
      backgroundColor: Get.theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  /// Copy to clipboard
  static Future<void> copyToClipboard(String text, {String? message}) async {
    await Clipboard.setData(ClipboardData(text: text));
    showSuccess(message ?? 'Copied to clipboard');
  }

  /// Haptic feedback
  static void hapticLight() => HapticFeedback.lightImpact();
  static void hapticMedium() => HapticFeedback.mediumImpact();
  static void hapticHeavy() => HapticFeedback.heavyImpact();
  static void hapticSelection() => HapticFeedback.selectionClick();
}

/// URL Launcher Helpers
class LauncherHelpers {
  /// Launch URL
  static Future<bool> launchURL(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Launch phone call
  static Future<bool> call(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    return launchURL(url);
  }

  /// Launch SMS
  static Future<bool> sms(String phoneNumber, {String? body}) async {
    final url = body != null
        ? 'sms:$phoneNumber?body=${Uri.encodeComponent(body)}'
        : 'sms:$phoneNumber';
    return launchURL(url);
  }

  /// Launch email
  static Future<bool> email(
    String email, {
    String? subject,
    String? body,
  }) async {
    final params = <String>[];
    if (subject != null) params.add('subject=${Uri.encodeComponent(subject)}');
    if (body != null) params.add('body=${Uri.encodeComponent(body)}');
    final url = 'mailto:$email${params.isNotEmpty ? '?${params.join('&')}' : ''}';
    return launchURL(url);
  }

  /// Launch WhatsApp
  static Future<bool> whatsapp(String phoneNumber, {String? message}) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final url = message != null
        ? 'https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}'
        : 'https://wa.me/$cleanPhone';
    return launchURL(url);
  }

  /// Launch maps
  static Future<bool> maps(double latitude, double longitude, {String? label}) async {
    String url;
    if (Platform.isIOS) {
      url = 'https://maps.apple.com/?ll=$latitude,$longitude';
      if (label != null) url += '&q=${Uri.encodeComponent(label)}';
    } else {
      url = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    }
    return launchURL(url);
  }

  /// Launch maps with address
  static Future<bool> mapsAddress(String address) async {
    final encodedAddress = Uri.encodeComponent(address);
    String url;
    if (Platform.isIOS) {
      url = 'https://maps.apple.com/?q=$encodedAddress';
    } else {
      url = 'https://www.google.com/maps/search/?api=1&query=$encodedAddress';
    }
    return launchURL(url);
  }
}

/// Device Helpers
class DeviceHelpers {
  /// Check if device is mobile
  static bool get isMobile => Get.width < AppConstants.mobileBreakpoint;

  /// Check if device is tablet
  static bool get isTablet =>
      Get.width >= AppConstants.mobileBreakpoint &&
      Get.width < AppConstants.tabletBreakpoint;

  /// Check if device is desktop
  static bool get isDesktop => Get.width >= AppConstants.tabletBreakpoint;

  /// Get device type
  static String get deviceType {
    if (isMobile) return 'mobile';
    if (isTablet) return 'tablet';
    return 'desktop';
  }

  /// Get screen size category
  static ScreenSize get screenSize {
    if (isMobile) return ScreenSize.mobile;
    if (isTablet) return ScreenSize.tablet;
    return ScreenSize.desktop;
  }

  /// Check if keyboard is visible
  static bool get isKeyboardVisible => Get.mediaQuery.viewInsets.bottom > 0;

  /// Get safe area padding
  static EdgeInsets get safeAreaPadding => Get.mediaQuery.padding;

  /// Check if platform is iOS
  static bool get isIOS => Platform.isIOS;

  /// Check if platform is Android
  static bool get isAndroid => Platform.isAndroid;
}

/// Screen size enum
enum ScreenSize { mobile, tablet, desktop }

/// Extension on String for validation
extension StringValidation on String {
  bool get isValidEmail => Validators.email(this) == null;
  bool get isValidPhone => Validators.phone(this) == null;
  bool get isValidPassword => Validators.password(this) == null;
  bool get isValidUrl => Validators.url(this) == null;
  bool get isNumeric => double.tryParse(this) != null;
}

/// Extension on DateTime for formatting
extension DateTimeFormatting on DateTime {
  String get formatted => Formatters.date(this);
  String get formattedTime => Formatters.time(this);
  String get formattedDateTime => Formatters.dateTime(this);
  String get relative => Formatters.relativeTime(this);
}

/// Extension on double for currency formatting
extension CurrencyFormatting on double {
  String get currency => Formatters.currency(this);
  String get percentage => Formatters.percentage(this);
}

/// Extension on int for number formatting
extension NumberFormatting on int {
  String get formatted => Formatters.number(this);
  String get fileSize => Formatters.fileSize(this);
}
