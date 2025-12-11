/// App Settings Model - Dynamic theming from API
class AppSettingsModel {
  final ThemeSettings theme;
  final BrandingSettings branding;
  final LayoutSettings layout;
  final FeatureSettings features;
  final Map<String, dynamic>? rawData;

  AppSettingsModel({
    required this.theme,
    required this.branding,
    required this.layout,
    required this.features,
    this.rawData,
  });

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) {
    return AppSettingsModel(
      theme: ThemeSettings.fromJson(json['theme'] ?? json['colors'] ?? json),
      branding: BrandingSettings.fromJson(json['branding'] ?? json),
      layout: LayoutSettings.fromJson(json['layout'] ?? json),
      features: FeatureSettings.fromJson(json['features'] ?? json),
      rawData: json,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'theme': theme.toJson(),
      'branding': branding.toJson(),
      'layout': layout.toJson(),
      'features': features.toJson(),
    };
  }

  /// Create default settings
  factory AppSettingsModel.defaults() {
    return AppSettingsModel(
      theme: ThemeSettings.defaults(),
      branding: BrandingSettings.defaults(),
      layout: LayoutSettings.defaults(),
      features: FeatureSettings.defaults(),
    );
  }
}

/// Theme Settings - Colors and typography
class ThemeSettings {
  // Primary colors
  final String primaryColor;
  final String primaryLightColor;
  final String primaryDarkColor;
  final String onPrimaryColor;

  // Secondary colors
  final String secondaryColor;
  final String secondaryLightColor;
  final String secondaryDarkColor;
  final String onSecondaryColor;

  // Accent/Tertiary colors
  final String accentColor;
  final String tertiaryColor;

  // Background colors
  final String backgroundColor;
  final String surfaceColor;
  final String cardColor;
  final String scaffoldColor;

  // Text colors
  final String textPrimaryColor;
  final String textSecondaryColor;
  final String textHintColor;
  final String textDisabledColor;

  // Status colors
  final String successColor;
  final String errorColor;
  final String warningColor;
  final String infoColor;

  // Other colors
  final String dividerColor;
  final String borderColor;
  final String shadowColor;
  final String overlayColor;

  // Typography
  final String fontFamily;
  final String headingFontFamily;
  final double baseFontSize;

  // Border radius
  final double borderRadiusSmall;
  final double borderRadiusMedium;
  final double borderRadiusLarge;

  // Elevation
  final double elevationSmall;
  final double elevationMedium;
  final double elevationLarge;

  ThemeSettings({
    required this.primaryColor,
    required this.primaryLightColor,
    required this.primaryDarkColor,
    required this.onPrimaryColor,
    required this.secondaryColor,
    required this.secondaryLightColor,
    required this.secondaryDarkColor,
    required this.onSecondaryColor,
    required this.accentColor,
    required this.tertiaryColor,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.cardColor,
    required this.scaffoldColor,
    required this.textPrimaryColor,
    required this.textSecondaryColor,
    required this.textHintColor,
    required this.textDisabledColor,
    required this.successColor,
    required this.errorColor,
    required this.warningColor,
    required this.infoColor,
    required this.dividerColor,
    required this.borderColor,
    required this.shadowColor,
    required this.overlayColor,
    required this.fontFamily,
    required this.headingFontFamily,
    required this.baseFontSize,
    required this.borderRadiusSmall,
    required this.borderRadiusMedium,
    required this.borderRadiusLarge,
    required this.elevationSmall,
    required this.elevationMedium,
    required this.elevationLarge,
  });

  factory ThemeSettings.fromJson(Map<String, dynamic> json) {
    return ThemeSettings(
      // Primary colors
      primaryColor: json['primary_color'] ?? json['primaryColor'] ?? '#1E88E5',
      primaryLightColor: json['primary_light_color'] ?? json['primaryLightColor'] ?? '#6AB7FF',
      primaryDarkColor: json['primary_dark_color'] ?? json['primaryDarkColor'] ?? '#005CB2',
      onPrimaryColor: json['on_primary_color'] ?? json['onPrimaryColor'] ?? '#FFFFFF',
      
      // Secondary colors
      secondaryColor: json['secondary_color'] ?? json['secondaryColor'] ?? '#26A69A',
      secondaryLightColor: json['secondary_light_color'] ?? json['secondaryLightColor'] ?? '#64D8CB',
      secondaryDarkColor: json['secondary_dark_color'] ?? json['secondaryDarkColor'] ?? '#00766C',
      onSecondaryColor: json['on_secondary_color'] ?? json['onSecondaryColor'] ?? '#FFFFFF',
      
      // Accent colors
      accentColor: json['accent_color'] ?? json['accentColor'] ?? '#FF7043',
      tertiaryColor: json['tertiary_color'] ?? json['tertiaryColor'] ?? '#7E57C2',
      
      // Background colors
      backgroundColor: json['background_color'] ?? json['backgroundColor'] ?? '#F5F5F5',
      surfaceColor: json['surface_color'] ?? json['surfaceColor'] ?? '#FFFFFF',
      cardColor: json['card_color'] ?? json['cardColor'] ?? '#FFFFFF',
      scaffoldColor: json['scaffold_color'] ?? json['scaffoldColor'] ?? '#FAFAFA',
      
      // Text colors
      textPrimaryColor: json['text_primary_color'] ?? json['textPrimaryColor'] ?? '#212121',
      textSecondaryColor: json['text_secondary_color'] ?? json['textSecondaryColor'] ?? '#757575',
      textHintColor: json['text_hint_color'] ?? json['textHintColor'] ?? '#9E9E9E',
      textDisabledColor: json['text_disabled_color'] ?? json['textDisabledColor'] ?? '#BDBDBD',
      
      // Status colors
      successColor: json['success_color'] ?? json['successColor'] ?? '#4CAF50',
      errorColor: json['error_color'] ?? json['errorColor'] ?? '#F44336',
      warningColor: json['warning_color'] ?? json['warningColor'] ?? '#FF9800',
      infoColor: json['info_color'] ?? json['infoColor'] ?? '#2196F3',
      
      // Other colors
      dividerColor: json['divider_color'] ?? json['dividerColor'] ?? '#E0E0E0',
      borderColor: json['border_color'] ?? json['borderColor'] ?? '#E0E0E0',
      shadowColor: json['shadow_color'] ?? json['shadowColor'] ?? '#000000',
      overlayColor: json['overlay_color'] ?? json['overlayColor'] ?? '#000000',
      
      // Typography
      fontFamily: json['font_family'] ?? json['fontFamily'] ?? 'Roboto',
      headingFontFamily: json['heading_font_family'] ?? json['headingFontFamily'] ?? 'Roboto',
      baseFontSize: _parseDouble(json['base_font_size'] ?? json['baseFontSize']) ?? 14.0,
      
      // Border radius
      borderRadiusSmall: _parseDouble(json['border_radius_small'] ?? json['borderRadiusSmall']) ?? 4.0,
      borderRadiusMedium: _parseDouble(json['border_radius_medium'] ?? json['borderRadiusMedium']) ?? 8.0,
      borderRadiusLarge: _parseDouble(json['border_radius_large'] ?? json['borderRadiusLarge']) ?? 16.0,
      
      // Elevation
      elevationSmall: _parseDouble(json['elevation_small'] ?? json['elevationSmall']) ?? 2.0,
      elevationMedium: _parseDouble(json['elevation_medium'] ?? json['elevationMedium']) ?? 4.0,
      elevationLarge: _parseDouble(json['elevation_large'] ?? json['elevationLarge']) ?? 8.0,
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'primary_color': primaryColor,
      'primary_light_color': primaryLightColor,
      'primary_dark_color': primaryDarkColor,
      'on_primary_color': onPrimaryColor,
      'secondary_color': secondaryColor,
      'secondary_light_color': secondaryLightColor,
      'secondary_dark_color': secondaryDarkColor,
      'on_secondary_color': onSecondaryColor,
      'accent_color': accentColor,
      'tertiary_color': tertiaryColor,
      'background_color': backgroundColor,
      'surface_color': surfaceColor,
      'card_color': cardColor,
      'scaffold_color': scaffoldColor,
      'text_primary_color': textPrimaryColor,
      'text_secondary_color': textSecondaryColor,
      'text_hint_color': textHintColor,
      'text_disabled_color': textDisabledColor,
      'success_color': successColor,
      'error_color': errorColor,
      'warning_color': warningColor,
      'info_color': infoColor,
      'divider_color': dividerColor,
      'border_color': borderColor,
      'shadow_color': shadowColor,
      'overlay_color': overlayColor,
      'font_family': fontFamily,
      'heading_font_family': headingFontFamily,
      'base_font_size': baseFontSize,
      'border_radius_small': borderRadiusSmall,
      'border_radius_medium': borderRadiusMedium,
      'border_radius_large': borderRadiusLarge,
      'elevation_small': elevationSmall,
      'elevation_medium': elevationMedium,
      'elevation_large': elevationLarge,
    };
  }

  factory ThemeSettings.defaults() {
    return ThemeSettings(
      primaryColor: '#1E88E5',
      primaryLightColor: '#6AB7FF',
      primaryDarkColor: '#005CB2',
      onPrimaryColor: '#FFFFFF',
      secondaryColor: '#26A69A',
      secondaryLightColor: '#64D8CB',
      secondaryDarkColor: '#00766C',
      onSecondaryColor: '#FFFFFF',
      accentColor: '#FF7043',
      tertiaryColor: '#7E57C2',
      backgroundColor: '#F5F5F5',
      surfaceColor: '#FFFFFF',
      cardColor: '#FFFFFF',
      scaffoldColor: '#FAFAFA',
      textPrimaryColor: '#212121',
      textSecondaryColor: '#757575',
      textHintColor: '#9E9E9E',
      textDisabledColor: '#BDBDBD',
      successColor: '#4CAF50',
      errorColor: '#F44336',
      warningColor: '#FF9800',
      infoColor: '#2196F3',
      dividerColor: '#E0E0E0',
      borderColor: '#E0E0E0',
      shadowColor: '#000000',
      overlayColor: '#000000',
      fontFamily: 'Roboto',
      headingFontFamily: 'Roboto',
      baseFontSize: 14.0,
      borderRadiusSmall: 4.0,
      borderRadiusMedium: 8.0,
      borderRadiusLarge: 16.0,
      elevationSmall: 2.0,
      elevationMedium: 4.0,
      elevationLarge: 8.0,
    );
  }
}

/// Branding Settings
class BrandingSettings {
  final String appName;
  final String? tagline;
  final String? logoUrl;
  final String? logoLightUrl;
  final String? logoDarkUrl;
  final String? iconUrl;
  final String? faviconUrl;
  final String? splashImageUrl;
  final String? companyName;
  final String? companyEmail;
  final String? companyPhone;
  final String? companyAddress;
  final String? companyWebsite;
  final Map<String, String>? socialLinks;

  BrandingSettings({
    required this.appName,
    this.tagline,
    this.logoUrl,
    this.logoLightUrl,
    this.logoDarkUrl,
    this.iconUrl,
    this.faviconUrl,
    this.splashImageUrl,
    this.companyName,
    this.companyEmail,
    this.companyPhone,
    this.companyAddress,
    this.companyWebsite,
    this.socialLinks,
  });

  factory BrandingSettings.fromJson(Map<String, dynamic> json) {
    Map<String, String>? social;
    if (json['social_links'] != null && json['social_links'] is Map) {
      social = Map<String, String>.from(
        (json['social_links'] as Map).map(
          (key, value) => MapEntry(key.toString(), value.toString()),
        ),
      );
    }

    return BrandingSettings(
      appName: json['app_name'] ?? json['appName'] ?? 'Distributor App',
      tagline: json['tagline'] ?? json['slogan'],
      logoUrl: json['logo_url'] ?? json['logoUrl'] ?? json['logo'],
      logoLightUrl: json['logo_light_url'] ?? json['logoLightUrl'],
      logoDarkUrl: json['logo_dark_url'] ?? json['logoDarkUrl'],
      iconUrl: json['icon_url'] ?? json['iconUrl'] ?? json['icon'],
      faviconUrl: json['favicon_url'] ?? json['faviconUrl'],
      splashImageUrl: json['splash_image_url'] ?? json['splashImageUrl'],
      companyName: json['company_name'] ?? json['companyName'],
      companyEmail: json['company_email'] ?? json['companyEmail'] ?? json['email'],
      companyPhone: json['company_phone'] ?? json['companyPhone'] ?? json['phone'],
      companyAddress: json['company_address'] ?? json['companyAddress'] ?? json['address'],
      companyWebsite: json['company_website'] ?? json['companyWebsite'] ?? json['website'],
      socialLinks: social,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'app_name': appName,
      'tagline': tagline,
      'logo_url': logoUrl,
      'logo_light_url': logoLightUrl,
      'logo_dark_url': logoDarkUrl,
      'icon_url': iconUrl,
      'favicon_url': faviconUrl,
      'splash_image_url': splashImageUrl,
      'company_name': companyName,
      'company_email': companyEmail,
      'company_phone': companyPhone,
      'company_address': companyAddress,
      'company_website': companyWebsite,
      'social_links': socialLinks,
    };
  }

  factory BrandingSettings.defaults() {
    return BrandingSettings(
      appName: 'Distributor App',
      tagline: 'Your B2B Distribution Partner',
    );
  }

  /// Get appropriate logo URL based on theme
  String? getLogoForTheme(bool isDark) {
    if (isDark && logoDarkUrl != null) return logoDarkUrl;
    if (!isDark && logoLightUrl != null) return logoLightUrl;
    return logoUrl;
  }
}

/// Layout Settings
class LayoutSettings {
  final int gridColumnsPhone;
  final int gridColumnsTablet;
  final int gridColumnsDesktop;
  final double productCardAspectRatio;
  final String productListStyle; // 'grid' or 'list'
  final bool showProductRating;
  final bool showProductStock;
  final bool showProductSku;
  final int homeCarouselCount;
  final int homeFeaturedCount;
  final int homeNewArrivalsCount;

  LayoutSettings({
    required this.gridColumnsPhone,
    required this.gridColumnsTablet,
    required this.gridColumnsDesktop,
    required this.productCardAspectRatio,
    required this.productListStyle,
    required this.showProductRating,
    required this.showProductStock,
    required this.showProductSku,
    required this.homeCarouselCount,
    required this.homeFeaturedCount,
    required this.homeNewArrivalsCount,
  });

  factory LayoutSettings.fromJson(Map<String, dynamic> json) {
    return LayoutSettings(
      gridColumnsPhone: json['grid_columns_phone'] ?? json['gridColumnsPhone'] ?? 2,
      gridColumnsTablet: json['grid_columns_tablet'] ?? json['gridColumnsTablet'] ?? 3,
      gridColumnsDesktop: json['grid_columns_desktop'] ?? json['gridColumnsDesktop'] ?? 4,
      productCardAspectRatio: _parseDouble(json['product_card_aspect_ratio'] ?? json['productCardAspectRatio']) ?? 0.75,
      productListStyle: json['product_list_style'] ?? json['productListStyle'] ?? 'grid',
      showProductRating: json['show_product_rating'] ?? json['showProductRating'] ?? true,
      showProductStock: json['show_product_stock'] ?? json['showProductStock'] ?? true,
      showProductSku: json['show_product_sku'] ?? json['showProductSku'] ?? false,
      homeCarouselCount: json['home_carousel_count'] ?? json['homeCarouselCount'] ?? 5,
      homeFeaturedCount: json['home_featured_count'] ?? json['homeFeaturedCount'] ?? 8,
      homeNewArrivalsCount: json['home_new_arrivals_count'] ?? json['homeNewArrivalsCount'] ?? 10,
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'grid_columns_phone': gridColumnsPhone,
      'grid_columns_tablet': gridColumnsTablet,
      'grid_columns_desktop': gridColumnsDesktop,
      'product_card_aspect_ratio': productCardAspectRatio,
      'product_list_style': productListStyle,
      'show_product_rating': showProductRating,
      'show_product_stock': showProductStock,
      'show_product_sku': showProductSku,
      'home_carousel_count': homeCarouselCount,
      'home_featured_count': homeFeaturedCount,
      'home_new_arrivals_count': homeNewArrivalsCount,
    };
  }

  factory LayoutSettings.defaults() {
    return LayoutSettings(
      gridColumnsPhone: 2,
      gridColumnsTablet: 3,
      gridColumnsDesktop: 4,
      productCardAspectRatio: 0.75,
      productListStyle: 'grid',
      showProductRating: true,
      showProductStock: true,
      showProductSku: false,
      homeCarouselCount: 5,
      homeFeaturedCount: 8,
      homeNewArrivalsCount: 10,
    );
  }
}

/// Feature Settings
class FeatureSettings {
  final bool enableWishlist;
  final bool enableCart;
  final bool enableSearch;
  final bool enableNotifications;
  final bool enableDarkMode;
  final bool enableGuestCheckout;
  final bool enableSocialLogin;
  final bool enableBiometricLogin;
  final bool enableProductReviews;
  final bool enableOrderTracking;
  final bool enableChatSupport;
  final bool enablePushNotifications;
  final bool requireApproval;
  final bool showPricesWithoutLogin;

  FeatureSettings({
    required this.enableWishlist,
    required this.enableCart,
    required this.enableSearch,
    required this.enableNotifications,
    required this.enableDarkMode,
    required this.enableGuestCheckout,
    required this.enableSocialLogin,
    required this.enableBiometricLogin,
    required this.enableProductReviews,
    required this.enableOrderTracking,
    required this.enableChatSupport,
    required this.enablePushNotifications,
    required this.requireApproval,
    required this.showPricesWithoutLogin,
  });

  factory FeatureSettings.fromJson(Map<String, dynamic> json) {
    return FeatureSettings(
      enableWishlist: json['enable_wishlist'] ?? json['enableWishlist'] ?? true,
      enableCart: json['enable_cart'] ?? json['enableCart'] ?? true,
      enableSearch: json['enable_search'] ?? json['enableSearch'] ?? true,
      enableNotifications: json['enable_notifications'] ?? json['enableNotifications'] ?? true,
      enableDarkMode: json['enable_dark_mode'] ?? json['enableDarkMode'] ?? true,
      enableGuestCheckout: json['enable_guest_checkout'] ?? json['enableGuestCheckout'] ?? false,
      enableSocialLogin: json['enable_social_login'] ?? json['enableSocialLogin'] ?? false,
      enableBiometricLogin: json['enable_biometric_login'] ?? json['enableBiometricLogin'] ?? false,
      enableProductReviews: json['enable_product_reviews'] ?? json['enableProductReviews'] ?? false,
      enableOrderTracking: json['enable_order_tracking'] ?? json['enableOrderTracking'] ?? true,
      enableChatSupport: json['enable_chat_support'] ?? json['enableChatSupport'] ?? false,
      enablePushNotifications: json['enable_push_notifications'] ?? json['enablePushNotifications'] ?? true,
      requireApproval: json['require_approval'] ?? json['requireApproval'] ?? true,
      showPricesWithoutLogin: json['show_prices_without_login'] ?? json['showPricesWithoutLogin'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enable_wishlist': enableWishlist,
      'enable_cart': enableCart,
      'enable_search': enableSearch,
      'enable_notifications': enableNotifications,
      'enable_dark_mode': enableDarkMode,
      'enable_guest_checkout': enableGuestCheckout,
      'enable_social_login': enableSocialLogin,
      'enable_biometric_login': enableBiometricLogin,
      'enable_product_reviews': enableProductReviews,
      'enable_order_tracking': enableOrderTracking,
      'enable_chat_support': enableChatSupport,
      'enable_push_notifications': enablePushNotifications,
      'require_approval': requireApproval,
      'show_prices_without_login': showPricesWithoutLogin,
    };
  }

  factory FeatureSettings.defaults() {
    return FeatureSettings(
      enableWishlist: true,
      enableCart: true,
      enableSearch: true,
      enableNotifications: true,
      enableDarkMode: true,
      enableGuestCheckout: false,
      enableSocialLogin: false,
      enableBiometricLogin: false,
      enableProductReviews: false,
      enableOrderTracking: true,
      enableChatSupport: false,
      enablePushNotifications: true,
      requireApproval: true,
      showPricesWithoutLogin: false,
    );
  }
}
