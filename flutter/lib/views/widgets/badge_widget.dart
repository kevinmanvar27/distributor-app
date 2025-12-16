import 'package:flutter/material.dart';

/// Badge Widget for displaying counts and status indicators
class BadgeWidget extends StatelessWidget {
  final Widget child;
  final int count;
  final Color? backgroundColor;
  final Color? textColor;
  final double size;
  final bool showZero;
  final Alignment alignment;

  const BadgeWidget({
    super.key,
    required this.child,
    this.count = 0,
    this.backgroundColor,
    this.textColor,
    this.size = 18,
    this.showZero = false,
    this.alignment = Alignment.topRight,
  });

  @override
  Widget build(BuildContext context) {
    if (count == 0 && !showZero) {
      return child;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: alignment == Alignment.topRight ||
                  alignment == Alignment.topLeft
              ? -size / 3
              : null,
          bottom: alignment == Alignment.bottomRight ||
                  alignment == Alignment.bottomLeft
              ? -size / 3
              : null,
          right: alignment == Alignment.topRight ||
                  alignment == Alignment.bottomRight
              ? -size / 3
              : null,
          left: alignment == Alignment.topLeft ||
                  alignment == Alignment.bottomLeft
              ? -size / 3
              : null,
          child: _buildBadge(context),
        ),
      ],
    );
  }

  Widget _buildBadge(BuildContext context) {
    final displayText = count > 99 ? '99+' : count.toString();
    final isLarge = displayText.length > 2;

    return Container(
      constraints: BoxConstraints(
        minWidth: size,
        minHeight: size,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? 4 : 0,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.red,
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Center(
        child: Text(
          displayText,
          style: TextStyle(
            color: textColor ?? Colors.white,
            fontSize: size * 0.6,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// Cart Badge - Specialized badge for cart icon
class CartBadge extends StatelessWidget {
  final int itemCount;
  final VoidCallback? onTap;
  final Color? iconColor;

  const CartBadge({
    super.key,
    required this.itemCount,
    this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: BadgeWidget(
        count: itemCount,
        child: Icon(
          Icons.shopping_cart_outlined,
          color: iconColor,
        ),
      ),
    );
  }
}

/// Notification Badge - Specialized badge for notifications
class NotificationBadge extends StatelessWidget {
  final int unreadCount;
  final VoidCallback? onTap;
  final Color? iconColor;

  const NotificationBadge({
    super.key,
    required this.unreadCount,
    this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: BadgeWidget(
        count: unreadCount,
        child: Icon(
          unreadCount > 0
              ? Icons.notifications
              : Icons.notifications_outlined,
          color: iconColor,
        ),
      ),
    );
  }
}

/// Status Badge - For displaying status labels
class StatusBadge extends StatelessWidget {
  final String status;
  final Color? backgroundColor;
  final Color? textColor;
  final double fontSize;
  final EdgeInsets padding;

  const StatusBadge({
    super.key,
    required this.status,
    this.backgroundColor,
    this.textColor,
    this.fontSize = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  });

  factory StatusBadge.order(String status) {
    Color bgColor;
    Color txtColor = Colors.white;

    switch (status.toLowerCase()) {
      case 'pending':
        bgColor = Colors.orange;
        break;
      case 'processing':
        bgColor = Colors.blue;
        break;
      case 'shipped':
        bgColor = Colors.purple;
        break;
      case 'delivered':
        bgColor = Colors.green;
        break;
      case 'cancelled':
        bgColor = Colors.red;
        break;
      case 'returned':
        bgColor = Colors.grey;
        break;
      default:
        bgColor = Colors.grey;
    }

    return StatusBadge(
      status: status,
      backgroundColor: bgColor,
      textColor: txtColor,
    );
  }

  factory StatusBadge.payment(String status) {
    Color bgColor;
    Color txtColor = Colors.white;

    switch (status.toLowerCase()) {
      case 'paid':
        bgColor = Colors.green;
        break;
      case 'pending':
        bgColor = Colors.orange;
        break;
      case 'failed':
        bgColor = Colors.red;
        break;
      case 'refunded':
        bgColor = Colors.blue;
        break;
      default:
        bgColor = Colors.grey;
    }

    return StatusBadge(
      status: status,
      backgroundColor: bgColor,
      textColor: txtColor,
    );
  }

  factory StatusBadge.stock(bool inStock, {int? quantity}) {
    if (inStock && (quantity == null || quantity > 10)) {
      return const StatusBadge(
        status: 'In Stock',
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } else if (inStock && quantity != null && quantity <= 10) {
      return StatusBadge(
        status: 'Only $quantity left',
        backgroundColor: Colors.orange,
        textColor: Colors.white,
      );
    } else {
      return const StatusBadge(
        status: 'Out of Stock',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Discount Badge - For showing discount percentage
class DiscountBadge extends StatelessWidget {
  final double discountPercentage;
  final Color? backgroundColor;
  final Color? textColor;

  const DiscountBadge({
    super.key,
    required this.discountPercentage,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    if (discountPercentage <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.red,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '-${discountPercentage.toStringAsFixed(0)}%',
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// New Badge - For marking new products
class NewBadge extends StatelessWidget {
  final Color? backgroundColor;
  final Color? textColor;

  const NewBadge({
    super.key,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.green,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'NEW',
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

/// Featured Badge - For marking featured products
class FeaturedBadge extends StatelessWidget {
  final Color? backgroundColor;
  final Color? textColor;

  const FeaturedBadge({
    super.key,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.amber,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: 12,
            color: textColor ?? Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            'FEATURED',
            style: TextStyle(
              color: textColor ?? Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
