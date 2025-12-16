import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/data.dart';

/// Notification Controller
/// Manages push notifications, in-app notifications, and preferences
class NotificationController extends GetxController {
  final NotificationRepository _notificationRepository;

  NotificationController({
    NotificationRepository? notificationRepository,
  }) : _notificationRepository = notificationRepository ?? NotificationRepository(Get.find());

  // Observable state
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxList<NotificationModel> unreadNotifications = <NotificationModel>[].obs;
  
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isUpdating = false.obs;
  
  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxBool hasMore = true.obs;
  
  // Unread count
  final RxInt unreadCount = 0.obs;
  
  // Filter
  final Rx<NotificationType?> typeFilter = Rx<NotificationType?>(null);
  
  // Preferences
  final RxMap<String, bool> preferences = <String, bool>{}.obs;
  
  final RxString errorMessage = ''.obs;

  // Getters
  int get notificationCount => notifications.length;
  bool get hasUnread => unreadCount.value > 0;
  bool get isEmpty => notifications.isEmpty;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
    loadUnreadCount();
    loadPreferences();
  }

  /// Load notifications
  Future<void> loadNotifications({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      hasMore.value = true;
      notifications.clear();
    }

    if (!hasMore.value && !refresh) return;

    isLoading.value = refresh || notifications.isEmpty;
    isLoadingMore.value = !refresh && notifications.isNotEmpty;
    errorMessage.value = '';

    try {
      final response = await _notificationRepository.getNotifications(
        page: currentPage.value,
        perPage: 20,
        type: typeFilter.value,
      );

      if (refresh) {
        notifications.value = response.data;
      } else {
        notifications.addAll(response.data);
      }

      currentPage.value = response.currentPage;
      totalPages.value = response.lastPage;
      hasMore.value = response.hasNextPage;

      // Update unread list
      unreadNotifications.value = notifications.where((n) => !n.isRead).toList();
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      if (!e.message.toLowerCase().contains('empty')) {
        _showError(e.message);
      }
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  /// Load more notifications (pagination)
  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;
    currentPage.value++;
    await loadNotifications();
  }

  /// Load unread count
  Future<void> loadUnreadCount() async {
    try {
      final count = await _notificationRepository.getUnreadCount();
      unreadCount.value = count;
    } catch (e) {
      // Silently fail
    }
  }

  /// Mark notification as read
  Future<bool> markAsRead(int notificationId) async {
    isUpdating.value = true;

    // Optimistic update
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 && !notifications[index].isRead) {
      notifications[index] = NotificationModel(
        id: notifications[index].id,
        title: notifications[index].title,
        body: notifications[index].body,
        type: notifications[index].type,
        data: notifications[index].data,
        imageUrl: notifications[index].imageUrl,
        actionUrl: notifications[index].actionUrl,
        isRead: true,
        readAt: DateTime.now(),
        createdAt: notifications[index].createdAt,
      );
      notifications.refresh();
      unreadCount.value = (unreadCount.value - 1).clamp(0, 999);
    }

    try {
      await _notificationRepository.markAsRead(notificationId);
      unreadNotifications.value = notifications.where((n) => !n.isRead).toList();
      return true;
    } on ApiException catch (e) {
      // Revert optimistic update
      await loadNotifications(refresh: true);
      await loadUnreadCount();
      _showError(e.message);
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  /// Mark notification as unread
  Future<bool> markAsUnread(int notificationId) async {
    isUpdating.value = true;

    try {
      await _notificationRepository.markAsUnread(notificationId);
      
      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        notifications[index] = NotificationModel(
          id: notifications[index].id,
          title: notifications[index].title,
          body: notifications[index].body,
          type: notifications[index].type,
          data: notifications[index].data,
          imageUrl: notifications[index].imageUrl,
          actionUrl: notifications[index].actionUrl,
          isRead: false,
          readAt: null,
          createdAt: notifications[index].createdAt,
        );
        notifications.refresh();
        unreadCount.value++;
      }

      unreadNotifications.value = notifications.where((n) => !n.isRead).toList();
      return true;
    } on ApiException catch (e) {
      _showError(e.message);
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  /// Mark all as read
  Future<bool> markAllAsRead() async {
    if (unreadCount.value == 0) return true;

    isUpdating.value = true;

    try {
      await _notificationRepository.markAllAsRead();
      
      // Update all notifications
      for (int i = 0; i < notifications.length; i++) {
        if (!notifications[i].isRead) {
          notifications[i] = NotificationModel(
            id: notifications[i].id,
            title: notifications[i].title,
            body: notifications[i].body,
            type: notifications[i].type,
            data: notifications[i].data,
            imageUrl: notifications[i].imageUrl,
            actionUrl: notifications[i].actionUrl,
            isRead: true,
            readAt: DateTime.now(),
            createdAt: notifications[i].createdAt,
          );
        }
      }
      notifications.refresh();
      
      unreadCount.value = 0;
      unreadNotifications.clear();

      Get.snackbar(
        'Done',
        'All notifications marked as read',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );

      return true;
    } on ApiException catch (e) {
      _showError(e.message);
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  /// Delete notification
  Future<bool> deleteNotification(int notificationId) async {
    isUpdating.value = true;

    // Optimistic update
    final removedNotification = notifications.firstWhereOrNull((n) => n.id == notificationId);
    final removedIndex = notifications.indexWhere((n) => n.id == notificationId);
    notifications.removeWhere((n) => n.id == notificationId);
    
    if (removedNotification != null && !removedNotification.isRead) {
      unreadCount.value = (unreadCount.value - 1).clamp(0, 999);
    }

    try {
      await _notificationRepository.deleteNotification(notificationId);
      unreadNotifications.value = notifications.where((n) => !n.isRead).toList();
      return true;
    } on ApiException catch (e) {
      // Revert optimistic update
      if (removedNotification != null && removedIndex != -1) {
        notifications.insert(removedIndex, removedNotification);
        if (!removedNotification.isRead) {
          unreadCount.value++;
        }
      }
      _showError(e.message);
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  /// Delete multiple notifications
  Future<bool> deleteMultiple(List<int> notificationIds) async {
    if (notificationIds.isEmpty) return true;

    isUpdating.value = true;

    try {
      await _notificationRepository.deleteMultiple(notificationIds);
      
      notifications.removeWhere((n) => notificationIds.contains(n.id));
      await loadUnreadCount();
      unreadNotifications.value = notifications.where((n) => !n.isRead).toList();

      Get.snackbar(
        'Deleted',
        '${notificationIds.length} notifications deleted',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.grey.shade100,
        colorText: Colors.grey.shade900,
      );

      return true;
    } on ApiException catch (e) {
      _showError(e.message);
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  /// Clear all notifications
  Future<bool> clearAll() async {
    if (notifications.isEmpty) return true;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Clear All'),
        content: const Text('Are you sure you want to delete all notifications?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed != true) return false;

    isUpdating.value = true;

    try {
      final ids = notifications.map((n) => n.id).toList();
      await _notificationRepository.deleteMultiple(ids);
      
      notifications.clear();
      unreadNotifications.clear();
      unreadCount.value = 0;

      Get.snackbar(
        'Cleared',
        'All notifications have been deleted',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.grey.shade100,
        colorText: Colors.grey.shade900,
      );

      return true;
    } on ApiException catch (e) {
      _showError(e.message);
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  /// Load preferences
  Future<void> loadPreferences() async {
    try {
      final prefs = await _notificationRepository.getPreferences();
      preferences.value = Map<String, bool>.from(prefs);
    } catch (e) {
      // Use defaults
      preferences.value = {
        'order_updates': true,
        'promotions': true,
        'new_products': true,
        'price_alerts': true,
        'newsletter': false,
      };
    }
  }

  /// Update preferences
  Future<bool> updatePreferences(Map<String, bool> newPreferences) async {
    try {
      await _notificationRepository.updatePreferences(newPreferences);
      preferences.value = newPreferences;

      Get.snackbar(
        'Saved',
        'Notification preferences updated',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );

      return true;
    } on ApiException catch (e) {
      _showError(e.message);
      return false;
    }
  }

  /// Toggle preference
  Future<bool> togglePreference(String key) async {
    final current = preferences[key] ?? false;
    final newPrefs = Map<String, bool>.from(preferences);
    newPrefs[key] = !current;
    return updatePreferences(newPrefs);
  }

  /// Register device for push notifications
  Future<void> registerDevice(String fcmToken) async {
    try {
      await _notificationRepository.registerDevice(
        token: fcmToken,
        platform: GetPlatform.isIOS ? 'ios' : 'android',
      );
    } catch (e) {
      // Silently fail
    }
  }

  /// Filter by type
  void filterByType(NotificationType? type) {
    typeFilter.value = type;
    loadNotifications(refresh: true);
  }

  /// Clear filter
  void clearFilter() {
    typeFilter.value = null;
    loadNotifications(refresh: true);
  }

  /// Handle notification tap
  void handleNotificationTap(NotificationModel notification) {
    // Mark as read
    if (!notification.isRead) {
      markAsRead(notification.id);
    }

    // Navigate based on type or action URL
    if (notification.actionUrl != null && notification.actionUrl!.isNotEmpty) {
      _navigateToUrl(notification.actionUrl!);
    } else {
      _navigateByType(notification);
    }
  }

  /// Navigate to URL
  void _navigateToUrl(String url) {
    // Parse internal URLs
    if (url.startsWith('/')) {
      Get.toNamed(url);
    } else if (url.contains('product/')) {
      final productId = _extractId(url, 'product');
      if (productId != null) {
        Get.toNamed('/product/$productId');
      }
    } else if (url.contains('invoice/') || url.contains('order/')) {
      final invoiceId = _extractId(url, 'invoice') ?? _extractId(url, 'order');
      if (invoiceId != null) {
        Get.toNamed('/invoice/$invoiceId');
      }
    }
  }

  /// Navigate by notification type
  void _navigateByType(NotificationModel notification) {
    switch (notification.type) {
      case NotificationType.order:
      case NotificationType.orderStatus:
        final orderId = notification.data?['order_id'] ?? notification.data?['invoice_id'];
        if (orderId != null) {
          Get.toNamed('/invoice/$orderId');
        } else {
          Get.toNamed('/orders');
        }
        break;
      case NotificationType.promotion:
      case NotificationType.promo:
        Get.toNamed('/promotions');
        break;
      case NotificationType.product:
      case NotificationType.newProduct:
        final productId = notification.data?['product_id'];
        if (productId != null) {
          Get.toNamed('/product/$productId');
        } else {
          Get.toNamed('/products');
        }
        break;
      case NotificationType.priceAlert:
        Get.toNamed('/wishlist');
        break;
      default:
        // Stay on notifications page
        break;
    }
  }

  /// Extract ID from URL
  int? _extractId(String url, String segment) {
    final regex = RegExp('$segment/(\\d+)');
    final match = regex.firstMatch(url);
    if (match != null) {
      return int.tryParse(match.group(1) ?? '');
    }
    return null;
  }

  /// Refresh notifications
  Future<void> refresh() async {
    await Future.wait([
      loadNotifications(refresh: true),
      loadUnreadCount(),
    ]);
  }

  /// Show error snackbar
  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade900,
      duration: const Duration(seconds: 3),
    );
  }
}
