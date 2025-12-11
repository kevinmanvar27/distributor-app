import '../providers/api_provider.dart';
import '../models/models.dart';

/// Settings Repository - Handles app settings and configuration API calls
class SettingsRepository {
  final ApiProvider _api;

  SettingsRepository(this._api);

  /// Get app settings (theme, branding, features)
  Future<AppSettingsModel> getAppSettings() async {
    final response = await _api.get<Map<String, dynamic>>(
      '/api/v1/app-settings',
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      return AppSettingsModel.defaults();
    }

    return AppSettingsModel.fromJson(response.data!);
  }

  /// Get app configuration
  Future<AppConfigModel> getAppConfig() async {
    final response = await _api.get<Map<String, dynamic>>(
      '/api/v1/app-config',
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      return AppConfigModel.defaults();
    }

    return AppConfigModel.fromJson(response.data!);
  }

  /// Get company info
  Future<CompanyInfoModel> getCompanyInfo() async {
    final response = await _api.get<Map<String, dynamic>>(
      '/api/v1/company-info',
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      return CompanyInfoModel.defaults();
    }

    return CompanyInfoModel.fromJson(response.data!);
  }

  /// Get all settings at once (combined endpoint)
  Future<Map<String, dynamic>> getAllSettings() async {
    final response = await _api.get<Map<String, dynamic>>(
      '/api/v1/settings',
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      return {};
    }

    return response.data!;
  }

  /// Check for app updates
  Future<AppVersionInfo> checkForUpdates({
    required String currentVersion,
    required String platform,
  }) async {
    final response = await _api.get<Map<String, dynamic>>(
      '/api/v1/app-version',
      queryParams: {
        'current_version': currentVersion,
        'platform': platform,
      },
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      return AppVersionInfo(
        currentVersion: currentVersion,
        latestVersion: currentVersion,
        updateAvailable: false,
        forceUpdate: false,
      );
    }

    return AppVersionInfo.fromJson(response.data!);
  }

  /// Get maintenance status
  Future<MaintenanceInfo> getMaintenanceStatus() async {
    final response = await _api.get<Map<String, dynamic>>(
      '/api/v1/maintenance-status',
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      return MaintenanceInfo(isUnderMaintenance: false);
    }

    return MaintenanceInfo.fromJson(response.data!);
  }

  /// Get terms and conditions
  Future<String> getTermsAndConditions() async {
    final response = await _api.get<Map<String, dynamic>>(
      '/api/v1/pages/terms',
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      return '';
    }

    return response.data!['content'] ?? '';
  }

  /// Get privacy policy
  Future<String> getPrivacyPolicy() async {
    final response = await _api.get<Map<String, dynamic>>(
      '/api/v1/pages/privacy',
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      return '';
    }

    return response.data!['content'] ?? '';
  }

  /// Get about us
  Future<String> getAboutUs() async {
    final response = await _api.get<Map<String, dynamic>>(
      '/api/v1/pages/about',
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      return '';
    }

    return response.data!['content'] ?? '';
  }

  /// Get FAQ
  Future<List<Map<String, String>>> getFaq() async {
    final response = await _api.get<List<dynamic>>(
      '/api/v1/pages/faq',
      fromJsonT: (data) => data as List<dynamic>,
    );

    if (!response.success || response.data == null) {
      return [];
    }

    return response.data!.map((e) {
      final item = e as Map<String, dynamic>;
      return {
        'question': item['question']?.toString() ?? '',
        'answer': item['answer']?.toString() ?? '',
      };
    }).toList();
  }

  /// Get return policy
  Future<String> getReturnPolicy() async {
    final response = await _api.get<Map<String, dynamic>>(
      '/api/v1/pages/return-policy',
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      return '';
    }

    return response.data!['content'] ?? '';
  }

  /// Get shipping policy
  Future<String> getShippingPolicy() async {
    final response = await _api.get<Map<String, dynamic>>(
      '/api/v1/pages/shipping-policy',
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      return '';
    }

    return response.data!['content'] ?? '';
  }

  /// Submit contact form
  Future<void> submitContactForm({
    required String name,
    required String email,
    required String subject,
    required String message,
    String? phone,
  }) async {
    final response = await _api.post(
      '/api/v1/contact',
      body: {
        'name': name,
        'email': email,
        'subject': subject,
        'message': message,
        if (phone != null) 'phone': phone,
      },
    );

    if (!response.success) {
      throw ApiException(
        message: response.message ?? 'Failed to submit contact form',
        statusCode: response.statusCode,
        errors: response.errors,
      );
    }
  }

  /// Submit feedback
  Future<void> submitFeedback({
    required String feedback,
    int? rating,
    String? category,
  }) async {
    final response = await _api.post(
      '/api/v1/feedback',
      body: {
        'feedback': feedback,
        if (rating != null) 'rating': rating,
        if (category != null) 'category': category,
      },
    );

    if (!response.success) {
      throw ApiException(
        message: response.message ?? 'Failed to submit feedback',
        statusCode: response.statusCode,
      );
    }
  }

  /// Report issue
  Future<void> reportIssue({
    required String title,
    required String description,
    String? category,
    List<String>? screenshots,
  }) async {
    final response = await _api.post(
      '/api/v1/report-issue',
      body: {
        'title': title,
        'description': description,
        if (category != null) 'category': category,
        if (screenshots != null) 'screenshots': screenshots,
      },
    );

    if (!response.success) {
      throw ApiException(
        message: response.message ?? 'Failed to report issue',
        statusCode: response.statusCode,
      );
    }
  }

  /// Get banners/sliders
  Future<List<Map<String, dynamic>>> getBanners({String? position}) async {
    final response = await _api.get<List<dynamic>>(
      '/api/v1/banners',
      queryParams: {
        if (position != null) 'position': position,
      },
      fromJsonT: (data) => data as List<dynamic>,
    );

    if (!response.success || response.data == null) {
      return [];
    }

    return response.data!.map((e) => e as Map<String, dynamic>).toList();
  }

  /// Get announcements
  Future<List<Map<String, dynamic>>> getAnnouncements() async {
    final response = await _api.get<List<dynamic>>(
      '/api/v1/announcements',
      fromJsonT: (data) => data as List<dynamic>,
    );

    if (!response.success || response.data == null) {
      return [];
    }

    return response.data!.map((e) => e as Map<String, dynamic>).toList();
  }
}
