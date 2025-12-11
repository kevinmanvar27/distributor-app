/// Notification Type Enum
enum NotificationType {
  general,
  order,
  invoice,
  product,
  promotion,
  system,
  alert;

  static NotificationType fromString(String? type) {
    switch (type?.toLowerCase()) {
      case 'order':
        return NotificationType.order;
      case 'invoice':
      case 'proforma_invoice':
        return NotificationType.invoice;
      case 'product':
        return NotificationType.product;
      case 'promotion':
      case 'promo':
      case 'offer':
        return NotificationType.promotion;
      case 'system':
        return NotificationType.system;
      case 'alert':
      case 'warning':
        return NotificationType.alert;
      default:
        return NotificationType.general;
    }
  }

  String get displayName {
    switch (this) {
      case NotificationType.general:
        return 'General';
      case NotificationType.order:
        return 'Order';
      case NotificationType.invoice:
        return 'Invoice';
      case NotificationType.product:
        return 'Product';
      case NotificationType.promotion:
        return 'Promotion';
      case NotificationType.system:
        return 'System';
      case NotificationType.alert:
        return 'Alert';
    }
  }

  String get iconName {
    switch (this) {
      case NotificationType.general:
        return 'notifications';
      case NotificationType.order:
        return 'shopping_bag';
      case NotificationType.invoice:
        return 'receipt_long';
      case NotificationType.product:
        return 'inventory_2';
      case NotificationType.promotion:
        return 'local_offer';
      case NotificationType.system:
        return 'settings';
      case NotificationType.alert:
        return 'warning';
    }
  }
}

/// Notification Model
class NotificationModel {
  final String id;
  final String? type;
  final String? notifiableType;
  final int? notifiableId;
  final String title;
  final String? message;
  final String? body;
  final NotificationType notificationType;
  final Map<String, dynamic>? data;
  final DateTime? readAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  NotificationModel({
    required this.id,
    this.type,
    this.notifiableType,
    this.notifiableId,
    required this.title,
    this.message,
    this.body,
    this.notificationType = NotificationType.general,
    this.data,
    this.readAt,
    this.createdAt,
    this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // Parse data field
    Map<String, dynamic>? notificationData;
    if (json['data'] != null) {
      if (json['data'] is Map) {
        notificationData = Map<String, dynamic>.from(json['data']);
      } else if (json['data'] is String) {
        // Try to parse JSON string
        try {
          notificationData = Map<String, dynamic>.from(
            Map.castFrom(json['data'] as Map),
          );
        } catch (_) {
          notificationData = {'raw': json['data']};
        }
      }
    }

    // Extract title and message from data if not in root
    String title = json['title'] ?? '';
    String? message = json['message'] ?? json['body'];
    
    if (notificationData != null) {
      title = title.isEmpty ? (notificationData['title'] ?? '') : title;
      message = message ?? notificationData['message'] ?? notificationData['body'];
    }

    // Determine notification type
    String? typeStr = json['notification_type'] ?? 
                      json['type'] ?? 
                      notificationData?['type'];

    return NotificationModel(
      id: json['id']?.toString() ?? '',
      type: json['type'],
      notifiableType: json['notifiable_type'],
      notifiableId: json['notifiable_id'],
      title: title,
      message: message,
      body: json['body'],
      notificationType: NotificationType.fromString(typeStr),
      data: notificationData,
      readAt: json['read_at'] != null
          ? DateTime.tryParse(json['read_at'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'notifiable_type': notifiableType,
      'notifiable_id': notifiableId,
      'title': title,
      'message': message,
      'body': body,
      'notification_type': notificationType.name,
      'data': data,
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? type,
    String? notifiableType,
    int? notifiableId,
    String? title,
    String? message,
    String? body,
    NotificationType? notificationType,
    Map<String, dynamic>? data,
    DateTime? readAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      notifiableType: notifiableType ?? this.notifiableType,
      notifiableId: notifiableId ?? this.notifiableId,
      title: title ?? this.title,
      message: message ?? this.message,
      body: body ?? this.body,
      notificationType: notificationType ?? this.notificationType,
      data: data ?? this.data,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if notification is read
  bool get isRead => readAt != null;

  /// Check if notification is unread
  bool get isUnread => readAt == null;

  /// Get display message
  String get displayMessage => message ?? body ?? '';

  /// Get time ago string
  String get timeAgo {
    if (createdAt == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(createdAt!);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  /// Get action URL from data
  String? get actionUrl => data?['url'] ?? data?['action_url'];

  /// Get related ID (order_id, invoice_id, product_id, etc.)
  int? get relatedId {
    if (data == null) return null;
    return data!['order_id'] ?? 
           data!['invoice_id'] ?? 
           data!['product_id'] ?? 
           data!['id'];
  }

  /// Check if notification has action
  bool get hasAction => actionUrl != null || relatedId != null;
}

/// Notifications List Model
class NotificationsModel {
  final List<NotificationModel> notifications;
  final int unreadCount;
  final int totalCount;

  NotificationsModel({
    this.notifications = const [],
    this.unreadCount = 0,
    this.totalCount = 0,
  });

  factory NotificationsModel.fromJson(Map<String, dynamic> json) {
    List<NotificationModel> notificationsList = [];
    
    if (json['notifications'] != null && json['notifications'] is List) {
      notificationsList = (json['notifications'] as List)
          .map((e) => NotificationModel.fromJson(e))
          .toList();
    } else if (json['data'] != null && json['data'] is List) {
      notificationsList = (json['data'] as List)
          .map((e) => NotificationModel.fromJson(e))
          .toList();
    }

    return NotificationsModel(
      notifications: notificationsList,
      unreadCount: json['unread_count'] ?? 
                   json['unread'] ?? 
                   notificationsList.where((n) => n.isUnread).length,
      totalCount: json['total_count'] ?? 
                  json['total'] ?? 
                  notificationsList.length,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notifications': notifications.map((e) => e.toJson()).toList(),
      'unread_count': unreadCount,
      'total_count': totalCount,
    };
  }

  /// Check if there are notifications
  bool get isEmpty => notifications.isEmpty;
  bool get isNotEmpty => notifications.isNotEmpty;

  /// Get unread notifications
  List<NotificationModel> get unreadNotifications {
    return notifications.where((n) => n.isUnread).toList();
  }

  /// Get read notifications
  List<NotificationModel> get readNotifications {
    return notifications.where((n) => n.isRead).toList();
  }

  /// Check if there are unread notifications
  bool get hasUnread => unreadCount > 0;

  /// Group notifications by date
  Map<String, List<NotificationModel>> get groupedByDate {
    final grouped = <String, List<NotificationModel>>{};
    
    for (var notification in notifications) {
      final date = notification.createdAt;
      if (date == null) continue;
      
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final notificationDate = DateTime(date.year, date.month, date.day);
      
      String key;
      if (notificationDate == today) {
        key = 'Today';
      } else if (notificationDate == yesterday) {
        key = 'Yesterday';
      } else if (now.difference(date).inDays < 7) {
        key = 'This Week';
      } else {
        key = 'Earlier';
      }
      
      grouped.putIfAbsent(key, () => []).add(notification);
    }
    
    return grouped;
  }
}
