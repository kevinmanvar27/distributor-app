// Cart View
// 
// Shopping cart screen with:
// - List of cart items with quantity controls
// - Item removal with swipe-to-delete
// - Price breakdown (subtotal, tax, total)
// - Checkout button
// - Empty cart state

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/dynamic_button.dart';
import '../../core/widgets/dynamic_appbar.dart';
import '../../models/cart_item.dart';
import '../main/main_controller.dart';
import 'cart_controller.dart';

class CartView extends GetView<CartController> {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DynamicAppBar(
        title: 'Shopping Cart',
        actions: [
          Obx(() => controller.hasItems
              ? IconButton(
                  icon: const Icon(Icons.delete_sweep_outlined),
                  onPressed: () => _showClearCartDialog(context),
                  tooltip: 'Clear Cart',
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.isEmpty) {
          return _buildEmptyCart(context);
        }

        return _buildCartContent(context);
      }),
      bottomNavigationBar: Obx(() {
        if (controller.isEmpty) return const SizedBox.shrink();
        return _buildCheckoutBar(context);
      }),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Empty Cart State
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 120,
              color: AppTheme.textSecondary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppTheme.spacingLG),
            Text(
              'Your cart is empty',
              style: AppTheme.headingMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: AppTheme.spacingSM),
            Text(
              'Browse our products and add items to your cart',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingXL),
            DynamicButton(
              text: 'Browse Products',
              onPressed: () {
                // Navigate to Home tab (index 0) instead of reopening app
                final mainController = Get.find<MainController>();
                mainController.goToHome();
              },
              leadingIcon: Icons.storefront_outlined,
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Cart Content
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildCartContent(BuildContext context) {
    return Column(
      children: [
        // Cart items list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppTheme.spacingMD),
            itemCount: controller.cartItems.length,
            itemBuilder: (context, index) {
              final item = controller.cartItems[index];
              return _buildCartItemCard(context, item);
            },
          ),
        ),
        // Price summary
        _buildPriceSummary(context),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Cart Item Card
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildCartItemCard(BuildContext context, CartItem item) {
    return Dismissible(
      key: Key('cart_item_${item.productId}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppTheme.spacingLG),
        margin: const EdgeInsets.only(bottom: AppTheme.spacingMD),
        decoration: BoxDecoration(
          color: AppTheme.errorColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: 28,
        ),
      ),
      onDismissed: (_) => controller.removeFromCart(item.productId),
      confirmDismiss: (_) => _showRemoveItemDialog(context, item),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spacingMD),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          boxShadow: AppTheme.shadowSM,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMD),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image
              _buildProductImage(item),
              const SizedBox(width: AppTheme.spacingMD),
              // Product details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name
                    Text(
                      item.name,
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppTheme.spacingXS),
                    // Price
                    Row(
                      children: [
                        Text(
                          '\$${item.price.toStringAsFixed(2)}',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (item.hasDiscount) ...[
                          const SizedBox(width: AppTheme.spacingSM),
                          Text(
                            '\$${item.displayOriginalPrice.toStringAsFixed(2)}',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textTertiary,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingMD),
                    // Quantity controls and total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildQuantityControls(item),
                        Text(
                          '\$${item.totalPrice.toStringAsFixed(2)}',
                          style: AppTheme.headingSmall.copyWith(
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(CartItem item) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusSM),
      child: Container(
        width: 80,
        height: 80,
        color: AppTheme.backgroundColor,
        child: item.imageUrl != null
            ? Image.network(
                item.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
              )
            : _buildImagePlaceholder(),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppTheme.backgroundColor,
      child: Icon(
        Icons.image_outlined,
        color: AppTheme.textTertiary.withValues(alpha: 0.5),
        size: 32,
      ),
    );
  }

  Widget _buildQuantityControls(CartItem item) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.borderColor),
        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrement button
          _buildQuantityButton(
            icon: Icons.remove,
            onPressed: () => controller.decrementQuantity(item.productId),
            enabled: item.quantity > 1,
          ),
          // Quantity display
          Container(
            constraints: const BoxConstraints(minWidth: 40),
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSM),
            child: Text(
              '${item.quantity}',
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Increment button
          _buildQuantityButton(
            icon: Icons.add,
            onPressed: () => controller.incrementQuantity(item.productId),
            enabled: item.quantity < item.stock,
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool enabled,
  }) {
    return InkWell(
      onTap: enabled ? onPressed : null,
      borderRadius: BorderRadius.circular(AppTheme.radiusSM),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingSM),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? AppTheme.primaryColor : AppTheme.textTertiary,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Price Summary
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildPriceSummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMD),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusLG),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Subtotal
          _buildPriceRow(
            'Subtotal (${controller.uniqueItemsCount} items)',
            '\$${controller.subtotal.toStringAsFixed(2)}',
          ),
          const SizedBox(height: AppTheme.spacingSM),
          // Discount (if any)
          if (controller.totalDiscount > 0) ...[
            _buildPriceRow(
              'Discount',
              '-\$${controller.totalDiscount.toStringAsFixed(2)}',
              valueColor: AppTheme.successColor,
            ),
            const SizedBox(height: AppTheme.spacingSM),
          ],
          // Tax
          _buildPriceRow(
            'Tax (${(controller.taxRate * 100).toInt()}%)',
            '\$${controller.taxAmount.toStringAsFixed(2)}',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppTheme.spacingMD),
            child: Divider(height: 1),
          ),
          // Total
          _buildPriceRow(
            'Total',
            '\$${controller.total.toStringAsFixed(2)}',
            isBold: true,
            labelStyle: AppTheme.headingSmall,
            valueStyle: AppTheme.headingMedium.copyWith(
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
    TextStyle? labelStyle,
    TextStyle? valueStyle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: labelStyle ??
              (isBold
                  ? AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600)
                  : AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary)),
        ),
        Text(
          value,
          style: valueStyle ??
              (isBold
                  ? AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w700)
                  : AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: valueColor,
                    )),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Checkout Bar
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildCheckoutBar(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingMD),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Obx(() => DynamicButton(
          text: 'Checkout (\$${controller.total.toStringAsFixed(2)})',
          onPressed: controller.isCheckingOut.value ? null : controller.checkout,
          isLoading: controller.isCheckingOut.value,
          isFullWidth: true,
          size: ButtonSize.large,
          leadingIcon: Icons.shopping_cart_checkout,
        )),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Dialogs
  // ─────────────────────────────────────────────────────────────────────────────

  Future<bool?> _showRemoveItemDialog(BuildContext context, CartItem item) {
    return Get.dialog<bool>(
      AlertDialog(
        title: const Text('Remove Item'),
        content: Text('Remove "${item.name}" from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.clearCart();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
