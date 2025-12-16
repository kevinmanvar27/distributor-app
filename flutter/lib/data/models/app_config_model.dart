/// App Config Model - Runtime configuration from API
class AppConfigModel {
  final String currencyCode;
  final String currencySymbol;
  final String currencyPosition; // 'before' or 'after'
  final int decimalPlaces;
  final String thousandsSeparator;
  final String decimalSeparator;
  final double taxRate;
  final String taxLabel;
  final bool taxInclusive;
  final int defaultPageSize;
  final int maxPageSize;
  final int minOrderAmount;
  final int? maxOrderAmount;
  final String dateFormat;
  final String timeFormat;
  final String timezone;
  final String defaultLanguage;
  final List<String> supportedLanguages;
  final AppVersionInfo? versionInfo;
  final MaintenanceInfo? maintenance;
  final Map<String, dynamic>? rawData;

  AppConfigModel({
    required this.currencyCode,
    required this.currencySymbol,
    required this.currencyPosition,
    required this.decimalPlaces,
    required this.thousandsSeparator,
    required this.decimalSeparator,
    required this.taxRate,
    required this.taxLabel,
    required this.taxInclusive,
    required this.defaultPageSize,
    required this.maxPageSize,
    required this.minOrderAmount,
    this.maxOrderAmount,
    required this.dateFormat,
    required this.timeFormat,
    required this.timezone,
    required this.defaultLanguage,
    required this.supportedLanguages,
    this.versionInfo,
    this.maintenance,
    this.rawData,
  });

  factory AppConfigModel.fromJson(Map<String, dynamic> json) {
    List<String> languages = ['en'];
    if (json['supported_languages'] != null && json['supported_languages'] is List) {
      languages = (json['supported_languages'] as List).map((e) => e.toString()).toList();
    }

    return AppConfigModel(
      currencyCode: json['currency_code'] ?? json['currencyCode'] ?? 'INR',
      currencySymbol: json['currency_symbol'] ?? json['currencySymbol'] ?? '₹',
      currencyPosition: json['currency_position'] ?? json['currencyPosition'] ?? 'before',
      decimalPlaces: json['decimal_places'] ?? json['decimalPlaces'] ?? 2,
      thousandsSeparator: json['thousands_separator'] ?? json['thousandsSeparator'] ?? ',',
      decimalSeparator: json['decimal_separator'] ?? json['decimalSeparator'] ?? '.',
      taxRate: _parseDouble(json['tax_rate'] ?? json['taxRate']) ?? 0.0,
      taxLabel: json['tax_label'] ?? json['taxLabel'] ?? 'GST',
      taxInclusive: json['tax_inclusive'] ?? json['taxInclusive'] ?? false,
      defaultPageSize: json['default_page_size'] ?? json['defaultPageSize'] ?? 15,
      maxPageSize: json['max_page_size'] ?? json['maxPageSize'] ?? 50,
      minOrderAmount: json['min_order_amount'] ?? json['minOrderAmount'] ?? 0,
      maxOrderAmount: json['max_order_amount'] ?? json['maxOrderAmount'],
      dateFormat: json['date_format'] ?? json['dateFormat'] ?? 'dd/MM/yyyy',
      timeFormat: json['time_format'] ?? json['timeFormat'] ?? 'HH:mm',
      timezone: json['timezone'] ?? 'Asia/Kolkata',
      defaultLanguage: json['default_language'] ?? json['defaultLanguage'] ?? 'en',
      supportedLanguages: languages,
      versionInfo: json['version'] != null || json['app_version'] != null
          ? AppVersionInfo.fromJson(json['version'] ?? json)
          : null,
      maintenance: json['maintenance'] != null
          ? MaintenanceInfo.fromJson(json['maintenance'])
          : null,
      rawData: json,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'currency_code': currencyCode,
      'currency_symbol': currencySymbol,
      'currency_position': currencyPosition,
      'decimal_places': decimalPlaces,
      'thousands_separator': thousandsSeparator,
      'decimal_separator': decimalSeparator,
      'tax_rate': taxRate,
      'tax_label': taxLabel,
      'tax_inclusive': taxInclusive,
      'default_page_size': defaultPageSize,
      'max_page_size': maxPageSize,
      'min_order_amount': minOrderAmount,
      'max_order_amount': maxOrderAmount,
      'date_format': dateFormat,
      'time_format': timeFormat,
      'timezone': timezone,
      'default_language': defaultLanguage,
      'supported_languages': supportedLanguages,
    };
  }

  factory AppConfigModel.defaults() {
    return AppConfigModel(
      currencyCode: 'INR',
      currencySymbol: '₹',
      currencyPosition: 'before',
      decimalPlaces: 2,
      thousandsSeparator: ',',
      decimalSeparator: '.',
      taxRate: 18.0,
      taxLabel: 'GST',
      taxInclusive: false,
      defaultPageSize: 15,
      maxPageSize: 50,
      minOrderAmount: 0,
      dateFormat: 'dd/MM/yyyy',
      timeFormat: 'HH:mm',
      timezone: 'Asia/Kolkata',
      defaultLanguage: 'en',
      supportedLanguages: ['en'],
    );
  }

  /// Format price with currency
  String formatPrice(double amount) {
    final formattedNumber = _formatNumber(amount);
    if (currencyPosition == 'after') {
      return '$formattedNumber $currencySymbol';
    }
    return '$currencySymbol$formattedNumber';
  }

  /// Format number with separators
  String _formatNumber(double number) {
    final parts = number.toStringAsFixed(decimalPlaces).split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '';

    // Add thousands separator
    final buffer = StringBuffer();
    for (int i = 0; i < integerPart.length; i++) {
      if (i > 0 && (integerPart.length - i) % 3 == 0) {
        buffer.write(thousandsSeparator);
      }
      buffer.write(integerPart[i]);
    }

    if (decimalPlaces > 0) {
      return '${buffer.toString()}$decimalSeparator$decimalPart';
    }
    return buffer.toString();
  }

  /// Calculate tax for amount
  double calculateTax(double amount) {
    if (taxInclusive) {
      return amount - (amount / (1 + taxRate / 100));
    }
    return amount * (taxRate / 100);
  }

  /// Get amount with tax
  double getAmountWithTax(double amount) {
    if (taxInclusive) return amount;
    return amount + calculateTax(amount);
  }

  /// Get amount without tax
  double getAmountWithoutTax(double amount) {
    if (!taxInclusive) return amount;
    return amount / (1 + taxRate / 100);
  }
}

/// App Version Info
class AppVersionInfo {
  final String currentVersion;
  final String? minVersion;
  final String? latestVersion;
  final bool forceUpdate;
  final String? updateUrl;
  final String? updateMessage;
  final String? releaseNotes;

  AppVersionInfo({
    required this.currentVersion,
    this.minVersion,
    this.latestVersion,
    this.forceUpdate = false,
    this.updateUrl,
    this.updateMessage,
    this.releaseNotes,
  });

  factory AppVersionInfo.fromJson(Map<String, dynamic> json) {
    return AppVersionInfo(
      currentVersion: json['current_version'] ?? json['app_version'] ?? json['version'] ?? '1.0.0',
      minVersion: json['min_version'] ?? json['minimum_version'],
      latestVersion: json['latest_version'],
      forceUpdate: json['force_update'] ?? json['forceUpdate'] ?? false,
      updateUrl: json['update_url'] ?? json['updateUrl'],
      updateMessage: json['update_message'] ?? json['updateMessage'],
      releaseNotes: json['release_notes'] ?? json['releaseNotes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_version': currentVersion,
      'min_version': minVersion,
      'latest_version': latestVersion,
      'force_update': forceUpdate,
      'update_url': updateUrl,
      'update_message': updateMessage,
      'release_notes': releaseNotes,
    };
  }

  /// Check if update is available
  bool get hasUpdate {
    if (latestVersion == null) return false;
    return _compareVersions(currentVersion, latestVersion!) < 0;
  }

  /// Check if update is required
  bool get requiresUpdate {
    if (minVersion == null) return false;
    return _compareVersions(currentVersion, minVersion!) < 0;
  }

  /// Compare version strings
  int _compareVersions(String v1, String v2) {
    final parts1 = v1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final parts2 = v2.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    final maxLength = parts1.length > parts2.length ? parts1.length : parts2.length;

    for (int i = 0; i < maxLength; i++) {
      final p1 = i < parts1.length ? parts1[i] : 0;
      final p2 = i < parts2.length ? parts2[i] : 0;

      if (p1 < p2) return -1;
      if (p1 > p2) return 1;
    }

    return 0;
  }
}

/// Maintenance Info
class MaintenanceInfo {
  final bool isEnabled;
  final String? message;
  final DateTime? startTime;
  final DateTime? endTime;
  final bool allowAdminAccess;

  MaintenanceInfo({
    required this.isEnabled,
    this.message,
    this.startTime,
    this.endTime,
    this.allowAdminAccess = true,
  });

  factory MaintenanceInfo.fromJson(Map<String, dynamic> json) {
    return MaintenanceInfo(
      isEnabled: json['is_enabled'] ?? json['enabled'] ?? json['maintenance_mode'] ?? false,
      message: json['message'] ?? json['maintenance_message'],
      startTime: json['start_time'] != null
          ? DateTime.tryParse(json['start_time'])
          : null,
      endTime: json['end_time'] != null
          ? DateTime.tryParse(json['end_time'])
          : null,
      allowAdminAccess: json['allow_admin_access'] ?? json['allowAdminAccess'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_enabled': isEnabled,
      'message': message,
      'start_time': startTime?.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'allow_admin_access': allowAdminAccess,
    };
  }

  /// Check if maintenance is currently active
  bool get isActive {
    if (!isEnabled) return false;

    final now = DateTime.now();
    if (startTime != null && now.isBefore(startTime!)) return false;
    if (endTime != null && now.isAfter(endTime!)) return false;

    return true;
  }

  /// Get estimated end time string
  String? get estimatedEndTime {
    if (endTime == null) return null;
    return '${endTime!.day}/${endTime!.month}/${endTime!.year} ${endTime!.hour}:${endTime!.minute.toString().padLeft(2, '0')}';
  }
}
