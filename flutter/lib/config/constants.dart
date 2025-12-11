/// App Constants
class AppConstants {
  // App Info
  static const String appName = 'Distributor App';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // API Configuration
  static const String baseUrl = 'https://api.distributor.com/api/v1';
  static const String apiVersion = 'v1';
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(minutes: 5);

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String appSettingsKey = 'app_settings';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String currencyKey = 'currency';
  static const String onboardingKey = 'onboarding_completed';
  static const String cartKey = 'cart_items';
  static const String searchHistoryKey = 'search_history';
  static const String recentProductsKey = 'recent_products';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  static const int searchPageSize = 15;

  // Cache Duration
  static const Duration cacheValidDuration = Duration(hours: 1);
  static const Duration imageCacheDuration = Duration(days: 7);
  static const Duration settingsCacheDuration = Duration(hours: 24);

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minPhoneLength = 10;
  static const int maxPhoneLength = 15;
  static const int otpLength = 6;
  static const Duration otpResendDelay = Duration(seconds: 60);

  // Cart & Orders
  static const int maxCartItems = 100;
  static const int maxQuantityPerItem = 9999;
  static const int minQuantityPerItem = 1;
  static const double minOrderAmount = 0.0;

  // Search
  static const int maxSearchHistory = 10;
  static const int maxRecentProducts = 20;
  static const int searchDebounceMs = 500;
  static const int minSearchLength = 2;

  // Image
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];
  static const double imageQuality = 0.8;
  static const int thumbnailSize = 150;
  static const int mediumImageSize = 400;
  static const int largeImageSize = 800;

  // Animation
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Layout
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  static const double maxContentWidth = 1200;
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultRadius = 12.0;
  static const double smallRadius = 8.0;
  static const double largeRadius = 16.0;

  // Grid
  static const int mobileGridColumns = 2;
  static const int tabletGridColumns = 3;
  static const int desktopGridColumns = 4;
  static const double gridSpacing = 16.0;
  static const double gridChildAspectRatio = 0.7;

  // Notifications
  static const String fcmChannelId = 'distributor_notifications';
  static const String fcmChannelName = 'Distributor Notifications';
  static const String fcmChannelDescription = 'Notifications from Distributor App';

  // Social Links (fallback)
  static const String defaultSupportEmail = 'support@distributor.com';
  static const String defaultSupportPhone = '+1234567890';
  static const String defaultWebsite = 'https://distributor.com';

  // Error Messages
  static const String networkError = 'Please check your internet connection';
  static const String serverError = 'Server error. Please try again later';
  static const String unknownError = 'Something went wrong. Please try again';
  static const String sessionExpired = 'Session expired. Please login again';
  static const String unauthorized = 'You are not authorized to perform this action';

  // Success Messages
  static const String loginSuccess = 'Login successful';
  static const String registerSuccess = 'Registration successful';
  static const String logoutSuccess = 'Logged out successfully';
  static const String profileUpdateSuccess = 'Profile updated successfully';
  static const String passwordChangeSuccess = 'Password changed successfully';
  static const String addressAddSuccess = 'Address added successfully';
  static const String addressUpdateSuccess = 'Address updated successfully';
  static const String addressDeleteSuccess = 'Address deleted successfully';
  static const String cartAddSuccess = 'Added to cart';
  static const String cartRemoveSuccess = 'Removed from cart';
  static const String wishlistAddSuccess = 'Added to wishlist';
  static const String wishlistRemoveSuccess = 'Removed from wishlist';
  static const String orderPlaceSuccess = 'Order placed successfully';
}

/// API Endpoints
class ApiEndpoints {
  // Base
  static const String appSettings = '/app-settings';
  
  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyEmail = '/auth/verify-email';
  static const String resendVerification = '/auth/resend-verification';
  static const String changePassword = '/auth/change-password';
  static const String socialLogin = '/auth/social';
  
  // User
  static const String profile = '/user/profile';
  static const String updateProfile = '/user/profile';
  static const String uploadAvatar = '/user/avatar';
  static const String deleteAccount = '/user/delete';
  
  // Addresses
  static const String addresses = '/user/addresses';
  static String addressById(String id) => '/user/addresses/$id';
  static String setDefaultAddress(String id) => '/user/addresses/$id/default';
  
  // Products
  static const String products = '/products';
  static String productById(String id) => '/products/$id';
  static const String featuredProducts = '/products/featured';
  static const String newArrivals = '/products/new-arrivals';
  static const String bestSellers = '/products/best-sellers';
  static const String searchProducts = '/products/search';
  static String productReviews(String id) => '/products/$id/reviews';
  static String addProductReview(String id) => '/products/$id/reviews';
  
  // Categories
  static const String categories = '/categories';
  static String categoryById(String id) => '/categories/$id';
  static String subcategories(String categoryId) => '/categories/$categoryId/subcategories';
  static String categoryProducts(String id) => '/categories/$id/products';
  
  // Cart
  static const String cart = '/cart';
  static const String addToCart = '/cart/add';
  static String updateCartItem(String id) => '/cart/$id';
  static String removeCartItem(String id) => '/cart/$id';
  static const String clearCart = '/cart/clear';
  static const String applyCoupon = '/cart/coupon';
  static const String removeCoupon = '/cart/coupon';
  
  // Wishlist
  static const String wishlist = '/wishlist';
  static const String addToWishlist = '/wishlist/add';
  static String removeFromWishlist(String productId) => '/wishlist/$productId';
  static const String clearWishlist = '/wishlist/clear';
  static const String moveToCart = '/wishlist/move-to-cart';
  
  // Orders / Invoices
  static const String orders = '/orders';
  static String orderById(String id) => '/orders/$id';
  static const String createOrder = '/orders';
  static String cancelOrder(String id) => '/orders/$id/cancel';
  static String reorder(String id) => '/orders/$id/reorder';
  static String orderTracking(String id) => '/orders/$id/tracking';
  static String orderInvoice(String id) => '/orders/$id/invoice';
  
  // Proforma Invoices
  static const String proformaInvoices = '/proforma-invoices';
  static String proformaById(String id) => '/proforma-invoices/$id';
  static const String createProforma = '/proforma-invoices';
  static String convertProforma(String id) => '/proforma-invoices/$id/convert';
  
  // Notifications
  static const String notifications = '/notifications';
  static String notificationById(String id) => '/notifications/$id';
  static String markAsRead(String id) => '/notifications/$id/read';
  static const String markAllAsRead = '/notifications/read-all';
  static const String unreadCount = '/notifications/unread-count';
  static const String notificationSettings = '/notifications/settings';
  
  // Home
  static const String home = '/home';
  static const String banners = '/banners';
  static const String promotions = '/promotions';
  
  // Support
  static const String faq = '/support/faq';
  static const String contactUs = '/support/contact';
  static const String submitTicket = '/support/ticket';
  
  // Media
  static const String uploadMedia = '/media/upload';
  static String mediaById(String id) => '/media/$id';
  
  // Settings
  static const String settings = '/settings';
  static const String updateSettings = '/settings';
}

/// Asset Paths
class AssetPaths {
  // Images
  static const String images = 'assets/images';
  static const String logo = '$images/logo.png';
  static const String logoLight = '$images/logo_light.png';
  static const String logoDark = '$images/logo_dark.png';
  static const String placeholder = '$images/placeholder.png';
  static const String noImage = '$images/no_image.png';
  static const String emptyCart = '$images/empty_cart.png';
  static const String emptyWishlist = '$images/empty_wishlist.png';
  static const String emptyOrders = '$images/empty_orders.png';
  static const String emptyNotifications = '$images/empty_notifications.png';
  static const String emptySearch = '$images/empty_search.png';
  static const String error = '$images/error.png';
  static const String noInternet = '$images/no_internet.png';
  static const String success = '$images/success.png';
  static const String onboarding1 = '$images/onboarding_1.png';
  static const String onboarding2 = '$images/onboarding_2.png';
  static const String onboarding3 = '$images/onboarding_3.png';
  
  // Icons
  static const String icons = 'assets/icons';
  
  // Animations
  static const String animations = 'assets/animations';
  static const String loadingAnimation = '$animations/loading.json';
  static const String successAnimation = '$animations/success.json';
  static const String errorAnimation = '$animations/error.json';
  static const String emptyAnimation = '$animations/empty.json';
}

/// Order Status
enum OrderStatus {
  pending('pending', 'Pending'),
  confirmed('confirmed', 'Confirmed'),
  processing('processing', 'Processing'),
  shipped('shipped', 'Shipped'),
  outForDelivery('out_for_delivery', 'Out for Delivery'),
  delivered('delivered', 'Delivered'),
  cancelled('cancelled', 'Cancelled'),
  returned('returned', 'Returned'),
  refunded('refunded', 'Refunded');

  final String value;
  final String label;
  const OrderStatus(this.value, this.label);

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => OrderStatus.pending,
    );
  }
}

/// Payment Status
enum PaymentStatus {
  pending('pending', 'Pending'),
  processing('processing', 'Processing'),
  completed('completed', 'Completed'),
  failed('failed', 'Failed'),
  refunded('refunded', 'Refunded'),
  cancelled('cancelled', 'Cancelled');

  final String value;
  final String label;
  const PaymentStatus(this.value, this.label);

  static PaymentStatus fromString(String value) {
    return PaymentStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PaymentStatus.pending,
    );
  }
}

/// Payment Method
enum PaymentMethod {
  cod('cod', 'Cash on Delivery'),
  card('card', 'Credit/Debit Card'),
  upi('upi', 'UPI'),
  netBanking('net_banking', 'Net Banking'),
  wallet('wallet', 'Wallet'),
  credit('credit', 'Store Credit');

  final String value;
  final String label;
  const PaymentMethod(this.value, this.label);

  static PaymentMethod fromString(String value) {
    return PaymentMethod.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PaymentMethod.cod,
    );
  }
}

/// Address Type
enum AddressType {
  home('home', 'Home'),
  office('office', 'Office'),
  warehouse('warehouse', 'Warehouse'),
  other('other', 'Other');

  final String value;
  final String label;
  const AddressType(this.value, this.label);

  static AddressType fromString(String value) {
    return AddressType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AddressType.other,
    );
  }
}

/// Sort Options
enum SortOption {
  relevance('relevance', 'Relevance'),
  newest('newest', 'Newest First'),
  oldest('oldest', 'Oldest First'),
  priceLowToHigh('price_asc', 'Price: Low to High'),
  priceHighToLow('price_desc', 'Price: High to Low'),
  nameAZ('name_asc', 'Name: A to Z'),
  nameZA('name_desc', 'Name: Z to A'),
  rating('rating', 'Highest Rated'),
  popularity('popularity', 'Most Popular');

  final String value;
  final String label;
  const SortOption(this.value, this.label);

  static SortOption fromString(String value) {
    return SortOption.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SortOption.relevance,
    );
  }
}

/// Notification Type
enum NotificationType {
  order('order', 'Order Update'),
  promotion('promotion', 'Promotion'),
  system('system', 'System'),
  payment('payment', 'Payment'),
  delivery('delivery', 'Delivery'),
  general('general', 'General');

  final String value;
  final String label;
  const NotificationType(this.value, this.label);

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => NotificationType.general,
    );
  }
}
