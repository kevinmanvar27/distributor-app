import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/controllers.dart';

/// Profile Screen
/// User profile, settings, and account management
class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Get.toNamed('/edit-profile'),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Profile header
              _buildProfileHeader(context),

              // Stats cards
              _buildStatsSection(context),

              // Menu sections
              _buildMenuSection(context),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final user = controller.user.value;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          // Avatar
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                backgroundImage: user?.avatar != null
                    ? NetworkImage(user!.avatar!)
                    : null,
                child: user?.avatar == null
                    ? Text(
                        user?.initials ?? 'U',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: controller.changeAvatar,
                    child: Icon(
                      Icons.camera_alt,
                      size: 20,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Name
          Text(
            user?.fullName ?? 'User',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),

          // Email
          Text(
            user?.email ?? '',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),

          // Business name
          if (user?.businessName != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                user!.businessName!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              context,
              icon: Icons.shopping_bag,
              label: 'Orders',
              value: '${controller.orderCount.value}',
              onTap: () => Get.toNamed('/orders'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              context,
              icon: Icons.favorite,
              label: 'Wishlist',
              value: '${controller.wishlistCount.value}',
              onTap: () => Get.toNamed('/wishlist'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              context,
              icon: Icons.star,
              label: 'Points',
              value: '${controller.loyaltyPoints.value}',
              onTap: () => Get.toNamed('/loyalty'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Account section
          _buildSectionTitle(context, 'Account'),
          _buildMenuCard(
            context,
            items: [
              _MenuItem(
                icon: Icons.person_outline,
                title: 'Personal Information',
                onTap: () => Get.toNamed('/edit-profile'),
              ),
              _MenuItem(
                icon: Icons.business,
                title: 'Business Details',
                onTap: () => Get.toNamed('/business-details'),
              ),
              _MenuItem(
                icon: Icons.location_on_outlined,
                title: 'Addresses',
                onTap: () => Get.toNamed('/addresses'),
              ),
              _MenuItem(
                icon: Icons.payment,
                title: 'Payment Methods',
                onTap: () => Get.toNamed('/payment-methods'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Orders section
          _buildSectionTitle(context, 'Orders'),
          _buildMenuCard(
            context,
            items: [
              _MenuItem(
                icon: Icons.receipt_long,
                title: 'Order History',
                onTap: () => Get.toNamed('/orders'),
              ),
              _MenuItem(
                icon: Icons.assignment_return,
                title: 'Returns & Refunds',
                onTap: () => Get.toNamed('/returns'),
              ),
              _MenuItem(
                icon: Icons.favorite_border,
                title: 'Wishlist',
                onTap: () => Get.toNamed('/wishlist'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Settings section
          _buildSectionTitle(context, 'Settings'),
          _buildMenuCard(
            context,
            items: [
              _MenuItem(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                trailing: Obx(() => Switch(
                      value: controller.notificationsEnabled.value,
                      onChanged: controller.toggleNotifications,
                    )),
              ),
              _MenuItem(
                icon: Icons.language,
                title: 'Language',
                subtitle: 'English',
                onTap: () => _showLanguageDialog(context),
              ),
              _MenuItem(
                icon: Icons.dark_mode_outlined,
                title: 'Dark Mode',
                trailing: Obx(() => Switch(
                      value: controller.darkModeEnabled.value,
                      onChanged: controller.toggleDarkMode,
                    )),
              ),
              _MenuItem(
                icon: Icons.lock_outline,
                title: 'Change Password',
                onTap: () => Get.toNamed('/change-password'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Support section
          _buildSectionTitle(context, 'Support'),
          _buildMenuCard(
            context,
            items: [
              _MenuItem(
                icon: Icons.help_outline,
                title: 'Help Center',
                onTap: () => Get.toNamed('/help'),
              ),
              _MenuItem(
                icon: Icons.chat_bubble_outline,
                title: 'Contact Us',
                onTap: () => Get.toNamed('/contact'),
              ),
              _MenuItem(
                icon: Icons.description_outlined,
                title: 'Terms & Conditions',
                onTap: () => Get.toNamed('/terms'),
              ),
              _MenuItem(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                onTap: () => Get.toNamed('/privacy'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Logout button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showLogoutDialog(context),
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Delete account
          Center(
            child: TextButton(
              onPressed: () => _showDeleteAccountDialog(context),
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
              child: const Text('Delete Account'),
            ),
          ),
          const SizedBox(height: 24),

          // App version
          Center(
            child: Text(
              'Version ${controller.appVersion.value}',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, {required List<_MenuItem> items}) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == items.length - 1;

          return Column(
            children: [
              ListTile(
                leading: Icon(item.icon, color: Theme.of(context).primaryColor),
                title: Text(item.title),
                subtitle: item.subtitle != null ? Text(item.subtitle!) : null,
                trailing: item.trailing ??
                    (item.onTap != null
                        ? const Icon(Icons.chevron_right)
                        : null),
                onTap: item.onTap,
              ),
              if (!isLast) const Divider(height: 1, indent: 56),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: controller.selectedLanguage.value,
              onChanged: (value) {
                controller.setLanguage(value!);
                Get.back();
              },
            ),
            RadioListTile<String>(
              title: const Text('العربية'),
              value: 'ar',
              groupValue: controller.selectedLanguage.value,
              onChanged: (value) {
                controller.setLanguage(value!);
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _showDeleteConfirmation(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    final passwordController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your password to confirm account deletion:'),
            const SizedBox(height: 16),
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
          ElevatedButton(
            onPressed: () {
              controller.deleteAccount(passwordController.text);
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Confirm Delete'),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });
}
