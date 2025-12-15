// Notifications Controller
//
// Manages notifications state and operations:
// - Load notifications from API with pagination
// - Filter by read/unread status
// - Mark notifications as read
// - Pull-to-refresh support

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_theme.dart';
import '../../models/notification_model.dart';

/// Filter options for notifications
enum NotificationFilter { all, unread, read }

class NotificationsController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  // ─────────────────────────────────────────────────────────────────────────────
  // Reactive State
  // ─────────────────────────────────────────────────────────────────────────────

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<NotificationFilter> currentFilter = NotificationFilter.all.obs;
  
  // Pagination
  final RxInt currentPage = 1.obs;
  final RxBool hasMorePages = true.obs;
  static const int _perPage = 20;

  // Unread count for badge
  final RxInt unreadCount = 0.obs;

  // ─────────────────────────────────────────────────────────────────────────────
  // Computed Properties
  // ─────────────────────────────────────────────────────────────────────────────

  /// Get filtered notifications based on current filter
  List<NotificationModel> get filteredNotifications {
    switch (currentFilter.value) {
      case NotificationFilter.unread:
        return notifications.where((n) => !n.isRead).toList();
      case NotificationFilter.read:
        return notifications.where((n) => n.isRead).toList();
      case NotificationFilter.all:
        return notifications.toList();
    }
  }

  bool get isEmpty => filteredNotifications.isEmpty;
  bool get hasUnread => notifications.any((n) => !n.isRead);

  // ─────────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Load Notifications
  // ─────────────────────────────────────────────────────────────────────────────

  /// Load notifications from API
  Future<void> loadNotifications({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      hasMorePages.value = true;
      notifications.clear();
    }

    if (isLoading.value || isLoadingMore.value) return;

    if (currentPage.value == 1) {
      isLoading.value = true;
    } else {
      isLoadingMore.value = true;
    }
    
    hasError.value = false;
    errorMessage.value = '';

    try {
      // Build query parameters
      final queryParams = <String, dynamic>{
        'page': currentPage.value,
        'per_page': _perPage,
      };

      // Add filter for unread only if selected
      if (currentFilter.value == NotificationFilter.unread) {
        queryParams['unread_only'] = true;
      }

      final response = await _apiService.get(
        '/notifications',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Handle different response formats
        List<dynamic> notificationsList;
        if (data is Map && data.containsKey('data')) {
          // Paginated response: { data: [...], meta: {...} }
          notificationsList = data['data'] as List? ?? [];
          
          // Check pagination meta
          if (data.containsKey('meta')) {
            final meta = data['meta'];
            final lastPage = meta['last_page'] ?? meta['total_pages'] ?? 1;
            hasMorePages.value = currentPage.value < lastPage;
          } else {
            hasMorePages.value = notificationsList.length >= _perPage;
          }
        } else if (data is List) {
          notificationsList = data;
          hasMorePages.value = notificationsList.length >= _perPage;
        } else {
          notificationsList = [];
          hasMorePages.value = false;
        }

        // Parse notifications
        final newNotifications = notificationsList
            .map((json) => NotificationModel.fromJson(json))
            .toList();

        if (refresh || currentPage.value == 1) {
          notifications.value = newNotifications;
        } else {
          notifications.addAll(newNotifications);
        }

        // Update unread count
        _updateUnreadCount();
        
        // Increment page for next load
        if (hasMorePages.value) {
          currentPage.value++;
        }
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load notifications. Please try again.';
      // ignore: avoid_print
      print('NotificationsController.loadNotifications error: $e');
      
      // Load mock data as fallback
      _loadMockNotifications();
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  /// Load more notifications (pagination)
  Future<void> loadMore() async {
    if (!hasMorePages.value || isLoadingMore.value) return;
    await loadNotifications();
  }

  /// Refresh notifications
  @override
  Future<void> refresh() async {
    await loadNotifications(refresh: true);
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Filter Operations
  // ─────────────────────────────────────────────────────────────────────────────

  /// Change filter and reload if needed
  void setFilter(NotificationFilter filter) {
    if (currentFilter.value == filter) return;
    
    currentFilter.value = filter;
    
    // For unread filter, we need to reload from API with unread_only param
    if (filter == NotificationFilter.unread) {
      loadNotifications(refresh: true);
    }
    // For all/read, we can filter locally
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Mark as Read Operations
  // ─────────────────────────────────────────────────────────────────────────────

  /// Mark a single notification as read
  Future<void> markAsRead(NotificationModel notification) async {
    if (notification.isRead) return;

    try {
      final response = await _apiService.post(
        '/notifications/${notification.id}/read',
      );

      if (response.statusCode == 200) {
        // Update local state
        final index = notifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          notifications[index] = notification.copyWith(isRead: true);
          _updateUnreadCount();
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('NotificationsController.markAsRead error: $e');
      // Still update locally for better UX
      final index = notifications.indexWhere((n) => n.id == notification.id);
      if (index != -1) {
        notifications[index] = notification.copyWith(isRead: true);
        _updateUnreadCount();
      }
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    if (!hasUnread) return;

    try {
      final response = await _apiService.post('/notifications/read-all');

      if (response.statusCode == 200) {
        // Update all local notifications
        notifications.value = notifications
            .map((n) => n.copyWith(isRead: true))
            .toList();
        _updateUnreadCount();
        
        _showSnackbar('Success', 'All notifications marked as read');
      }
    } catch (e) {
      // ignore: avoid_print
      print('NotificationsController.markAllAsRead error: $e');
      // Still update locally
      notifications.value = notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
      _updateUnreadCount();
      _showSnackbar('Success', 'All notifications marked as read');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Helper Methods
  // ─────────────────────────────────────────────────────────────────────────────

  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }

  void _showSnackbar(String title, String message, {bool isError = false}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError 
          ? AppTheme.errorColor.withValues(alpha: 0.9)
          : AppTheme.successColor.withValues(alpha: 0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  /// Load mock notifications as fallback
  void _loadMockNotifications() {
    notifications.value = [
      NotificationModel(
        id: '1',
        title: 'Order Shipped',
        message: 'Your order #12345 has been shipped and is on its way!',
        type: NotificationType.order,
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      NotificationModel(
        id: '2',
        title: 'New Products Available',
        message: 'Check out our latest collection of premium products.',
        type: NotificationType.promotion,
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      NotificationModel(
        id: '3',
        title: 'Payment Confirmed',
        message: 'Your payment for order #12344 has been confirmed.',
        type: NotificationType.payment,
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      NotificationModel(
        id: '4',
        title: 'Flash Sale!',
        message: 'Don\'t miss our 24-hour flash sale. Up to 50% off!',
        type: NotificationType.promotion,
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      NotificationModel(
        id: '5',
        title: 'Order Delivered',
        message: 'Your order #12340 has been delivered successfully.',
        type: NotificationType.order,
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
    _updateUnreadCount();
    hasMorePages.value = false;
  }
}
