// Register View
// 
// Registration screen with name, email, password, and phone fields.
// Links back to login.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/dynamic_button.dart';
import '../../core/utils/validators.dart';
import 'auth_controller.dart';

class RegisterView extends GetView<AuthController> {
  const RegisterView({super.key});
  
  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingLg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title
                    Text(
                      'Create Account',
                      style: AppTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTheme.spacingXs),
                    Text(
                      'Sign up to get started',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTheme.spacingXl),
                    
                    // Error message
                    Obx(() {
                      if (controller.errorMessage.value.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Container(
                        padding: const EdgeInsets.all(AppTheme.spacingMd),
                        margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          border: Border.all(color: AppTheme.errorColor.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: AppTheme.errorColor),
                            const SizedBox(width: AppTheme.spacingSm),
                            Expanded(
                              child: Text(
                                controller.errorMessage.value,
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.errorColor,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: controller.clearError,
                              color: AppTheme.errorColor,
                            ),
                          ],
                        ),
                      );
                    }),
                    
                    // Name field
                    CustomTextField(
                      controller: nameController,
                      label: 'Full Name',
                      hint: 'Enter your full name',
                      prefixIcon: const Icon(Icons.person_outline),
                      validator: Validators.name,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    
                    // Email field
                    EmailTextField(
                      controller: emailController,
                      validator: Validators.email,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    
                    // Phone field (optional)
                    PhoneTextField(
                      controller: phoneController,
                      validator: (value) {
                        // Phone is optional, only validate if provided
                        if (value != null && value.isNotEmpty) {
                          return Validators.phone(value);
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    
                    // Password field
                    PasswordTextField(
                      controller: passwordController,
                      label: 'Password',
                      validator: Validators.password,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    
                    // Confirm password field
                    PasswordTextField(
                      controller: confirmPasswordController,
                      label: 'Confirm Password',
                      validator: (value) {
                        if (value != passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return Validators.password(value);
                      },
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: AppTheme.spacingLg),
                    
                    // Terms and conditions
                    Text(
                      'By signing up, you agree to our Terms of Service and Privacy Policy',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTheme.spacingLg),
                    
                    // Register button
                    Obx(() => DynamicButton(
                      text: 'Create Account',
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          final success = await controller.register(
                            name: nameController.text.trim(),
                            email: emailController.text.trim(),
                            password: passwordController.text,
                            passwordConfirmation: confirmPasswordController.text,
                            phone: phoneController.text.trim().isNotEmpty 
                                ? phoneController.text.trim() 
                                : null,
                          );
                          if (success) {
                            // If auto-logged in, go to main
                            if (controller.isAuthenticated) {
                              Get.offAllNamed('/main');
                            } else {
                              // Otherwise go back to login
                              Get.back();
                            }
                          }
                        }
                      },
                      isLoading: controller.isLoading.value,
                      isFullWidth: true,
                    )),
                    const SizedBox(height: AppTheme.spacingXl),
                    
                    // Login link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
