// Login View
// 
// Login screen with email/password form.
// Links to registration and forgot password.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/dynamic_button.dart';
import '../../core/utils/validators.dart';
import 'auth_controller.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});
  
  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    
    return Scaffold(
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
                    // Logo
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.store,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingLg),
                    
                    // Title
                    Text(
                      'Welcome Back',
                      style: AppTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTheme.spacingXs),
                    Text(
                      'Sign in to continue',
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
                    
                    // Email field
                    EmailTextField(
                      controller: emailController,
                      validator: Validators.email,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    
                    // Password field
                    PasswordTextField(
                      controller: passwordController,
                      validator: Validators.password,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                    
                    // Forgot password link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // TODO: Implement forgot password
                          Get.snackbar(
                            'Coming Soon',
                            'Forgot password feature will be available soon.',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                        child: Text(
                          'Forgot Password?',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingLg),
                    
                    // Login button
                    Obx(() => DynamicButton(
                      text: 'Sign In',
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          final success = await controller.login(
                            emailController.text.trim(),
                            passwordController.text,
                          );
                          if (success) {
                            Get.offAllNamed('/main');
                          }
                        }
                      },
                      isLoading: controller.isLoading.value,
                      isFullWidth: true,
                    )),
                    const SizedBox(height: AppTheme.spacingXl),
                    
                    // Register link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Get.toNamed('/register'),
                          child: const Text(
                            'Sign Up',
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
