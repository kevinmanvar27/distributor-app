// Notifications View
//
// Full notifications screen with:
// - Filter tabs (All / Unread / Read)
// - Notification list with pagination
// - Pull-to-refresh
// - Mark as read functionality
// - Empty states for each filter

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/dynamic_appbar.dart';
import '../../models/notification_model.dart';
import 'notifications_controller.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DynamicAppBar(
        title: 'Notifications',
        actions: [
          // Mark all as read button
          Obx(() => controller.hasUnread
              ? IconButton(
                  icon: const Icon(Icons.done_all),
                  onPressed: controller.markAllAsRead,
                  tooltip: 'Mark all as read',
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: Column(
        children: [
          // Filter tabs
          _buildFilterTabs(),
          
          // Notifications list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.notifications.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.hasError.value && controller.notifications.isEmpty) {
                return _buildErrorState();
              }

              if (controller.isEmpty) {
                return _buildEmptyState();
              }

              return _buildNotificationsList();
            }),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Filter Tabs
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.borderColor.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Obx(() => Row(
        children: [
          _buildFilterChip(
            label: 'All',
            filter: NotificationFilter.all,
            count: controller.notifications.length,
          ),
          const SizedBox(width: AppTheme.spacingSm),
          _buildFilterChip(
            label: 'Unread',
            filter: NotificationFilter.unread,
            count: controller.unreadCount.value,
          ),
          const SizedBox(width: AppTheme.spacingSm),
          _buildFilterChip(
            label: 'Read',
            filter: NotificationFilter.read,
            count: controller.notifications.where((n) => n.isRead).length,
          ),
        ],
      )),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required NotificationFilter filter,
    required int count,
  }) {
    final isSelected = controller.currentFilter.value == filter;
    
    return GestureDetector(
      onTap: () => controller.setFilter(filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: AppTheme.spacingSm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTheme.bodyMedium.copyWith(
                color: isSelected ? Colors.white : AppTheme.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: AppTheme.spacingXs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Colors.white.withValues(alpha: 0.2)
                      : AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Notifications List
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildNotificationsList() {
    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
        itemCount: controller.filteredNotifications.length + 1,
        itemBuilder: (context, index) {
          // Load more indicator
          if (index == controller.filteredNotifications.length) {
            return _buildLoadMoreIndicator();
          }

          final notification = controller.filteredNotifications[index];
          return _buildNotificationTile(notification);
        },
      ),
    );
  }

  Widget _buildNotificationTile(NotificationModel notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppTheme.spacingLg),
        color: AppTheme.successColor,
        child: const Icon(
          Icons.check,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        controller.markAsRead(notification);
        return false; // Don't actually dismiss, just mark as read
      },
      child: InkWell(
        onTap: () => controller.markAsRead(notification),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          decoration: BoxDecoration(
            color: notification.isRead 
                ? Colors.transparent 
                : AppTheme.primaryColor.withValues(alpha: 0.05),
            border: Border(
              bottom: BorderSide(
                color: AppTheme.borderColor.withValues(alpha: 0.3),
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              _buildNotificationIcon(notification),
              const SizedBox(width: AppTheme.spacingMd),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and time
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: AppTheme.titleSmall.copyWith(
                              fontWeight: notification.isRead 
                                  ? FontWeight.normal 
                                  : FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingSm),
                        Text(
                          notification.timeAgo,
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingXs),
                    
                    // Message
                    Text(
                      notification.message,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // Unread indicator
              if (!notification.isRead) ...[
                const SizedBox(width: AppTheme.spacingSm),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(NotificationModel notification) {
    IconData icon;
    Color color;

    switch (notification.type) {
      case NotificationType.order:
        icon = Icons.local_shipping_outlined;
        color = AppTheme.primaryColor;
        break;
      case NotificationType.promotion:
        icon = Icons.local_offer_outlined;
        color = AppTheme.warningColor;
        break;
      case NotificationType.payment:
        icon = Icons.payment_outlined;
        color = AppTheme.successColor;
        break;
      case NotificationType.system:
        icon = Icons.notifications_outlined;
        color = AppTheme.textSecondary;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Icon(
        icon,
        color: color,
        size: 22,
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Obx(() {
      if (!controller.hasMorePages.value) {
        return const SizedBox.shrink();
      }

      if (controller.isLoadingMore.value) {
        return const Padding(
          padding: EdgeInsets.all(AppTheme.spacingLg),
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      }

      // Trigger load more when this widget becomes visible
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.loadMore();
      });

      return const SizedBox(height: AppTheme.spacingLg);
    });
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Empty & Error States
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    String message;
    IconData icon;

    switch (controller.currentFilter.value) {
      case NotificationFilter.unread:
        message = 'No unread notifications';
        icon = Icons.mark_email_read_outlined;
        break;
      case NotificationFilter.read:
        message = 'No read notifications';
        icon = Icons.mark_email_unread_outlined;
        break;
      case NotificationFilter.all:
        message = 'No notifications yet';
        icon = Icons.notifications_none_outlined;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: AppTheme.textTertiary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            Text(
              message,
              style: AppTheme.titleMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              'Pull down to refresh',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: AppTheme.errorColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            Text(
              'Failed to load notifications',
              style: AppTheme.titleMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingLg),
            ElevatedButton.icon(
              onPressed: controller.refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
