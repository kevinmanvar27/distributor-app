
import '../data/data.dart';

/// Main App Controller
/// Manages app-wide state: settings, theme, connectivity, initialization
class AppController extends GetxController {
  final SettingsRepository _settingsRepository;
  final HomeRepository _homeRepository;

  AppController({
    SettingsRepository? settingsRepository,
    HomeRepository? homeRepository,
  })  : _settingsRepository = settingsRepository ?? SettingsRepository(Get.find()),
        _homeRepository = homeRepository ?? HomeRepository(Get.find());

  // Observable state
  final Rx<AppSettingsModel?> appSettings = Rx<AppSettingsModel?>(null);
  final Rx<AppConfigModel?> appConfig = Rx<AppConfigModel?>(null);
  final Rx<CompanyInfoModel?> companyInfo = Rx<CompanyInfoModel?>(null);
  
  final RxBool isInitialized = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  
  final RxBool isConnected = true.obs;
  final RxBool isDarkMode = false.obs;
  final RxString currentLocale = 'en'.obs;
  
  // Update availability
  final RxBool hasUpdate = false.obs;
  final RxBool isForceUpdate = false.obs;
  final RxString updateMessage = ''.obs;
  final RxString updateUrl = ''.obs;

  // Getters
  bool get isReady => isInitialized.value && !hasError.value;
  ThemeData get currentTheme => _buildTheme();
  String get appName => appSettings.value?.appName ?? 'Distributor App';
  String get appVersion => appConfig.value?.currentVersion ?? '1.0.0';
  String get currencySymbol => appSettings.value?.currencySymbol ?? '\$';
  String get currencyCode => appSettings.value?.currencyCode ?? 'USD';

  @override
  void onInit() {
    super.onInit();
    initializeApp();
  }

  /// Initialize app with settings from API
  Future<void> initializeApp() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      // Load all settings in parallel
      final results = await Future.wait([
        _settingsRepository.getAppSettings(),
        _settingsRepository.getAppConfig(),
        _settingsRepository.getCompanyInfo(),
      ]);

      appSettings.value = results[0] as AppSettingsModel;
      appConfig.value = results[1] as AppConfigModel;
      companyInfo.value = results[2] as CompanyInfoModel;

      // Apply theme settings
      if (appSettings.value != null) {
        isDarkMode.value = appSettings.value!.defaultTheme == 'dark';
      }

      // Check for updates
      await checkForUpdates();

      isInitialized.value = true;
    } on ApiException catch (e) {
      hasError.value = true;
      errorMessage.value = e.message;
      _showErrorSnackbar(e.message);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to initialize app';
      _showErrorSnackbar('Failed to initialize app');
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh app settings
  Future<void> refreshSettings() async {
    try {
      final settings = await _settingsRepository.getAppSettings();
      appSettings.value = settings;
    } on ApiException catch (e) {
      _showErrorSnackbar(e.message);
    }
  }

  /// Check for app updates
  Future<void> checkForUpdates() async {
    try {
      final updateInfo = await _settingsRepository.checkForUpdates(
        currentVersion: appVersion,
        platform: GetPlatform.isIOS ? 'ios' : 'android',
      );

      hasUpdate.value = updateInfo['has_update'] ?? false;
      isForceUpdate.value = updateInfo['force_update'] ?? false;
      updateMessage.value = updateInfo['message'] ?? '';
      updateUrl.value = updateInfo['update_url'] ?? '';

      if (isForceUpdate.value) {
        _showForceUpdateDialog();
      } else if (hasUpdate.value) {
        _showOptionalUpdateDialog();
      }
    } catch (e) {
      // Silently fail update check
    }
  }

  /// Toggle dark mode
  void toggleDarkMode() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  /// Set dark mode
  void setDarkMode(bool value) {
    isDarkMode.value = value;
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  /// Change locale
  void changeLocale(String locale) {
    currentLocale.value = locale;
    Get.updateLocale(Locale(locale));
  }

  /// Set connectivity status
  void setConnectivity(bool connected) {
    isConnected.value = connected;
    if (!connected) {
      _showNoConnectionSnackbar();
    }
  }

  /// Format currency
  String formatCurrency(double amount) {
    final symbol = currencySymbol;
    final position = appSettings.value?.currencyPosition ?? 'before';
    final decimals = appSettings.value?.currencyDecimals ?? 2;
    
    final formattedAmount = amount.toStringAsFixed(decimals);
    
    if (position == 'before') {
      return '$symbol$formattedAmount';
    } else {
      return '$formattedAmount$symbol';
    }
  }

  /// Build theme from API settings
  ThemeData _buildTheme() {
    final settings = appSettings.value;
    
    if (settings == null) {
      return isDarkMode.value ? ThemeData.dark() : ThemeData.light();
    }

    final primaryColor = settings.primaryColorValue;
    final secondaryColor = settings.secondaryColorValue;
    final accentColor = settings.accentColorValue;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      brightness: isDarkMode.value ? Brightness.dark : Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: settings.fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(settings.borderRadius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(settings.borderRadius),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(settings.borderRadius),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(settings.borderRadius),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(settings.borderRadius),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: primaryColor.withOpacity(0.1),
        selectedColor: primaryColor,
        labelStyle: TextStyle(color: primaryColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(settings.borderRadius / 2),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(settings.borderRadius),
        ),
      ),
    );
  }

  /// Show error snackbar
  void _showErrorSnackbar(String message) {
    if (Get.context != null) {
      Get.snackbar(
        'Error',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Show no connection snackbar
  void _showNoConnectionSnackbar() {
    Get.snackbar(
      'No Connection',
      'Please check your internet connection',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange.shade100,
      colorText: Colors.orange.shade900,
      duration: const Duration(seconds: 3),
    );
  }

  /// Show force update dialog
  void _showForceUpdateDialog() {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: const Text('Update Required'),
          content: Text(updateMessage.value.isNotEmpty
              ? updateMessage.value
              : 'A new version is available. Please update to continue.'),
          actions: [
            ElevatedButton(
              onPressed: () => _launchUpdateUrl(),
              child: const Text('Update Now'),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Show optional update dialog
  void _showOptionalUpdateDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Update Available'),
        content: Text(updateMessage.value.isNotEmpty
            ? updateMessage.value
            : 'A new version is available.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _launchUpdateUrl();
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  /// Launch update URL
  void _launchUpdateUrl() {
    // Will use url_launcher package
    // launchUrl(Uri.parse(updateUrl.value));
  }

  /// Get legal page content
  Future<String> getLegalPage(String type) async {
    try {
      switch (type) {
        case 'terms':
          return await _settingsRepository.getTermsAndConditions();
        case 'privacy':
          return await _settingsRepository.getPrivacyPolicy();
        case 'return':
          return await _settingsRepository.getReturnPolicy();
        case 'shipping':
          return await _settingsRepository.getShippingPolicy();
        default:
          return '';
      }
    } on ApiException catch (e) {
      _showErrorSnackbar(e.message);
      return '';
    }
  }

  /// Get FAQs
  Future<List<Map<String, dynamic>>> getFaqs({String? category}) async {
    try {
      return await _settingsRepository.getFaqs(category: category);
    } on ApiException catch (e) {
      _showErrorSnackbar(e.message);
      return [];
    }
  }

  /// Submit contact form
  Future<bool> submitContactForm({
    required String name,
    required String email,
    required String subject,
    required String message,
    String? phone,
  }) async {
    try {
      await _settingsRepository.submitContactForm(
        name: name,
        email: email,
        subject: subject,
        message: message,
        phone: phone,
      );
      Get.snackbar(
        'Success',
        'Your message has been sent successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );
      return true;
    } on ApiException catch (e) {
      _showErrorSnackbar(e.message);
      return false;
    }
  }

  /// Submit feedback
  Future<bool> submitFeedback({
    required int rating,
    String? feedback,
    String? category,
  }) async {
    try {
      await _settingsRepository.submitFeedback(
        rating: rating,
        feedback: feedback,
        category: category,
      );
      Get.snackbar(
        'Thank You',
        'Your feedback has been submitted',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );
      return true;
    } on ApiException catch (e) {
      _showErrorSnackbar(e.message);
      return false;
    }
  }
}
