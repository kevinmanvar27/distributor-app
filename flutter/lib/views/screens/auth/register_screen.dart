import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/controllers.dart';

/// Register Screen
/// New user registration with business details
class RegisterScreen extends GetView<AuthController> {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? screenSize.width * 0.2 : 24,
              vertical: 24,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Form(
                key: controller.registerFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    _buildHeader(context),
                    const SizedBox(height: 32),

                    // Personal info section
                    _buildSectionTitle(context, 'Personal Information'),
                    const SizedBox(height: 16),
                    _buildPersonalInfoFields(context),
                    const SizedBox(height: 24),

                    // Business info section
                    _buildSectionTitle(context, 'Business Information'),
                    const SizedBox(height: 16),
                    _buildBusinessInfoFields(context),
                    const SizedBox(height: 24),

                    // Password section
                    _buildSectionTitle(context, 'Security'),
                    const SizedBox(height: 16),
                    _buildPasswordFields(context),
                    const SizedBox(height: 24),

                    // Terms and conditions
                    _buildTermsCheckbox(context),
                    const SizedBox(height: 24),

                    // Register button
                    _buildRegisterButton(),
                    const SizedBox(height: 16),

                    // Login link
                    _buildLoginLink(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Join Our Network',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Create your B2B distributor account',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).primaryColor,
          ),
    );
  }

  Widget _buildPersonalInfoFields(BuildContext context) {
    return Column(
      children: [
        // Name field
        TextFormField(
          controller: controller.nameController,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: 'Full Name',
            hintText: 'Enter your full name',
            prefixIcon: const Icon(Icons.person_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Name is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Email field
        TextFormField(
          controller: controller.emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'Enter your email',
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Email is required';
            }
            if (!GetUtils.isEmail(value!)) {
              return 'Enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Phone field
        TextFormField(
          controller: controller.phoneController,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'Phone Number',
            hintText: 'Enter your phone number',
            prefixIcon: const Icon(Icons.phone_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Phone number is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildBusinessInfoFields(BuildContext context) {
    return Column(
      children: [
        // Company name
        TextFormField(
          controller: controller.companyNameController,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: 'Company Name',
            hintText: 'Enter your company name',
            prefixIcon: const Icon(Icons.business_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Company name is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Business type dropdown
        DropdownButtonFormField<String>(
          value: controller.businessType.value.isEmpty
              ? null
              : controller.businessType.value,
          decoration: InputDecoration(
            labelText: 'Business Type',
            prefixIcon: const Icon(Icons.category_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          items: const [
            DropdownMenuItem(value: 'retailer', child: Text('Retailer')),
            DropdownMenuItem(value: 'wholesaler', child: Text('Wholesaler')),
            DropdownMenuItem(value: 'distributor', child: Text('Distributor')),
            DropdownMenuItem(value: 'manufacturer', child: Text('Manufacturer')),
            DropdownMenuItem(value: 'other', child: Text('Other')),
          ],
          onChanged: (value) {
            controller.businessType.value = value ?? '';
          },
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please select business type';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Tax ID
        TextFormField(
          controller: controller.taxIdController,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'Tax ID / GST Number (Optional)',
            hintText: 'Enter your tax ID',
            prefixIcon: const Icon(Icons.receipt_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordFields(BuildContext context) {
    return Column(
      children: [
        // Password field
        Obx(() => TextFormField(
              controller: controller.passwordController,
              obscureText: !controller.showPassword.value,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Create a password',
                prefixIcon: const Icon(Icons.lock_outlined),
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.showPassword.value
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: controller.togglePasswordVisibility,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Password is required';
                }
                if (value!.length < 8) {
                  return 'Password must be at least 8 characters';
                }
                return null;
              },
            )),
        const SizedBox(height: 16),

        // Confirm password field
        Obx(() => TextFormField(
              controller: controller.confirmPasswordController,
              obscureText: !controller.showConfirmPassword.value,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                hintText: 'Confirm your password',
                prefixIcon: const Icon(Icons.lock_outlined),
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.showConfirmPassword.value
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: controller.toggleConfirmPasswordVisibility,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please confirm your password';
                }
                if (value != controller.passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            )),
      ],
    );
  }

  Widget _buildTermsCheckbox(BuildContext context) {
    return Obx(() => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: controller.acceptTerms.value,
              onChanged: (value) =>
                  controller.acceptTerms.value = value ?? false,
            ),
            Expanded(
              child: GestureDetector(
                onTap: () =>
                    controller.acceptTerms.value = !controller.acceptTerms.value,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium,
                      children: [
                        const TextSpan(text: 'I agree to the '),
                        TextSpan(
                          text: 'Terms of Service',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  Widget _buildRegisterButton() {
    return Obx(() => ElevatedButton(
          onPressed: controller.isLoading.value || !controller.acceptTerms.value
              ? null
              : controller.register,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: controller.isLoading.value
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Create Account',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
        ));
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: TextStyle(color: Colors.grey[600]),
        ),
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Sign In'),
        ),
      ],
    );
  }
}
