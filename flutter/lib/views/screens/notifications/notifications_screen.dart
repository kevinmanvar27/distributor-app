import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/controllers.dart';
import '../../../data/data.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Notifications Screen
/// Displays all user notifications with filtering and actions
class NotificationsScreen extends GetView<NotificationController> {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          Obx(() => controller.unreadCount.value > 0
              ? TextButton.icon(
                  onPressed: controller.markAllAsRead,
                  icon: const Icon(Icons.done_all, size: 18),
                  label: const Text('Mark all read'),
                )
              : const SizedBox.shrink()),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Notification Settings'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: ListTile(
                  leading: Icon(Icons.delete_sweep, color: Colors.red),
                  title: Text('Clear All', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter tabs
          _buildFilterTabs(context),
          // Notifications list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.notifications.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.notifications.isEmpty) {
                return _buildEmptyState(context);
              }

              return RefreshIndicator(
                onRefresh: controller.refreshNotifications,
                child: _buildNotificationsList(context),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Obx(() => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(context, 'All', null),
                _buildFilterChip(context, 'Unread', 'unread'),
                _buildFilterChip(context, 'Orders', 'order'),
                _buildFilterChip(context, 'Promotions', 'promotion'),
                _buildFilterChip(context, 'System', 'system'),
              ],
            ),
          )),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, String? filter) {
    final isSelected = controller.currentFilter.value == filter;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => controller.filterNotifications(filter),
        selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
        checkmarkColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'No notifications',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            "You're all caught up!",
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(BuildContext context) {
    // Group notifications by date
    final groupedNotifications = _groupNotificationsByDate();

    return ListView.builder(
      itemCount: groupedNotifications.length,
      itemBuilder: (context, index) {
        final group = groupedNotifications[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                group['date'] as String,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ),
            // Notifications for this date
            ...((group['notifications'] as List<NotificationModel>)
                .map((notification) =>
                    _buildNotificationItem(context, notification))),
          ],
        );
      },
    );
  }

  List<Map<String, dynamic>> _groupNotificationsByDate() {
    final Map<String, List<NotificationModel>> groups = {};

    for (final notification in controller.notifications) {
      final date = _getDateLabel(notification.createdAt);
      groups.putIfAbsent(date, () => []).add(notification);
    }

    return groups.entries
        .map((e) => {'date': e.key, 'notifications': e.value})
        .toList();
  }

  String _getDateLabel(DateTime? date) {
    if (date == null) return 'Unknown';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final notificationDate = DateTime(date.year, date.month, date.day);

    if (notificationDate == today) {
      return 'Today';
    } else if (notificationDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(date).inDays < 7) {
      return 'This Week';
    } else {
      return 'Earlier';
    }
  }

  Widget _buildNotificationItem(
      BuildContext context, NotificationModel notification) {
    return Dismissible(
      key: Key('notification_${notification.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => controller.deleteNotification(notification.id),
      child: InkWell(
        onTap: () => _handleNotificationTap(notification),
        child: Container(
          color: notification.isRead
              ? null
              : Theme.of(context).primaryColor.withOpacity(0.05),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              _buildNotificationIcon(context, notification),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: notification.isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.createdAt != null
                          ? timeago.format(notification.createdAt!)
                          : '',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(
      BuildContext context, NotificationModel notification) {
    IconData icon;
    Color color;

    switch (notification.type) {
      case 'order':
      case 'order_status':
        icon = Icons.local_shipping;
        color = Colors.blue;
        break;
      case 'promotion':
      case 'marketing':
        icon = Icons.local_offer;
        color = Colors.orange;
        break;
      case 'payment':
        icon = Icons.payment;
        color = Colors.green;
        break;
      case 'system':
        icon = Icons.info;
        color = Colors.grey;
        break;
      default:
        icon = Icons.notifications;
        color = Theme.of(context).primaryColor;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Mark as read
    if (!notification.isRead) {
      controller.markAsRead(notification.id);
    }

    // Navigate based on notification type and data
    controller.handleNotificationNavigation(notification);
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'settings':
        Get.toNamed('/notification-settings');
        break;
      case 'clear_all':
        _showClearAllDialog();
        break;
    }
  }

  void _showClearAllDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear All Notifications'),
        content: const Text(
            'Are you sure you want to delete all notifications? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.clearAllNotifications();
              Get.back();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}

/// Notification Settings Screen
class NotificationSettingsScreen extends GetView<NotificationController> {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: Obx(() => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSection(
                context,
                'Push Notifications',
                [
                  _buildSwitchTile(
                    'Enable Push Notifications',
                    'Receive notifications on your device',
                    controller.pushEnabled.value,
                    (value) => controller.togglePushNotifications(value),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                context,
                'Notification Types',
                [
                  _buildSwitchTile(
                    'Order Updates',
                    'Status changes, shipping updates',
                    controller.orderNotifications.value,
                    (value) => controller.toggleOrderNotifications(value),
                  ),
                  _buildSwitchTile(
                    'Promotions & Offers',
                    'Sales, discounts, special offers',
                    controller.promotionNotifications.value,
                    (value) => controller.togglePromotionNotifications(value),
                  ),
                  _buildSwitchTile(
                    'System Notifications',
                    'Account updates, security alerts',
                    controller.systemNotifications.value,
                    (value) => controller.toggleSystemNotifications(value),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                context,
                'Email Notifications',
                [
                  _buildSwitchTile(
                    'Email Notifications',
                    'Receive notifications via email',
                    controller.emailEnabled.value,
                    (value) => controller.toggleEmailNotifications(value),
                  ),
                ],
              ),
            ],
          )),
    );
  }

  Widget _buildSection(
      BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
      value: value,
      onChanged: onChanged,
    );
  }
}
