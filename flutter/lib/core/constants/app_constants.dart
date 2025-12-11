/// Application Constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Distributor App';
  static const String appVersion = '1.0.0';
  static const int appBuildNumber = 1;

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_settings';
  static const String configKey = 'app_config';
  static const String darkModeKey = 'dark_mode';
  static const String onboardingKey = 'onboarding_completed';
  static const String cartCacheKey = 'cart_cache';
  static const String wishlistCacheKey = 'wishlist_cache';

  // Pagination
  static const int defaultPageSize = 15;
  static const int maxPageSize = 50;

  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // Cache Duration
  static const int cacheDurationMinutes = 30;
  static const int themeCacheDurationHours = 24;

  // Animation Durations
  static const int shortAnimationDuration = 200;
  static const int mediumAnimationDuration = 300;
  static const int longAnimationDuration = 500;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultRadius = 12.0;
  static const double smallRadius = 8.0;
  static const double largeRadius = 16.0;
  static const double cardElevation = 2.0;

  // Grid
  static const int mobileGridColumns = 2;
  static const int tabletGridColumns = 3;
  static const int desktopGridColumns = 4;

  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  // Image Sizes
  static const double thumbnailSize = 80;
  static const double productImageSize = 200;
  static const double categoryImageSize = 120;
  static const double avatarSize = 100;

  // Invoice Statuses
  static const String statusDraft = 'Draft';
  static const String statusApproved = 'Approved';
  static const String statusDispatch = 'Dispatch';
  static const String statusOutForDelivery = 'Out for Delivery';
  static const String statusDelivered = 'Delivered';
  static const String statusReturn = 'Return';

  // User Roles
  static const String roleSuperAdmin = 'super_admin';
  static const String roleAdmin = 'admin';
  static const String roleEditor = 'editor';
  static const String roleUser = 'user';

  // Notification Types
  static const String notificationTypeOrder = 'order';
  static const String notificationTypePromo = 'promo';
  static const String notificationTypeSystem = 'system';
  static const String notificationTypeGeneral = 'general';
}

/// Error Messages
class ErrorMessages {
  ErrorMessages._();

  static const String networkError = 'Please check your internet connection and try again.';
  static const String serverError = 'Something went wrong. Please try again later.';
  static const String sessionExpired = 'Your session has expired. Please login again.';
  static const String invalidCredentials = 'Invalid email or password.';
  static const String accountNotApproved = 'Your account is pending approval.';
  static const String validationError = 'Please check your input and try again.';
  static const String unknownError = 'An unexpected error occurred.';
  static const String noDataFound = 'No data found.';
  static const String emptyCart = 'Your cart is empty.';
  static const String emptyWishlist = 'Your wishlist is empty.';
  static const String emptyNotifications = 'No notifications yet.';
  static const String emptyInvoices = 'No invoices found.';
  static const String emptyProducts = 'No products found.';
  static const String emptyCategories = 'No categories found.';
}

/// Success Messages
class SuccessMessages {
  SuccessMessages._();

  static const String loginSuccess = 'Welcome back!';
  static const String registerSuccess = 'Account created successfully!';
  static const String logoutSuccess = 'Logged out successfully.';
  static const String passwordResetSent = 'Password reset link sent to your email.';
  static const String passwordResetSuccess = 'Password reset successfully.';
  static const String profileUpdated = 'Profile updated successfully.';
  static const String passwordChanged = 'Password changed successfully.';
  static const String avatarUpdated = 'Avatar updated successfully.';
  static const String avatarRemoved = 'Avatar removed successfully.';
  static const String addedToCart = 'Added to cart.';
  static const String removedFromCart = 'Removed from cart.';
  static const String cartCleared = 'Cart cleared.';
  static const String addedToWishlist = 'Added to wishlist.';
  static const String removedFromWishlist = 'Removed from wishlist.';
  static const String invoiceGenerated = 'Invoice generated successfully.';
  static const String invoiceDeleted = 'Invoice deleted successfully.';
  static const String notificationRead = 'Notification marked as read.';
  static const String allNotificationsRead = 'All notifications marked as read.';
}
