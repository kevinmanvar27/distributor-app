// Profile View
// 
// User profile screen with:
// - User avatar and info display
// - Edit profile form
// - Account settings menu
// - Logout button

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/dynamic_button.dart';
import '../../core/widgets/dynamic_appbar.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../routes/app_routes.dart';
import '../wishlist/wishlist_controller.dart';
import 'profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DynamicAppBar(
        title: 'Profile',
        actions: [
          Obx(() => controller.isEditMode.value
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: controller.cancelEditMode,
                  tooltip: 'Cancel',
                )
              : IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: controller.enterEditMode,
                  tooltip: 'Edit Profile',
                )),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.user.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.hasError.value && controller.user.value == null) {
          return _buildErrorState(context);
        }

        return RefreshIndicator(
          onRefresh: controller.refreshProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppTheme.spacingMD),
            child: Column(
              children: [
                // Profile header
                _buildProfileHeader(context),
                const SizedBox(height: AppTheme.spacingXL),
                // Edit form or info display
                controller.isEditMode.value
                    ? _buildEditForm(context)
                    : _buildProfileInfo(context),
                const SizedBox(height: AppTheme.spacingXL),
                // Settings menu (only in view mode)
                if (!controller.isEditMode.value) ...[
                  _buildSettingsMenu(context),
                  const SizedBox(height: AppTheme.spacingXL),
                  // Logout button
                  _buildLogoutButton(context),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Error State
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: AppTheme.errorColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppTheme.spacingLG),
            Text(
              'Failed to load profile',
              style: AppTheme.headingMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: AppTheme.spacingSM),
            Text(
              controller.errorMessage.value,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingXL),
            DynamicButton(
              text: 'Retry',
              onPressed: controller.loadUserProfile,
              leadingIcon: Icons.refresh,
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Profile Header
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildProfileHeader(BuildContext context) {
    return Column(
      children: [
        // Avatar
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.primaryColor,
            boxShadow: AppTheme.shadowMD,
          ),
          child: Center(
            child: Text(
              controller.userInitials,
              style: AppTheme.displaySmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spacingMD),
        // Name
        Text(
          controller.userName,
          style: AppTheme.headingLarge,
        ),
        const SizedBox(height: AppTheme.spacingXS),
        // Email
        Text(
          controller.userEmail,
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Profile Info (View Mode)
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildProfileInfo(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        boxShadow: AppTheme.shadowSM,
      ),
      child: Column(
        children: [
          _buildInfoTile(
            icon: Icons.person_outline,
            label: 'Full Name',
            value: controller.userName,
          ),
          const Divider(height: 1),
          _buildInfoTile(
            icon: Icons.email_outlined,
            label: 'Email',
            value: controller.userEmail,
          ),
          const Divider(height: 1),
          _buildInfoTile(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: controller.userPhone.isNotEmpty 
                ? controller.userPhone 
                : 'Not provided',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(
        label,
        style: AppTheme.bodySmall.copyWith(
          color: AppTheme.textTertiary,
        ),
      ),
      subtitle: Text(
        value,
        style: AppTheme.bodyLarge.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Edit Form
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildEditForm(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMD),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        boxShadow: AppTheme.shadowSM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Edit Profile',
            style: AppTheme.headingSmall,
          ),
          const SizedBox(height: AppTheme.spacingMD),
          // Name field
          CustomTextField(
            controller: controller.nameController,
            label: 'Full Name',
            hint: 'Enter your full name',
            prefixIcon: const Icon(Icons.person_outline),
          ),
          const SizedBox(height: AppTheme.spacingMD),
          // Email field
          CustomTextField.email(
            controller: controller.emailController,
            label: 'Email',
            hint: 'Enter your email',
          ),
          const SizedBox(height: AppTheme.spacingMD),
          // Phone field
          CustomTextField.phone(
            controller: controller.phoneController,
            label: 'Phone',
            hint: 'Enter your phone number',
          ),
          const SizedBox(height: AppTheme.spacingLG),
          // Save button
          Obx(() => DynamicButton(
            text: 'Save Changes',
            onPressed: controller.isSaving.value ? null : controller.saveProfile,
            isLoading: controller.isSaving.value,
            isFullWidth: true,
            leadingIcon: Icons.check,
          )),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Settings Menu
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildSettingsMenu(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        boxShadow: AppTheme.shadowSM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMD),
            child: Text(
              'Settings',
              style: AppTheme.headingSmall,
            ),
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            icon: Icons.shopping_bag_outlined,
            title: 'My Orders',
            subtitle: 'View your order history',
            onTap: () => Get.toNamed('/orders'),
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            icon: Icons.location_on_outlined,
            title: 'Addresses',
            subtitle: 'Manage delivery addresses',
            onTap: () => Get.toNamed('/addresses'),
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            icon: Icons.payment_outlined,
            title: 'Payment Methods',
            subtitle: 'Manage payment options',
            onTap: () => Get.toNamed('/payment-methods'),
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Configure notification preferences',
            onTap: () => Get.toNamed(Routes.notifications),
          ),
          const Divider(height: 1),
          // Wishlist option - shows count badge
          Obx(() {
            final wishlistController = Get.find<WishlistController>();
            return _buildSettingsTile(
              icon: Icons.favorite_outline,
              title: 'Wishlist',
              subtitle: wishlistController.wishlistCount > 0
                  ? '${wishlistController.wishlistCount} saved items'
                  : 'Your saved products',
              onTap: () => Get.toNamed(Routes.wishlist),
              trailing: wishlistController.wishlistCount > 0
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${wishlistController.wishlistCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : null,
            );
          }),
          const Divider(height: 1),
          _buildSettingsTile(
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Get help or contact us',
            onTap: () => Get.toNamed('/support'),
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'App version and info',
            onTap: () => _showAboutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.textSecondary),
      title: Text(title, style: AppTheme.bodyLarge),
      subtitle: Text(
        subtitle,
        style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null) ...[
            trailing,
            const SizedBox(width: 8),
          ],
          const Icon(
            Icons.chevron_right,
            color: AppTheme.textTertiary,
          ),
        ],
      ),
      onTap: onTap,
    );
  }

  void _showAboutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusSM),
              ),
              child: const Icon(
                Icons.storefront,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: AppTheme.spacingMD),
            const Text('Distributor App'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version 1.0.0',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMD),
            Text(
              'A complete e-commerce solution for distributors.',
              style: AppTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Logout Button
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildLogoutButton(BuildContext context) {
    return DynamicButton(
      text: 'Logout',
      onPressed: controller.logout,
      variant: ButtonVariant.outlined,
      isFullWidth: true,
      leadingIcon: Icons.logout,
      color: ButtonColor.danger,
    );
  }
}
