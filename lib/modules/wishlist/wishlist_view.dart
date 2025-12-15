// 
// Wishlist screen displaying saved products
// Features:
// - Grid view of wishlist products
// - Remove from wishlist functionality
// - Navigate to product detail on tap
// - Empty state when no items

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/dynamic_appbar.dart';
import '../../core/widgets/product_card.dart';
import '../../routes/app_routes.dart';
import 'wishlist_controller.dart';

class WishlistView extends GetView<WishlistController> {
  const WishlistView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DynamicAppBar(
        title: 'My Wishlist',
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.isEmpty) {
          return _buildEmptyState();
        }

        return _buildWishlistGrid();
      }),
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
              Icons.favorite_border,
              size: 80,
              color: AppTheme.textTertiary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            Text(
              'Your Wishlist is Empty',
              style: AppTheme.headingMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              'Save your favorite products here for easy access',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingXl),
            ElevatedButton.icon(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.shopping_bag_outlined),
              label: const Text('Browse Products'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingLg,
                  vertical: AppTheme.spacingMd,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWishlistGrid() {
    return RefreshIndicator(
      onRefresh: () async {
        // Wishlist is local, just trigger a rebuild
        controller.wishlistItems.refresh();
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: AppTheme.spacingMd,
          mainAxisSpacing: AppTheme.spacingMd,
        ),
        itemCount: controller.wishlistItems.length,
        itemBuilder: (context, index) {
          final product = controller.wishlistItems[index];
          return ProductCard(
            product: product,
            variant: ProductCardVariant.grid,
            onTap: () => _navigateToProductDetail(product.id),
            onFavorite: () => controller.removeFromWishlist(product.id),
            isFavorite: true, // Always true since it's in wishlist
            showFavorite: true,
            showAddToCart: true,
            heroTagPrefix: 'wishlist',
          );
        },
      ),
    );
  }

  void _navigateToProductDetail(int productId) {
    Get.toNamed(
      Routes.productDetail.replaceFirst(':id', productId.toString()),
    );
  }
}
