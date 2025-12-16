import 'package:flutter/material.dart';

/// Empty State Widget
/// Displays when there's no content to show
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? customAction;
  final double iconSize;
  final Color? iconColor;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.customAction,
    this.iconSize = 80,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: iconColor ?? Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: TextStyle(color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ],
            if (customAction != null) ...[
              const SizedBox(height: 24),
              customAction!,
            ] else if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty Cart State
class EmptyCartState extends StatelessWidget {
  final VoidCallback? onBrowseProducts;

  const EmptyCartState({super.key, this.onBrowseProducts});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.shopping_cart_outlined,
      title: 'Your cart is empty',
      subtitle: 'Add items to your cart to get started',
      actionLabel: 'Browse Products',
      onAction: onBrowseProducts,
    );
  }
}

/// Empty Wishlist State
class EmptyWishlistState extends StatelessWidget {
  final VoidCallback? onBrowseProducts;

  const EmptyWishlistState({super.key, this.onBrowseProducts});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.favorite_border,
      title: 'Your wishlist is empty',
      subtitle: 'Save items you love for later',
      actionLabel: 'Browse Products',
      onAction: onBrowseProducts,
    );
  }
}

/// Empty Orders State
class EmptyOrdersState extends StatelessWidget {
  final VoidCallback? onBrowseProducts;

  const EmptyOrdersState({super.key, this.onBrowseProducts});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.receipt_long_outlined,
      title: 'No orders yet',
      subtitle: 'Place your first order to see it here',
      actionLabel: 'Start Shopping',
      onAction: onBrowseProducts,
    );
  }
}

/// Empty Search Results State
class EmptySearchState extends StatelessWidget {
  final String? query;
  final VoidCallback? onClearSearch;

  const EmptySearchState({
    super.key,
    this.query,
    this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.search_off,
      title: 'No results found',
      subtitle: query != null
          ? 'No results for "$query"'
          : 'Try different keywords or filters',
      actionLabel: 'Clear Search',
      onAction: onClearSearch,
    );
  }
}

/// Empty Notifications State
class EmptyNotificationsState extends StatelessWidget {
  const EmptyNotificationsState({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.notifications_none,
      title: 'No notifications',
      subtitle: "You're all caught up!",
    );
  }
}

/// No Internet State
class NoInternetState extends StatelessWidget {
  final VoidCallback? onRetry;

  const NoInternetState({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.wifi_off,
      title: 'No Internet Connection',
      subtitle: 'Please check your connection and try again',
      actionLabel: 'Retry',
      onAction: onRetry,
    );
  }
}
