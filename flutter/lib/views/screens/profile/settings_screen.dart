import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/app_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/profile_controller.dart';
import '../../../controllers/notification_controller.dart';

/// Settings Screen - App settings and preferences
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppController appController = Get.find<AppController>();
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Account Section
          _SectionHeader(title: 'Account'),
          _SettingsTile(
            icon: Icons.person,
            title: 'Edit Profile',
            subtitle: 'Update your personal information',
            onTap: () => Get.to(() => const EditProfileScreen()),
          ),
          _SettingsTile(
            icon: Icons.lock,
            title: 'Change Password',
            subtitle: 'Update your password',
            onTap: () => Get.to(() => const ChangePasswordScreen()),
          ),
          _SettingsTile(
            icon: Icons.location_on,
            title: 'Addresses',
            subtitle: 'Manage shipping addresses',
            onTap: () => Get.toNamed('/addresses'),
          ),

          // Preferences Section
          _SectionHeader(title: 'Preferences'),
          Obx(() => _SettingsTile(
                icon: Icons.dark_mode,
                title: 'Dark Mode',
                subtitle: 'Toggle dark theme',
                trailing: Switch(
                  value: appController.isDarkMode.value,
                  onChanged: (value) => appController.toggleTheme(),
                ),
              )),
          _SettingsTile(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Manage notification preferences',
            onTap: () => Get.to(() => const NotificationSettingsScreen()),
          ),
          _SettingsTile(
            icon: Icons.language,
            title: 'Language',
            subtitle: 'English',
            onTap: () => _showLanguageDialog(context),
          ),
          _SettingsTile(
            icon: Icons.attach_money,
            title: 'Currency',
            subtitle: 'USD',
            onTap: () => _showCurrencyDialog(context),
          ),

          // Support Section
          _SectionHeader(title: 'Support'),
          _SettingsTile(
            icon: Icons.help,
            title: 'Help Center',
            subtitle: 'FAQs and support',
            onTap: () => Get.to(() => const HelpCenterScreen()),
          ),
          _SettingsTile(
            icon: Icons.chat,
            title: 'Contact Us',
            subtitle: 'Get in touch with support',
            onTap: () => Get.to(() => const ContactUsScreen()),
          ),
          _SettingsTile(
            icon: Icons.info,
            title: 'About',
            subtitle: 'App version and info',
            onTap: () => Get.to(() => const AboutScreen()),
          ),

          // Legal Section
          _SectionHeader(title: 'Legal'),
          _SettingsTile(
            icon: Icons.description,
            title: 'Terms of Service',
            onTap: () => Get.to(() => const LegalScreen(type: 'terms')),
          ),
          _SettingsTile(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            onTap: () => Get.to(() => const LegalScreen(type: 'privacy')),
          ),

          // Danger Zone
          _SectionHeader(title: 'Account Actions'),
          _SettingsTile(
            icon: Icons.logout,
            title: 'Logout',
            iconColor: Colors.orange,
            onTap: () => _confirmLogout(context, authController),
          ),
          _SettingsTile(
            icon: Icons.delete_forever,
            title: 'Delete Account',
            subtitle: 'Permanently delete your account',
            iconColor: Colors.red,
            textColor: Colors.red,
            onTap: () => _confirmDeleteAccount(context, authController),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LanguageOption(language: 'English', code: 'en', isSelected: true),
            _LanguageOption(language: 'Spanish', code: 'es'),
            _LanguageOption(language: 'French', code: 'fr'),
            _LanguageOption(language: 'German', code: 'de'),
            _LanguageOption(language: 'Arabic', code: 'ar'),
          ],
        ),
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CurrencyOption(currency: 'USD', symbol: '\$', isSelected: true),
            _CurrencyOption(currency: 'EUR', symbol: '€'),
            _CurrencyOption(currency: 'GBP', symbol: '£'),
            _CurrencyOption(currency: 'AED', symbol: 'د.إ'),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              authController.logout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(
      BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This action cannot be undone. All your data will be permanently deleted. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              authController.deleteAccount();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? textColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Theme.of(context).primaryColor),
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String language;
  final String code;
  final bool isSelected;

  const _LanguageOption({
    required this.language,
    required this.code,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(language),
      trailing: isSelected
          ? Icon(Icons.check, color: Theme.of(context).primaryColor)
          : null,
      onTap: () {
        Navigator.pop(context);
        // TODO: Implement language change
      },
    );
  }
}

class _CurrencyOption extends StatelessWidget {
  final String currency;
  final String symbol;
  final bool isSelected;

  const _CurrencyOption({
    required this.currency,
    required this.symbol,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
        child: Text(symbol),
      ),
      title: Text(currency),
      trailing: isSelected
          ? Icon(Icons.check, color: Theme.of(context).primaryColor)
          : null,
      onTap: () {
        Navigator.pop(context);
        // TODO: Implement currency change
      },
    );
  }
}

/// Edit Profile Screen
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = Get.find<AuthController>().user.value;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phone ?? '';
      _companyController.text = user.companyName ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Profile Picture
            Center(
              child: Stack(
                children: [
                  Obx(() {
                    final user = Get.find<AuthController>().user.value;
                    return CircleAvatar(
                      radius: 50,
                      backgroundColor:
                          Theme.of(context).primaryColor.withOpacity(0.1),
                      backgroundImage: user?.profileImage != null
                          ? NetworkImage(user!.profileImage!)
                          : null,
                      child: user?.profileImage == null
                          ? Text(
                              user?.name.isNotEmpty == true
                                  ? user!.name[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                fontSize: 36,
                                color: Theme.of(context).primaryColor,
                              ),
                            )
                          : null,
                    );
                  }),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt,
                            size: 18, color: Colors.white),
                        onPressed: _pickImage,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Email
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!GetUtils.isEmail(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Phone
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            // Company
            TextFormField(
              controller: _companyController,
              decoration: const InputDecoration(
                labelText: 'Company Name',
                prefixIcon: Icon(Icons.business),
              ),
            ),
            const SizedBox(height: 32),

            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveProfile,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _pickImage() {
    // TODO: Implement image picker
    Get.snackbar('Coming Soon', 'Image upload will be available soon');
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await Get.find<ProfileController>().updateProfile({
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'company_name': _companyController.text,
      });

      Get.back();
      Get.snackbar('Success', 'Profile updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile');
    } finally {
      setState(() => _isLoading = false);
    }
  }
}

/// Change Password Screen
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Current Password
            TextFormField(
              controller: _currentPasswordController,
              obscureText: _obscureCurrent,
              decoration: InputDecoration(
                labelText: 'Current Password',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                      _obscureCurrent ? Icons.visibility : Icons.visibility_off),
                  onPressed: () =>
                      setState(() => _obscureCurrent = !_obscureCurrent),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your current password';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // New Password
            TextFormField(
              controller: _newPasswordController,
              obscureText: _obscureNew,
              decoration: InputDecoration(
                labelText: 'New Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                      _obscureNew ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscureNew = !_obscureNew),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a new password';
                }
                if (value.length < 8) {
                  return 'Password must be at least 8 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Confirm Password
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirm,
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                      _obscureConfirm ? Icons.visibility : Icons.visibility_off),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your new password';
                }
                if (value != _newPasswordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Change Button
            ElevatedButton(
              onPressed: _isLoading ? null : _changePassword,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await Get.find<AuthController>().changePassword(
        _currentPasswordController.text,
        _newPasswordController.text,
      );

      Get.back();
      Get.snackbar('Success', 'Password changed successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to change password');
    } finally {
      setState(() => _isLoading = false);
    }
  }
}

// Note: NotificationSettingsScreen is defined in notifications_screen.dart
// This file provides the other settings-related screens

/// Help Center Screen
class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help Center'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Search
          TextField(
            decoration: InputDecoration(
              hintText: 'Search for help...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // FAQ Categories
          const Text(
            'Frequently Asked Questions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _FaqCategory(
            icon: Icons.shopping_bag,
            title: 'Orders & Shipping',
            questions: [
              'How do I track my order?',
              'What are the shipping options?',
              'How long does delivery take?',
            ],
          ),
          _FaqCategory(
            icon: Icons.payment,
            title: 'Payments & Billing',
            questions: [
              'What payment methods are accepted?',
              'How do I apply a coupon?',
              'Can I get an invoice?',
            ],
          ),
          _FaqCategory(
            icon: Icons.assignment_return,
            title: 'Returns & Refunds',
            questions: [
              'What is the return policy?',
              'How do I request a return?',
              'When will I get my refund?',
            ],
          ),
          _FaqCategory(
            icon: Icons.account_circle,
            title: 'Account & Security',
            questions: [
              'How do I reset my password?',
              'How do I update my profile?',
              'How do I delete my account?',
            ],
          ),
        ],
      ),
    );
  }
}

class _FaqCategory extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> questions;

  const _FaqCategory({
    required this.icon,
    required this.title,
    required this.questions,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title),
        children: questions
            .map((q) => ListTile(
                  title: Text(q),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Navigate to FAQ detail
                  },
                ))
            .toList(),
      ),
    );
  }
}

/// Contact Us Screen
class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Us'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Contact Options
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.email),
                  ),
                  title: const Text('Email Support'),
                  subtitle: const Text('support@distributor.com'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Open email
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.phone),
                  ),
                  title: const Text('Phone Support'),
                  subtitle: const Text('+1 (800) 123-4567'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Open phone
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.chat),
                  ),
                  title: const Text('Live Chat'),
                  subtitle: const Text('Available 24/7'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Open chat
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Contact Form
          const Text(
            'Send us a message',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Subject',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          const TextField(
            maxLines: 5,
            decoration: InputDecoration(
              labelText: 'Message',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // TODO: Send message
              Get.snackbar('Success', 'Message sent successfully');
            },
            child: const Text('Send Message'),
          ),
        ],
      ),
    );
  }
}

/// About Screen
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App Logo
          Center(
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.store,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Distributor App',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Description
          const Text(
            'Your trusted B2B distribution partner. We provide quality products at competitive prices with reliable delivery.',
            textAlign: TextAlign.center,
            style: TextStyle(height: 1.5),
          ),
          const SizedBox(height: 32),

          // Links
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('Website'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () {
                    // TODO: Open website
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.facebook),
                  title: const Text('Facebook'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () {
                    // TODO: Open Facebook
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Instagram'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () {
                    // TODO: Open Instagram
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Copyright
          Center(
            child: Text(
              '© 2024 Distributor App. All rights reserved.',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Legal Screen (Terms & Privacy)
class LegalScreen extends StatelessWidget {
  final String type; // 'terms' or 'privacy'

  const LegalScreen({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(type == 'terms' ? 'Terms of Service' : 'Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(
          type == 'terms' ? _termsOfService : _privacyPolicy,
          style: const TextStyle(height: 1.6),
        ),
      ),
    );
  }

  static const String _termsOfService = '''
Terms of Service

Last updated: January 2024

1. Acceptance of Terms
By accessing and using this application, you accept and agree to be bound by the terms and provision of this agreement.

2. Use License
Permission is granted to temporarily download one copy of the materials on Distributor App for personal, non-commercial transitory viewing only.

3. Disclaimer
The materials on Distributor App are provided on an 'as is' basis. Distributor App makes no warranties, expressed or implied, and hereby disclaims and negates all other warranties including, without limitation, implied warranties or conditions of merchantability, fitness for a particular purpose, or non-infringement of intellectual property or other violation of rights.

4. Limitations
In no event shall Distributor App or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use the materials on Distributor App.

5. Accuracy of Materials
The materials appearing on Distributor App could include technical, typographical, or photographic errors. Distributor App does not warrant that any of the materials on its website are accurate, complete or current.

6. Links
Distributor App has not reviewed all of the sites linked to its app and is not responsible for the contents of any such linked site.

7. Modifications
Distributor App may revise these terms of service for its app at any time without notice. By using this app you are agreeing to be bound by the then current version of these terms of service.
''';

  static const String _privacyPolicy = '''
Privacy Policy

Last updated: January 2024

1. Information We Collect
We collect information you provide directly to us, such as when you create an account, make a purchase, or contact us for support.

2. How We Use Your Information
We use the information we collect to:
- Process transactions and send related information
- Send promotional communications
- Respond to your comments and questions
- Analyze usage patterns and improve our services

3. Information Sharing
We do not sell, trade, or otherwise transfer your personal information to outside parties except to provide services you've requested.

4. Data Security
We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.

5. Cookies
We use cookies to enhance your experience, gather general visitor information, and track visits to our app.

6. Third-Party Services
We may employ third-party companies and individuals to facilitate our service, provide service on our behalf, or assist us in analyzing how our service is used.

7. Children's Privacy
Our service does not address anyone under the age of 13. We do not knowingly collect personal information from children under 13.

8. Changes to This Policy
We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page.

9. Contact Us
If you have any questions about this Privacy Policy, please contact us at privacy@distributor.com.
''';
}
