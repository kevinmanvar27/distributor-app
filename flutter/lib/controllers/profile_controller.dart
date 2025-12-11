import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../data/data.dart';

/// Profile Controller
/// Manages user profile, account settings, and preferences
class ProfileController extends GetxController {
  final AuthRepository _authRepository;

  ProfileController({
    AuthRepository? authRepository,
  }) : _authRepository = authRepository ?? AuthRepository(Get.find());

  // User data
  final Rx<UserModel?> user = Rx<UserModel?>(null);
  
  // Profile form
  final profileFormKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final companyNameController = TextEditingController();
  final businessTypeController = TextEditingController();
  final taxIdController = TextEditingController();
  
  // Address form
  final addressFormKey = GlobalKey<FormState>();
  final addressLine1Controller = TextEditingController();
  final addressLine2Controller = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final postalCodeController = TextEditingController();
  final countryController = TextEditingController();

  // Password form
  final passwordFormKey = GlobalKey<FormState>();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final RxBool showCurrentPassword = false.obs;
  final RxBool showNewPassword = false.obs;
  final RxBool showConfirmPassword = false.obs;

  // Avatar
  final Rx<File?> selectedAvatar = Rx<File?>(null);
  final RxString avatarUrl = ''.obs;

  // Preferences
  final RxBool emailNotifications = true.obs;
  final RxBool pushNotifications = true.obs;
  final RxBool orderUpdates = true.obs;
  final RxBool promotionalEmails = false.obs;
  final RxString language = 'en'.obs;
  final RxString currency = 'USD'.obs;

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isUpdatingProfile = false.obs;
  final RxBool isUpdatingPassword = false.obs;
  final RxBool isUploadingAvatar = false.obs;
  final RxBool isDeletingAccount = false.obs;

  // Edit mode
  final RxBool isEditingProfile = false.obs;
  final RxBool isEditingAddress = false.obs;

  // Getters
  bool get hasUser => user.value != null;
  String get displayName => user.value?.name ?? 'User';
  String get displayEmail => user.value?.email ?? '';
  String get displayPhone => user.value?.phone ?? '';
  String get displayAvatar => avatarUrl.value.isNotEmpty 
      ? avatarUrl.value 
      : user.value?.avatar ?? '';

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    companyNameController.dispose();
    businessTypeController.dispose();
    taxIdController.dispose();
    addressLine1Controller.dispose();
    addressLine2Controller.dispose();
    cityController.dispose();
    stateController.dispose();
    postalCodeController.dispose();
    countryController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  /// Load user profile
  Future<void> loadProfile() async {
    isLoading.value = true;

    try {
      final userData = await _authRepository.getProfile();
      user.value = userData;
      _populateFormFields();
    } on ApiException catch (e) {
      _showError(e.message);
    } finally {
      isLoading.value = false;
    }
  }

  /// Populate form fields with user data
  void _populateFormFields() {
    final u = user.value;
    if (u == null) return;

    nameController.text = u.name;
    emailController.text = u.email;
    phoneController.text = u.phone ?? '';
    companyNameController.text = u.companyName ?? '';
    businessTypeController.text = u.businessType ?? '';
    taxIdController.text = u.taxId ?? '';
    
    // Address
    addressLine1Controller.text = u.address?['line1'] ?? '';
    addressLine2Controller.text = u.address?['line2'] ?? '';
    cityController.text = u.address?['city'] ?? '';
    stateController.text = u.address?['state'] ?? '';
    postalCodeController.text = u.address?['postal_code'] ?? '';
    countryController.text = u.address?['country'] ?? '';

    // Preferences
    emailNotifications.value = u.settings?['email_notifications'] ?? true;
    pushNotifications.value = u.settings?['push_notifications'] ?? true;
    orderUpdates.value = u.settings?['order_updates'] ?? true;
    promotionalEmails.value = u.settings?['promotional_emails'] ?? false;
    language.value = u.settings?['language'] ?? 'en';
    currency.value = u.settings?['currency'] ?? 'USD';
    
    avatarUrl.value = u.avatar ?? '';
  }

  /// Toggle edit profile mode
  void toggleEditProfile() {
    if (isEditingProfile.value) {
      // Cancel editing - restore original values
      _populateFormFields();
    }
    isEditingProfile.value = !isEditingProfile.value;
  }

  /// Toggle edit address mode
  void toggleEditAddress() {
    if (isEditingAddress.value) {
      // Cancel editing - restore original values
      _populateFormFields();
    }
    isEditingAddress.value = !isEditingAddress.value;
  }

  /// Update profile
  Future<void> updateProfile() async {
    if (!profileFormKey.currentState!.validate()) return;

    isUpdatingProfile.value = true;

    try {
      final updatedUser = await _authRepository.updateProfile({
        'name': nameController.text,
        'phone': phoneController.text,
        'company_name': companyNameController.text,
        'business_type': businessTypeController.text,
        'tax_id': taxIdController.text,
      });

      user.value = updatedUser;
      isEditingProfile.value = false;
      _showSuccess('Profile updated successfully');
    } on ApiException catch (e) {
      _showError(e.message);
    } finally {
      isUpdatingProfile.value = false;
    }
  }

  /// Update address
  Future<void> updateAddress() async {
    if (!addressFormKey.currentState!.validate()) return;

    isUpdatingProfile.value = true;

    try {
      final updatedUser = await _authRepository.updateProfile({
        'address': {
          'line1': addressLine1Controller.text,
          'line2': addressLine2Controller.text,
          'city': cityController.text,
          'state': stateController.text,
          'postal_code': postalCodeController.text,
          'country': countryController.text,
        },
      });

      user.value = updatedUser;
      isEditingAddress.value = false;
      _showSuccess('Address updated successfully');
    } on ApiException catch (e) {
      _showError(e.message);
    } finally {
      isUpdatingProfile.value = false;
    }
  }

  /// Change password
  Future<void> changePassword() async {
    if (!passwordFormKey.currentState!.validate()) return;

    if (newPasswordController.text != confirmPasswordController.text) {
      _showError('Passwords do not match');
      return;
    }

    isUpdatingPassword.value = true;

    try {
      await _authRepository.changePassword(
        currentPasswordController.text,
        newPasswordController.text,
        confirmPasswordController.text,
      );

      _clearPasswordForm();
      Get.back();
      _showSuccess('Password changed successfully');
    } on ApiException catch (e) {
      _showError(e.message);
    } finally {
      isUpdatingPassword.value = false;
    }
  }

  /// Clear password form
  void _clearPasswordForm() {
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
    showCurrentPassword.value = false;
    showNewPassword.value = false;
    showConfirmPassword.value = false;
  }

  /// Pick avatar image
  Future<void> pickAvatar({ImageSource source = ImageSource.gallery}) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        selectedAvatar.value = File(pickedFile.path);
        await uploadAvatar();
      }
    } catch (e) {
      _showError('Failed to pick image');
    }
  }

  /// Upload avatar
  Future<void> uploadAvatar() async {
    if (selectedAvatar.value == null) return;

    isUploadingAvatar.value = true;

    try {
      final url = await _authRepository.uploadAvatar(selectedAvatar.value!);
      avatarUrl.value = url;
      
      // Update user model
      if (user.value != null) {
        user.value = user.value!.copyWith(avatar: url);
      }
      
      selectedAvatar.value = null;
      _showSuccess('Avatar updated successfully');
    } on ApiException catch (e) {
      _showError(e.message);
    } finally {
      isUploadingAvatar.value = false;
    }
  }

  /// Remove avatar
  Future<void> removeAvatar() async {
    isUploadingAvatar.value = true;

    try {
      await _authRepository.updateProfile({'avatar': null});
      avatarUrl.value = '';
      
      if (user.value != null) {
        user.value = user.value!.copyWith(avatar: null);
      }
      
      _showSuccess('Avatar removed');
    } on ApiException catch (e) {
      _showError(e.message);
    } finally {
      isUploadingAvatar.value = false;
    }
  }

  /// Update preferences
  Future<void> updatePreferences() async {
    isUpdatingProfile.value = true;

    try {
      await _authRepository.updateProfile({
        'settings': {
          'email_notifications': emailNotifications.value,
          'push_notifications': pushNotifications.value,
          'order_updates': orderUpdates.value,
          'promotional_emails': promotionalEmails.value,
          'language': language.value,
          'currency': currency.value,
        },
      });

      _showSuccess('Preferences updated');
    } on ApiException catch (e) {
      _showError(e.message);
    } finally {
      isUpdatingProfile.value = false;
    }
  }

  /// Delete account
  Future<void> deleteAccount(String password) async {
    isDeletingAccount.value = true;

    try {
      await _authRepository.deleteAccount(password);
      
      // Logout and navigate to login
      Get.offAllNamed('/login');
      _showSuccess('Account deleted successfully');
    } on ApiException catch (e) {
      _showError(e.message);
    } finally {
      isDeletingAccount.value = false;
    }
  }

  /// Show delete account confirmation
  void showDeleteAccountDialog() {
    final passwordController = TextEditingController();
    
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This action cannot be undone. All your data will be permanently deleted.',
              style: TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            const Text('Enter your password to confirm:'),
            const SizedBox(height: 8),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          Obx(() => ElevatedButton(
            onPressed: isDeletingAccount.value
                ? null
                : () {
                    if (passwordController.text.isNotEmpty) {
                      deleteAccount(passwordController.text);
                    }
                  },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: isDeletingAccount.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Delete', style: TextStyle(color: Colors.white)),
          )),
        ],
      ),
    );
  }

  /// Show change password dialog
  void showChangePasswordDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Change Password'),
        content: Form(
          key: passwordFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() => TextFormField(
                controller: currentPasswordController,
                obscureText: !showCurrentPassword.value,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  suffixIcon: IconButton(
                    icon: Icon(showCurrentPassword.value
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        showCurrentPassword.value = !showCurrentPassword.value,
                  ),
                ),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              )),
              const SizedBox(height: 16),
              Obx(() => TextFormField(
                controller: newPasswordController,
                obscureText: !showNewPassword.value,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  suffixIcon: IconButton(
                    icon: Icon(showNewPassword.value
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        showNewPassword.value = !showNewPassword.value,
                  ),
                ),
                validator: (v) {
                  if (v?.isEmpty == true) return 'Required';
                  if (v!.length < 8) return 'Min 8 characters';
                  return null;
                },
              )),
              const SizedBox(height: 16),
              Obx(() => TextFormField(
                controller: confirmPasswordController,
                obscureText: !showConfirmPassword.value,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  suffixIcon: IconButton(
                    icon: Icon(showConfirmPassword.value
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        showConfirmPassword.value = !showConfirmPassword.value,
                  ),
                ),
                validator: (v) {
                  if (v?.isEmpty == true) return 'Required';
                  if (v != newPasswordController.text) return 'Passwords do not match';
                  return null;
                },
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _clearPasswordForm();
              Get.back();
            },
            child: const Text('Cancel'),
          ),
          Obx(() => ElevatedButton(
            onPressed: isUpdatingPassword.value ? null : changePassword,
            child: isUpdatingPassword.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Change'),
          )),
        ],
      ),
    );
  }

  /// Show avatar options
  void showAvatarOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Get.back();
                pickAvatar(source: ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Get.back();
                pickAvatar(source: ImageSource.gallery);
              },
            ),
            if (displayAvatar.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Get.back();
                  removeAvatar();
                },
              ),
          ],
        ),
      ),
    );
  }

  /// Validate email
  String? validateEmail(String? value) {
    if (value?.isEmpty == true) return 'Email is required';
    if (!GetUtils.isEmail(value!)) return 'Invalid email';
    return null;
  }

  /// Validate phone
  String? validatePhone(String? value) {
    if (value?.isEmpty == true) return null; // Optional
    if (!GetUtils.isPhoneNumber(value!)) return 'Invalid phone number';
    return null;
  }

  /// Show success snackbar
  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade900,
      duration: const Duration(seconds: 3),
    );
  }

  /// Show error snackbar
  void _showError(String message) {
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
