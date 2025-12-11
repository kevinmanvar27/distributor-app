import 'package:get/get.dart';
import '../controllers/app_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/product_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/wishlist_controller.dart';
import '../controllers/invoice_controller.dart';
import '../controllers/notification_controller.dart';
import '../controllers/home_controller.dart';
import '../controllers/search_controller.dart';
import '../controllers/checkout_controller.dart';
import '../controllers/profile_controller.dart';
import '../data/repositories/api_provider.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/product_repository.dart';
import '../data/repositories/category_repository.dart';
import '../data/repositories/cart_repository.dart';
import '../data/repositories/wishlist_repository.dart';
import '../data/repositories/invoice_repository.dart';
import '../data/repositories/notification_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../data/repositories/home_repository.dart';

/// Initial Bindings - Loaded when app starts
class InitialBindings extends Bindings {
  @override
  void dependencies() {
    // Core Services - Permanent
    Get.put<ApiProvider>(ApiProvider(), permanent: true);
    
    // Repositories - Lazy Singleton
    Get.lazyPut<AuthRepository>(() => AuthRepository(), fenix: true);
    Get.lazyPut<ProductRepository>(() => ProductRepository(), fenix: true);
    Get.lazyPut<CategoryRepository>(() => CategoryRepository(), fenix: true);
    Get.lazyPut<CartRepository>(() => CartRepository(), fenix: true);
    Get.lazyPut<WishlistRepository>(() => WishlistRepository(), fenix: true);
    Get.lazyPut<InvoiceRepository>(() => InvoiceRepository(), fenix: true);
    Get.lazyPut<NotificationRepository>(() => NotificationRepository(), fenix: true);
    Get.lazyPut<SettingsRepository>(() => SettingsRepository(), fenix: true);
    Get.lazyPut<HomeRepository>(() => HomeRepository(), fenix: true);
    
    // Core Controllers - Permanent
    Get.put<AppController>(AppController(), permanent: true);
    Get.put<AuthController>(AuthController(), permanent: true);
  }
}

/// Auth Bindings - For login/register screens
class AuthBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRepository>(() => AuthRepository());
  }
}

/// Home Bindings - For home screen
class HomeBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<HomeRepository>(() => HomeRepository());
  }
}

/// Product Bindings - For product screens
class ProductBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductController>(() => ProductController());
    Get.lazyPut<ProductRepository>(() => ProductRepository());
    Get.lazyPut<CategoryRepository>(() => CategoryRepository());
  }
}

/// Cart Bindings - For cart screen
class CartBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CartController>(() => CartController());
    Get.lazyPut<CartRepository>(() => CartRepository());
  }
}

/// Wishlist Bindings - For wishlist screen
class WishlistBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WishlistController>(() => WishlistController());
    Get.lazyPut<WishlistRepository>(() => WishlistRepository());
  }
}

/// Checkout Bindings - For checkout screen
class CheckoutBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CheckoutController>(() => CheckoutController());
    Get.lazyPut<CartRepository>(() => CartRepository());
    Get.lazyPut<InvoiceRepository>(() => InvoiceRepository());
  }
}

/// Order Bindings - For order screens
class OrderBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InvoiceController>(() => InvoiceController());
    Get.lazyPut<InvoiceRepository>(() => InvoiceRepository());
  }
}

/// Notification Bindings - For notification screens
class NotificationBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationController>(() => NotificationController());
    Get.lazyPut<NotificationRepository>(() => NotificationRepository());
  }
}

/// Search Bindings - For search screen
class SearchBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SearchController>(() => SearchController());
    Get.lazyPut<ProductRepository>(() => ProductRepository());
  }
}

/// Profile Bindings - For profile screens
class ProfileBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<AuthRepository>(() => AuthRepository());
    Get.lazyPut<SettingsRepository>(() => SettingsRepository());
  }
}

/// Main Screen Bindings - For main screen with bottom nav
class MainBindings extends Bindings {
  @override
  void dependencies() {
    // Home
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<HomeRepository>(() => HomeRepository());
    
    // Products
    Get.lazyPut<ProductController>(() => ProductController());
    Get.lazyPut<ProductRepository>(() => ProductRepository());
    Get.lazyPut<CategoryRepository>(() => CategoryRepository());
    
    // Cart
    Get.lazyPut<CartController>(() => CartController());
    Get.lazyPut<CartRepository>(() => CartRepository());
    
    // Wishlist
    Get.lazyPut<WishlistController>(() => WishlistController());
    Get.lazyPut<WishlistRepository>(() => WishlistRepository());
    
    // Notifications
    Get.lazyPut<NotificationController>(() => NotificationController());
    Get.lazyPut<NotificationRepository>(() => NotificationRepository());
    
    // Profile
    Get.lazyPut<ProfileController>(() => ProfileController());
    
    // Search
    Get.lazyPut<SearchController>(() => SearchController());
  }
}
