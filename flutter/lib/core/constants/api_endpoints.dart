/// API Endpoints for the Distributor App
/// All endpoints are relative to the base URL
class ApiEndpoints {
  ApiEndpoints._();

  // Base URL - Change this to your production URL
  static const String baseUrl = 'https://your-api-domain.com';
  static const String apiVersion = '/api/v1';
  static String get apiBaseUrl => '$baseUrl$apiVersion';

  // ==================== Authentication ====================
  static const String login = '/login';
  static const String register = '/register';
  static const String logout = '/logout';
  static const String user = '/user';
  
  // Password Reset
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String verifyResetToken = '/verify-reset-token';

  // ==================== App Configuration ====================
  static const String appVersion = '/app-version';
  static const String appSettings = '/app-settings';
  static const String appConfig = '/app-config';
  static const String companyInfo = '/company-info';

  // ==================== Home/Dashboard ====================
  static const String home = '/home';

  // ==================== Categories ====================
  static const String categories = '/categories';
  static String categoryById(int id) => '/categories/$id';
  static String subcategoriesByCategory(int categoryId) => '/categories/$categoryId/subcategories';

  // ==================== Products ====================
  static const String products = '/products';
  static String productById(int id) => '/products/$id';
  static const String productSearch = '/products/search';
  static String productsByCategory(int categoryId) => '/products/by-category/$categoryId';
  static String productsBySubcategory(int subcategoryId) => '/products/by-subcategory/$subcategoryId';

  // ==================== Cart ====================
  static const String cart = '/cart';
  static const String cartAdd = '/cart/add';
  static String cartUpdate(int id) => '/cart/$id';
  static String cartRemove(int id) => '/cart/$id';
  static const String cartClear = '/cart/clear';
  static const String cartCount = '/cart/count';
  static const String cartGenerateInvoice = '/cart/generate-invoice';

  // ==================== Wishlist ====================
  static const String wishlist = '/wishlist';
  static String wishlistAdd(int productId) => '/wishlist/$productId';
  static String wishlistRemove(int productId) => '/wishlist/$productId';
  static String wishlistCheck(int productId) => '/wishlist/check/$productId';
  static String wishlistAddToCart(int productId) => '/wishlist/$productId/add-to-cart';
  static const String wishlistClear = '/wishlist/clear';

  // ==================== Invoices ====================
  static const String myInvoices = '/my-invoices';
  static String invoiceById(int id) => '/my-invoices/$id';
  static String invoiceDownloadPdf(int id) => '/my-invoices/$id/download-pdf';
  static String invoiceAddToCart(int id) => '/my-invoices/$id/add-to-cart';
  static String invoiceDelete(int id) => '/my-invoices/$id';

  // ==================== Profile ====================
  static const String profile = '/profile';
  static const String profileAvatar = '/profile/avatar';
  static const String profilePassword = '/profile/password';
  static const String profileDeleteAccount = '/profile/delete-account';

  // ==================== Notifications ====================
  static const String notifications = '/notifications';
  static String notificationMarkRead(int id) => '/notifications/$id/mark-read';
  static const String notificationsMarkAllRead = '/notifications/mark-all-read';
  static const String notificationsUnreadCount = '/notifications/unread-count';
  static String notificationDelete(int id) => '/notifications/$id';
  static const String notificationsRegisterDevice = '/notifications/register-device';

  // ==================== Pages ====================
  static const String pages = '/pages';
  static String pageById(int id) => '/pages/$id';
}
