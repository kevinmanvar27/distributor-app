// Product Detail View
// 
// Product detail screen with:
// - Product image with hero animation
// - White icons overlay above image (share, favorite)
// - Product info (name, price, description)
// - Quantity selector
// - Add to cart / Buy now buttons

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/dynamic_button.dart';
import '../wishlist/wishlist_controller.dart';
import 'product_detail_controller.dart';

class ProductDetailView extends GetView<ProductDetailController> {
  const ProductDetailView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (controller.hasError.value) {
          return _buildErrorState();
        }
        
        final product = controller.product.value;
        if (product == null) {
          return _buildErrorState();
        }
        
        return CustomScrollView(
          slivers: [
            // App bar with image and WHITE icon overlay
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              // Back button with white color
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
              ),
              // Action icons with white color overlay
              actions: [
                // Share button
                Container(
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.share, color: Colors.white),
                    onPressed: () => _shareProduct(product),
                  ),
                ),
                // Favorite button - integrated with WishlistController
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Obx(() {
                    final wishlistController = Get.find<WishlistController>();
                    final isFavorite = wishlistController.isInWishlist(product.id);
                    return IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? AppTheme.errorColor : Colors.white,
                      ),
                      onPressed: () => wishlistController.toggleWishlist(product),
                    );
                  }),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Hero(
                  tag: 'products_${product.id}',
                  child: product.imageUrl != null
                      ? Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                        )
                      : _buildImagePlaceholder(),
                ),
              ),
            ),
            
            // Product info
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      product.name,
                      style: AppTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                    
                    // Price - Show selling price as main, MRP crossed out if discount
                    Row(
                      children: [
                        Text(
                          product.formattedSalePrice,
                          style: AppTheme.headlineMedium.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (product.hasDiscount) ...[
                          const SizedBox(width: AppTheme.spacingSm),
                          Text(
                            product.formattedPrice,
                            style: AppTheme.titleMedium.copyWith(
                              color: AppTheme.textSecondary,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacingSm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.errorColor,
                              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                            ),
                            child: Text(
                              '-${product.discountPercentage}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    
                    // Stock status
                    Row(
                      children: [
                        Icon(
                          product.inStock ? Icons.check_circle : Icons.cancel,
                          color: product.inStock ? AppTheme.successColor : AppTheme.errorColor,
                          size: 20,
                        ),
                        const SizedBox(width: AppTheme.spacingXs),
                        Text(
                          product.inStock
                              ? 'In Stock (${product.stock} available)'
                              : 'Out of Stock',
                          style: AppTheme.bodyMedium.copyWith(
                            color: product.inStock ? AppTheme.successColor : AppTheme.errorColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingLg),
                    
                    // Description
                    if (product.description.isNotEmpty) ...[
                      Text(
                        'Description',
                        style: AppTheme.titleMedium,
                      ),
                      const SizedBox(height: AppTheme.spacingSm),
                      Text(
                        product.description,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingLg),
                    ],
                    
                    // Quantity selector
                    if (product.inStock) ...[
                      Text(
                        'Quantity',
                        style: AppTheme.titleMedium,
                      ),
                      const SizedBox(height: AppTheme.spacingSm),
                      _buildQuantitySelector(),
                    ],
                    
                    // Spacer for bottom buttons
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        final product = controller.product.value;
        if (product == null || !product.inStock) {
          return const SizedBox.shrink();
        }
        
        return Container(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: DynamicButton(
                    text: 'Add to Cart',
                    onPressed: controller.addToCart,
                    isLoading: controller.isAddingToCart.value,
                    variant: ButtonVariant.outlined,
                    leadingIcon: Icons.add_shopping_cart,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: DynamicButton(
                    text: 'Buy Now',
                    onPressed: controller.buyNow,
                    isLoading: controller.isAddingToCart.value,
                    leadingIcon: Icons.flash_on,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
  
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              'Product not found',
              style: AppTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spacingLg),
            ElevatedButton(
              onPressed: () => Get.back(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          size: 64,
          color: Colors.grey,
        ),
      ),
    );
  }
  
  Widget _buildQuantitySelector() {
    return Obx(() => Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.borderColor),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: controller.quantity.value > 1
                ? controller.decrementQuantity
                : null,
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 48),
            alignment: Alignment.center,
            child: Text(
              controller.quantity.value.toString(),
              style: AppTheme.titleMedium,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: controller.product.value != null &&
                    controller.quantity.value < controller.product.value!.stock
                ? controller.incrementQuantity
                : null,
          ),
        ],
      ),
    ));
  }

  /// Share product information using share_plus
  void _shareProduct(dynamic product) async {
    try {
      final text = '''Check out this product:
${product.name}
Price: ${product.formattedSalePrice}
${product.imageUrl ?? ''}''';
      
      final result = await SharePlus.instance.share(
        ShareParams(
          text: text,
          subject: product.name,
        ),
      );
      
      if (result.status == ShareResultStatus.unavailable) {
        Get.snackbar(
          'Share Unavailable',
          'Share is not available on this device',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.errorColor,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Share Failed',
        'Unable to share this product. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
      );
    }
  }
}
