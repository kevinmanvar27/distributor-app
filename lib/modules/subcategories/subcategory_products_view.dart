// 
// Products screen for a specific subcategory
// Shows products grid with infinite scroll pagination

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/dynamic_appbar.dart';
import '../../core/widgets/product_card.dart';
import '../cart/cart_controller.dart';
import '../wishlist/wishlist_controller.dart';
import 'subcategories_controller.dart';

class SubcategoryProductsView extends GetView<SubcategoryProductsController> {
  const SubcategoryProductsView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DynamicAppBar(
        title: controller.subcategory.value?.name ?? 'Products',
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.products.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (controller.hasError.value && controller.products.isEmpty) {
          return _buildErrorState();
        }
        
        if (controller.products.isEmpty) {
          return _buildEmptyState();
        }
        
        return _buildProductsGrid();
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
              'Failed to load products',
              style: AppTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Obx(() => Text(
              controller.errorMessage.value,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            )),
            const SizedBox(height: AppTheme.spacingLg),
            ElevatedButton.icon(
              onPressed: controller.loadProducts,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: AppTheme.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              'No Products',
              style: AppTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              'No products found in this subcategory',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingLg),
            ElevatedButton.icon(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProductsGrid() {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification) {
          final metrics = notification.metrics;
          if (metrics.pixels >= metrics.maxScrollExtent - 200) {
            controller.loadMoreProducts();
          }
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: controller.refreshProducts,
        child: Obx(() => GridView.builder(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.65,
            crossAxisSpacing: AppTheme.spacingMd,
            mainAxisSpacing: AppTheme.spacingMd,
          ),
          itemCount: controller.products.length + (controller.hasMore.value ? 1 : 0),
          itemBuilder: (context, index) {
            // Loading indicator at the end
            if (index >= controller.products.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppTheme.spacingMd),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            
            final product = controller.products[index];
            final wishlistController = Get.find<WishlistController>();
            
            return Obx(() => ProductCard(
              product: product,
              heroTagPrefix: 'subcategory_products',
              onTap: () => controller.goToProductDetail(product),
              onAddToCart: () {
                final cartController = Get.find<CartController>();
                cartController.addToCart(product);
              },
              // Wishlist functionality
              showFavorite: true,
              isFavorite: wishlistController.isInWishlist(product.id),
              onFavorite: () => wishlistController.toggleWishlist(product),
            ));
          },
        )),
      ),
    );
  }
}
