import 'package:get/get.dart';
import '../views/screens/splash_screen.dart';
import '../views/screens/main_screen.dart';
import '../views/screens/auth/login_screen.dart';
import '../views/screens/auth/register_screen.dart';
import '../views/screens/auth/forgot_password_screen.dart';
import '../views/screens/auth/otp_verification_screen.dart';
import '../views/screens/auth/reset_password_screen.dart';
import '../views/screens/home/home_screen.dart';
import '../views/screens/products/products_screen.dart';
import '../views/screens/products/product_detail_screen.dart';
import '../views/screens/categories/categories_screen.dart';
import '../views/screens/cart/cart_screen.dart';
import '../views/screens/wishlist/wishlist_screen.dart';
import '../views/screens/checkout/checkout_screen.dart';
import '../views/screens/orders/orders_screen.dart';
import '../views/screens/orders/order_detail_screen.dart';
import '../views/screens/notifications/notifications_screen.dart';
import '../views/screens/search/search_screen.dart';
import '../views/screens/profile/profile_screen.dart';
import '../views/screens/profile/addresses_screen.dart';
// Settings screen exports all nested screens: EditProfileScreen, ChangePasswordScreen, 
// HelpCenterScreen, ContactUsScreen, AboutScreen, LegalScreen
import '../views/screens/profile/settings_screen.dart';

/// App Routes - Defines all navigation routes
class AppRoutes {
  // Route names
  static const String splash = '/splash';
  static const String main = '/main';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String otpVerification = '/otp-verification';
  static const String resetPassword = '/reset-password';
  static const String home = '/home';
  static const String products = '/products';
  static const String productDetail = '/product/:id';
  static const String categories = '/categories';
  static const String subcategories = '/categories/:id';
  static const String cart = '/cart';
  static const String wishlist = '/wishlist';
  static const String checkout = '/checkout';
  static const String orders = '/orders';
  static const String orderDetail = '/orders/:id';
  static const String notifications = '/notifications';
  static const String notificationSettings = '/notifications/settings';
  static const String search = '/search';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String addresses = '/addresses';
  static const String settings = '/settings';
  static const String changePassword = '/settings/password';
  static const String helpCenter = '/help';
  static const String contactUs = '/contact';
  static const String about = '/about';
  static const String terms = '/terms';
  static const String privacy = '/privacy';

  // Initial route
  static const String initial = splash;

  // Route pages
  static final List<GetPage> pages = [
    // Splash
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
      transition: Transition.fade,
    ),

    // Main (with bottom navigation)
    GetPage(
      name: main,
      page: () => const MainScreen(),
      transition: Transition.fadeIn,
    ),

    // Auth routes
    GetPage(
      name: login,
      page: () => const LoginScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: register,
      page: () => const RegisterScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: forgotPassword,
      page: () => const ForgotPasswordScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: otpVerification,
      page: () => const OtpVerificationScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: resetPassword,
      page: () => const ResetPasswordScreen(),
      transition: Transition.rightToLeft,
    ),

    // Home
    GetPage(
      name: home,
      page: () => const HomeScreen(),
    ),

    // Products
    GetPage(
      name: products,
      page: () => const ProductsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: productDetail,
      page: () {
        final productId = Get.parameters['id'];
        return ProductDetailScreen(productId: productId ?? '');
      },
      transition: Transition.rightToLeft,
    ),

    // Categories
    GetPage(
      name: categories,
      page: () => const CategoriesScreen(),
      transition: Transition.rightToLeft,
    ),
    // Note: SubcategoriesScreen is navigated to directly via Get.to() from CategoriesScreen
    // with a CategoryModel object, not through named routes

    // Cart
    GetPage(
      name: cart,
      page: () => const CartScreen(),
      transition: Transition.rightToLeft,
    ),

    // Wishlist
    GetPage(
      name: wishlist,
      page: () => const WishlistScreen(),
      transition: Transition.rightToLeft,
    ),

    // Checkout
    GetPage(
      name: checkout,
      page: () => const CheckoutScreen(),
      transition: Transition.rightToLeft,
    ),

    // Orders
    GetPage(
      name: orders,
      page: () => const OrdersScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: orderDetail,
      page: () {
        final orderId = Get.parameters['id'];
        return OrderDetailScreen(orderId: orderId ?? '');
      },
      transition: Transition.rightToLeft,
    ),

    // Notifications
    GetPage(
      name: notifications,
      page: () => const NotificationsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: notificationSettings,
      page: () => const NotificationSettingsScreen(),
      transition: Transition.rightToLeft,
    ),

    // Search
    GetPage(
      name: search,
      page: () => const SearchScreen(),
      transition: Transition.fadeIn,
    ),

    // Profile
    GetPage(
      name: profile,
      page: () => const ProfileScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: editProfile,
      page: () => const EditProfileScreen(),
      transition: Transition.rightToLeft,
    ),

    // Addresses
    GetPage(
      name: addresses,
      page: () => const AddressesScreen(),
      transition: Transition.rightToLeft,
    ),

    // Settings
    GetPage(
      name: settings,
      page: () => const SettingsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: changePassword,
      page: () => const ChangePasswordScreen(),
      transition: Transition.rightToLeft,
    ),

    // Support
    GetPage(
      name: helpCenter,
      page: () => const HelpCenterScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: contactUs,
      page: () => const ContactUsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: about,
      page: () => const AboutScreen(),
      transition: Transition.rightToLeft,
    ),

    // Legal
    GetPage(
      name: terms,
      page: () => const LegalScreen(type: 'terms'),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: privacy,
      page: () => const LegalScreen(type: 'privacy'),
      transition: Transition.rightToLeft,
    ),
  ];

  // Navigation helpers
  static void toMain() => Get.offAllNamed(main);
  static void toLogin() => Get.offAllNamed(login);
  static void toRegister() => Get.toNamed(register);
  static void toForgotPassword() => Get.toNamed(forgotPassword);
  static void toOtpVerification() => Get.toNamed(otpVerification);
  static void toResetPassword() => Get.toNamed(resetPassword);
  static void toHome() => Get.toNamed(home);
  static void toProducts({Map<String, dynamic>? arguments}) =>
      Get.toNamed(products, arguments: arguments);
  static void toProductDetail(String productId) =>
      Get.toNamed('/product/$productId');
  static void toCategories() => Get.toNamed(categories);
  static void toSubcategories(String categoryId, String categoryName) =>
      Get.toNamed('/categories/$categoryId', arguments: {'name': categoryName});
  static void toCart() => Get.toNamed(cart);
  static void toWishlist() => Get.toNamed(wishlist);
  static void toCheckout() => Get.toNamed(checkout);
  static void toOrders() => Get.toNamed(orders);
  static void toOrderDetail(String orderId) => Get.toNamed('/orders/$orderId');
  static void toNotifications() => Get.toNamed(notifications);
  static void toSearch() => Get.toNamed(search);
  static void toProfile() => Get.toNamed(profile);
  static void toEditProfile() => Get.toNamed(editProfile);
  static void toAddresses({bool isSelectionMode = false, String? addressType}) =>
      Get.toNamed(addresses, arguments: {
        'isSelectionMode': isSelectionMode,
        'addressType': addressType,
      });
  static void toSettings() => Get.toNamed(settings);
  static void toChangePassword() => Get.toNamed(changePassword);
  static void toHelpCenter() => Get.toNamed(helpCenter);
  static void toContactUs() => Get.toNamed(contactUs);
  static void toAbout() => Get.toNamed(about);
  static void toTerms() => Get.toNamed(terms);
  static void toPrivacy() => Get.toNamed(privacy);
}
