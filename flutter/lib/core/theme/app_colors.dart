import 'package:flutter/material.dart';

/// App Colors - These are default colors that can be overridden by API settings
/// Colors are fetched from /api/v1/app-settings and applied dynamically
class AppColors {
  AppColors._();

  // ==================== Primary Colors ====================
  // These can be overridden by API settings
  static Color primary = const Color(0xFF007BFF);
  static Color secondary = const Color(0xFF6C757D);
  static Color accent = const Color(0xFF28A745);

  // ==================== Light Theme Colors ====================
  static Color background = const Color(0xFFF8F9FA);
  static Color surface = const Color(0xFFFFFFFF);
  static Color textPrimary = const Color(0xFF212529);
  static Color textSecondary = const Color(0xFF6C757D);
  static Color textHint = const Color(0xFFADB5BD);
  static Color border = const Color(0xFFDEE2E6);
  static Color divider = const Color(0xFFE9ECEF);
  static Color inputBackground = const Color(0xFFF8F9FA);
  static Color chipBackground = const Color(0xFFE9ECEF);

  // ==================== Dark Theme Colors ====================
  static Color darkBackground = const Color(0xFF121212);
  static Color darkSurface = const Color(0xFF1E1E1E);
  static Color darkTextPrimary = const Color(0xFFE1E1E1);
  static Color darkTextSecondary = const Color(0xFF9E9E9E);
  static Color darkTextHint = const Color(0xFF757575);
  static Color darkBorder = const Color(0xFF2C2C2C);
  static Color darkDivider = const Color(0xFF2C2C2C);
  static Color darkInputBackground = const Color(0xFF2C2C2C);

  // ==================== Semantic Colors ====================
  static const Color success = Color(0xFF28A745);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFDC3545);
  static const Color info = Color(0xFF17A2B8);

  // ==================== Status Colors ====================
  static const Color statusDraft = Color(0xFF6C757D);
  static const Color statusApproved = Color(0xFF28A745);
  static const Color statusDispatch = Color(0xFF17A2B8);
  static const Color statusOutForDelivery = Color(0xFFFFC107);
  static const Color statusDelivered = Color(0xFF28A745);
  static const Color statusReturn = Color(0xFFDC3545);

  // ==================== Gradient Colors ====================
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF007BFF), Color(0xFF0056B3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF28A745), Color(0xFF1E7E34)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ==================== Shimmer Colors ====================
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
  static const Color darkShimmerBase = Color(0xFF2C2C2C);
  static const Color darkShimmerHighlight = Color(0xFF3C3C3C);

  // ==================== Shadow Colors ====================
  static Color shadowLight = Colors.black.withOpacity(0.05);
  static Color shadowMedium = Colors.black.withOpacity(0.1);
  static Color shadowDark = Colors.black.withOpacity(0.15);

  // ==================== Overlay Colors ====================
  static Color overlayLight = Colors.black.withOpacity(0.3);
  static Color overlayMedium = Colors.black.withOpacity(0.5);
  static Color overlayDark = Colors.black.withOpacity(0.7);

  /// Update colors from API settings
  /// Called when app settings are fetched from the server
  static void updateFromSettings(Map<String, dynamic> settings) {
    if (settings['primary_color'] != null) {
      primary = _parseColor(settings['primary_color']);
    }
    if (settings['secondary_color'] != null) {
      secondary = _parseColor(settings['secondary_color']);
    }
    if (settings['accent_color'] != null) {
      accent = _parseColor(settings['accent_color']);
    }
    if (settings['background_color'] != null) {
      background = _parseColor(settings['background_color']);
    }
    if (settings['text_color'] != null) {
      textPrimary = _parseColor(settings['text_color']);
    }
  }

  /// Parse hex color string to Color object
  static Color _parseColor(String hexColor) {
    try {
      hexColor = hexColor.replaceAll('#', '');
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor';
      }
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return primary; // Return default if parsing fails
    }
  }

  /// Get status color based on invoice status
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return statusDraft;
      case 'approved':
        return statusApproved;
      case 'dispatch':
        return statusDispatch;
      case 'out for delivery':
        return statusOutForDelivery;
      case 'delivered':
        return statusDelivered;
      case 'return':
        return statusReturn;
      default:
        return statusDraft;
    }
  }
}
