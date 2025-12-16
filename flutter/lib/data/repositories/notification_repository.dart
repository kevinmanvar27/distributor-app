import '../providers/api_provider.dart';
import '../models/models.dart';

/// Notification Repository - Handles notification API calls
class NotificationRepository {
  final ApiProvider _api;

  NotificationRepository(this._api);

  /// Get all notifications with pagination
  Future<PaginatedResponse<NotificationModel>> getNotifications({
    int page = 1,
    int perPage = 20,
    bool? unreadOnly,
    NotificationType? type,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
      if (unreadOnly == true) 'unread': '1',
      if (type != null) 'type': type.value,
    };

    return _api.getPaginated<NotificationModel>(
      '/api/v1/notifications',
      queryParams: queryParams,
      fromJsonT: (json) => NotificationModel.fromJson(json),
    );
  }

  /// Get notifications model (with counts)
  Future<NotificationsModel> getNotificationsModel() async {
    final response = await _api.get<Map<String, dynamic>>(
      '/api/v1/notifications',
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      return NotificationsModel.empty();
    }

    return NotificationsModel.fromJson(response.data!);
  }

  /// Get single notification
  Future<NotificationModel> getNotification(String id) async {
    final response = await _api.get<Map<String, dynamic>>(
      '/api/v1/notifications/$id',
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        message: response.message ?? 'Notification not found',
        statusCode: response.statusCode,
      );
    }

    return NotificationModel.fromJson(response.data!);
  }

  /// Mark notification as read
  Future<NotificationModel> markAsRead(String id) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/api/v1/notifications/$id/read',
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        message: response.message ?? 'Failed to mark as read',
        statusCode: response.statusCode,
      );
    }

    return NotificationModel.fromJson(response.data!);
  }

  /// Mark notification as unread
  Future<NotificationModel> markAsUnread(String id) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/api/v1/notifications/$id/unread',
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        message: response.message ?? 'Failed to mark as unread',
        statusCode: response.statusCode,
      );
    }

    return NotificationModel.fromJson(response.data!);
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    final response = await _api.post('/api/v1/notifications/read-all');

    if (!response.success) {
      throw ApiException(
        message: response.message ?? 'Failed to mark all as read',
        statusCode: response.statusCode,
      );
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String id) async {
    final response = await _api.delete('/api/v1/notifications/$id');

    if (!response.success) {
      throw ApiException(
        message: response.message ?? 'Failed to delete notification',
        statusCode: response.statusCode,
      );
    }
  }

  /// Delete all notifications
  Future<void> deleteAllNotifications() async {
    final response = await _api.delete('/api/v1/notifications');

    if (!response.success) {
      throw ApiException(
        message: response.message ?? 'Failed to delete notifications',
        statusCode: response.statusCode,
      );
    }
  }

  /// Get unread count
  Future<int> getUnreadCount() async {
    final response = await _api.get<Map<String, dynamic>>(
      '/api/v1/notifications/unread-count',
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      return 0;
    }

    return response.data!['count'] ?? response.data!['unread_count'] ?? 0;
  }

  /// Get notification preferences
  Future<Map<String, bool>> getPreferences() async {
    final response = await _api.get<Map<String, dynamic>>(
      '/api/v1/notifications/preferences',
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      return {};
    }

    return response.data!.map((key, value) => MapEntry(key, value == true));
  }

  /// Update notification preferences
  Future<void> updatePreferences(Map<String, bool> preferences) async {
    final response = await _api.put(
      '/api/v1/notifications/preferences',
      body: preferences,
    );

    if (!response.success) {
      throw ApiException(
        message: response.message ?? 'Failed to update preferences',
        statusCode: response.statusCode,
      );
    }
  }

  /// Register device for push notifications
  Future<void> registerDevice({
    required String fcmToken,
    String? deviceType,
    String? deviceName,
  }) async {
    final response = await _api.post(
      '/api/v1/notifications/register-device',
      body: {
        'fcm_token': fcmToken,
        if (deviceType != null) 'device_type': deviceType,
        if (deviceName != null) 'device_name': deviceName,
      },
    );

    if (!response.success) {
      throw ApiException(
        message: response.message ?? 'Failed to register device',
        statusCode: response.statusCode,
      );
    }
  }

  /// Unregister device from push notifications
  Future<void> unregisterDevice(String fcmToken) async {
    final response = await _api.post(
      '/api/v1/notifications/unregister-device',
      body: {'fcm_token': fcmToken},
    );

    if (!response.success) {
      throw ApiException(
        message: response.message ?? 'Failed to unregister device',
        statusCode: response.statusCode,
      );
    }
  }

  /// Get notifications by type
  Future<PaginatedResponse<NotificationModel>> getNotificationsByType(
    NotificationType type, {
    int page = 1,
    int perPage = 20,
  }) async {
    return _api.getPaginated<NotificationModel>(
      '/api/v1/notifications/type/${type.value}',
      queryParams: {'page': page, 'per_page': perPage},
      fromJsonT: (json) => NotificationModel.fromJson(json),
    );
  }

  /// Get recent notifications
  Future<List<NotificationModel>> getRecentNotifications({int limit = 5}) async {
    final response = await _api.get<List<dynamic>>(
      '/api/v1/notifications/recent',
      queryParams: {'limit': limit},
      fromJsonT: (data) => data as List<dynamic>,
    );

    if (!response.success || response.data == null) {
      return [];
    }

    return response.data!
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Mark multiple notifications as read
  Future<void> markMultipleAsRead(List<String> ids) async {
    final response = await _api.post(
      '/api/v1/notifications/read-multiple',
      body: {'ids': ids},
    );

    if (!response.success) {
      throw ApiException(
        message: response.message ?? 'Failed to mark notifications as read',
        statusCode: response.statusCode,
      );
    }
  }

  /// Delete multiple notifications
  Future<void> deleteMultiple(List<String> ids) async {
    final response = await _api.delete(
      '/api/v1/notifications/delete-multiple',
      body: {'ids': ids},
    );

    if (!response.success) {
      throw ApiException(
        message: response.message ?? 'Failed to delete notifications',
        statusCode: response.statusCode,
      );
    }
  }
}
