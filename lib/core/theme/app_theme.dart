// App Theme
// 
// Centralized design system with all UI tokens:
// - Colors (primary, secondary, surface, text, status)
// - Typography (display, heading, body, label styles)
// - Spacing (xs, sm, md, lg, xl, xxl)
// - Border radius values
// - Shadows
// - Durations for animations

import 'package:flutter/material.dart';

class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // ─────────────────────────────────────────────────────────────────────────────
  // Colors - Primary Palette
  // ─────────────────────────────────────────────────────────────────────────────
  
  /// Primary brand color - used for main actions, links, active states
  static const Color primaryColor = Color(0xFF2563EB);
  
  /// Primary color variants for different states
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primaryDark = Color(0xFF1D4ED8);
  
  /// Secondary color - used for secondary actions, accents
  static const Color secondaryColor = Color(0xFF7C3AED);
  static const Color secondaryLight = Color(0xFFA78BFA);
  static const Color secondaryDark = Color(0xFF5B21B6);

  // ─────────────────────────────────────────────────────────────────────────────
  // Colors - Surface & Background
  // ─────────────────────────────────────────────────────────────────────────────
  
  /// Background color for the app
  static const Color backgroundColor = Color(0xFFF8FAFC);
  
  /// Surface color for cards, dialogs, sheets
  static const Color surfaceColor = Color(0xFFFFFFFF);
  
  /// Elevated surface color
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  
  /// Border color for dividers, outlines
  static const Color borderColor = Color(0xFFE2E8F0);
  
  /// Divider color
  static const Color dividerColor = Color(0xFFE2E8F0);

  // ─────────────────────────────────────────────────────────────────────────────
  // Colors - Text
  // ─────────────────────────────────────────────────────────────────────────────
  
  /// Primary text color - headings, important text
  static const Color textPrimary = Color(0xFF0F172A);
  
  /// Secondary text color - body text, descriptions
  static const Color textSecondary = Color(0xFF475569);
  
  /// Tertiary text color - hints, placeholders, disabled
  static const Color textTertiary = Color(0xFF94A3B8);
  
  /// Text on primary color background
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ─────────────────────────────────────────────────────────────────────────────
  // Colors - Status
  // ─────────────────────────────────────────────────────────────────────────────
  
  /// Success color - confirmations, positive actions
  static const Color successColor = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFDCFCE7);
  
  /// Warning color - alerts, caution states
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  
  /// Error color - errors, destructive actions
  static const Color errorColor = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  
  /// Info color - informational messages
  static const Color infoColor = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // ─────────────────────────────────────────────────────────────────────────────
  // Spacing
  // ─────────────────────────────────────────────────────────────────────────────
  
  /// Extra small spacing - 4px
  static const double spacingXs = 4.0;
  
  /// Small spacing - 8px
  static const double spacingSm = 8.0;
  
  /// Medium spacing - 16px
  static const double spacingMd = 16.0;
  
  /// Large spacing - 24px
  static const double spacingLg = 24.0;
  
  /// Extra large spacing - 32px
  static const double spacingXl = 32.0;
  
  /// Extra extra large spacing - 48px
  static const double spacingXxl = 48.0;

  // Uppercase aliases for backwards compatibility
  static const double spacingXS = spacingXs;
  static const double spacingSM = spacingSm;
  static const double spacingMD = spacingMd;
  static const double spacingLG = spacingLg;
  static const double spacingXL = spacingXl;
  static const double spacingXXL = spacingXxl;

  // ─────────────────────────────────────────────────────────────────────────────
  // Border Radius
  // ─────────────────────────────────────────────────────────────────────────────
  
  /// Small radius - 4px (buttons, chips)
  static const double radiusSm = 4.0;
  
  /// Medium radius - 8px (cards, inputs)
  static const double radiusMd = 8.0;
  
  /// Large radius - 12px (modals, sheets)
  static const double radiusLg = 12.0;
  
  /// Extra large radius - 16px (large cards)
  static const double radiusXl = 16.0;
  
  /// Full radius - 9999px (pills, avatars)
  static const double radiusFull = 9999.0;

  // Uppercase aliases for backwards compatibility
  static const double radiusSM = radiusSm;
  static const double radiusMD = radiusMd;
  static const double radiusLG = radiusLg;
  static const double radiusXL = radiusXl;

  // ─────────────────────────────────────────────────────────────────────────────
  // Typography - Display (Hero text, large headings)
  // ─────────────────────────────────────────────────────────────────────────────
  
  /// Display large - 57px, for hero sections
  static const TextStyle displayLarge = TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    height: 1.12,
    color: textPrimary,
  );
  
  /// Display medium - 45px
  static const TextStyle displayMedium = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.16,
    color: textPrimary,
  );
  
  /// Display small - 36px
  static const TextStyle displaySmall = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.22,
    color: textPrimary,
  );

  // ─────────────────────────────────────────────────────────────────────────────
  // Typography - Headlines
  // ─────────────────────────────────────────────────────────────────────────────
  
  /// Headline large - 32px
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.25,
    color: textPrimary,
  );
  
  /// Headline medium - 28px
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.29,
    color: textPrimary,
  );
  
  /// Headline small - 24px
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.33,
    color: textPrimary,
  );

  // ─────────────────────────────────────────────────────────────────────────────
  // Typography - Headings (Aliases for convenience)
  // ─────────────────────────────────────────────────────────────────────────────
  
  /// Heading large - alias for headlineLarge
  static const TextStyle headingLarge = headlineLarge;
  
  /// Heading medium - alias for headlineMedium
  static const TextStyle headingMedium = headlineMedium;
  
  /// Heading small - alias for headlineSmall
  static const TextStyle headingSmall = headlineSmall;

  // ─────────────────────────────────────────────────────────────────────────────
  // Typography - Title
  // ─────────────────────────────────────────────────────────────────────────────
  
  /// Title large - 22px
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.27,
    color: textPrimary,
  );
  
  /// Title medium - 16px
  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 1.5,
    color: textPrimary,
  );
  
  /// Title small - 14px
  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
    color: textPrimary,
  );

  // ─────────────────────────────────────────────────────────────────────────────
  // Typography - Body
  // ─────────────────────────────────────────────────────────────────────────────
  
  /// Body large - 16px
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
    color: textSecondary,
  );
  
  /// Body medium - 14px
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
    color: textSecondary,
  );
  
  /// Body small - 12px
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
    color: textSecondary,
  );

  // ─────────────────────────────────────────────────────────────────────────────
  // Typography - Label
  // ─────────────────────────────────────────────────────────────────────────────
  
  /// Label large - 14px, for buttons
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
    color: textPrimary,
  );
  
  /// Label medium - 12px
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.33,
    color: textPrimary,
  );
  
  /// Label small - 11px
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
    color: textPrimary,
  );

  // ─────────────────────────────────────────────────────────────────────────────
  // Shadows
  // ─────────────────────────────────────────────────────────────────────────────
  
  /// Small shadow - subtle elevation
  static const List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];
  
  /// Medium shadow - cards, dropdowns
  static const List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 15,
      offset: Offset(0, 4),
    ),
  ];
  
  /// Large shadow - modals, popovers
  static const List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 25,
      offset: Offset(0, 10),
    ),
  ];
  
  /// Extra large shadow - dialogs
  static const List<BoxShadow> shadowXl = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 15,
      offset: Offset(0, 10),
    ),
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 50,
      offset: Offset(0, 25),
    ),
  ];

  // Uppercase aliases for backwards compatibility
  static const List<BoxShadow> shadowSM = shadowSm;
  static const List<BoxShadow> shadowMD = shadowMd;
  static const List<BoxShadow> shadowLG = shadowLg;
  static const List<BoxShadow> shadowXL = shadowXl;

  // ─────────────────────────────────────────────────────────────────────────────
  // Common Decorations
  // ─────────────────────────────────────────────────────────────────────────────
  
  /// Standard card decoration
  static BoxDecoration cardDecoration = BoxDecoration(
    color: surfaceColor,
    borderRadius: BorderRadius.circular(radiusMd),
    boxShadow: shadowSm,
  );
  
  /// Elevated card decoration
  static BoxDecoration cardDecorationElevated = BoxDecoration(
    color: surfaceColor,
    borderRadius: BorderRadius.circular(radiusMd),
    boxShadow: shadowMd,
  );

  // ─────────────────────────────────────────────────────────────────────────────
  // Animation Durations
  // ─────────────────────────────────────────────────────────────────────────────
  
  /// Fast duration - 150ms (micro-interactions)
  static const Duration durationFast = Duration(milliseconds: 150);
  
  /// Normal duration - 250ms (standard transitions)
  static const Duration durationNormal = Duration(milliseconds: 250);
  
  /// Slow duration - 350ms (complex animations)
  static const Duration durationSlow = Duration(milliseconds: 350);

  // ─────────────────────────────────────────────────────────────────────────────
  // Theme Data
  // ─────────────────────────────────────────────────────────────────────────────
  
  /// Light theme configuration
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      error: errorColor,
      onPrimary: textOnPrimary,
      onSecondary: textOnPrimary,
      onSurface: textPrimary,
      onError: textOnPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: surfaceColor,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: titleLarge,
    ),
    cardTheme: CardThemeData(
      color: surfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        side: const BorderSide(color: borderColor),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: errorColor),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacingMd,
        vertical: spacingSm,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: textOnPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: spacingLg,
          vertical: spacingMd,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        textStyle: labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        padding: const EdgeInsets.symmetric(
          horizontal: spacingLg,
          vertical: spacingMd,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        textStyle: labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingSm,
        ),
        textStyle: labelLarge,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: dividerColor,
      thickness: 1,
      space: spacingMd,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: textPrimary,
      contentTextStyle: bodyMedium.copyWith(color: textOnPrimary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMd),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surfaceColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: textTertiary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: textOnPrimary,
      elevation: 4,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surfaceColor,
      selectedColor: primaryLight,
      labelStyle: labelMedium,
      padding: const EdgeInsets.symmetric(
        horizontal: spacingSm,
        vertical: spacingXs,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusFull),
        side: const BorderSide(color: borderColor),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryColor,
    ),
    textTheme: const TextTheme(
      displayLarge: displayLarge,
      displayMedium: displayMedium,
      displaySmall: displaySmall,
      headlineLarge: headlineLarge,
      headlineMedium: headlineMedium,
      headlineSmall: headlineSmall,
      titleLarge: titleLarge,
      titleMedium: titleMedium,
      titleSmall: titleSmall,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelLarge: labelLarge,
      labelMedium: labelMedium,
      labelSmall: labelSmall,
    ),
  );

  /// Dark theme configuration (optional - can be expanded later)
  static ThemeData get darkTheme => lightTheme.copyWith(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0F172A),
    colorScheme: const ColorScheme.dark(
      primary: primaryLight,
      secondary: secondaryLight,
      surface: Color(0xFF1E293B),
      error: errorColor,
      onPrimary: textPrimary,
      onSecondary: textPrimary,
      onSurface: Color(0xFFF8FAFC),
      onError: textOnPrimary,
    ),
  );
}
