// Products View
// 
// Products listing screen with:
// - Grid view display
// - Debounced search bar
// - Infinite scroll pagination
// - Pull-to-refresh
// - NO sort options (removed)
// - NO category filtering (removed)

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/dynamic_appbar.dart';
import '../cart/cart_controller.dart';
import '../wishlist/wishlist_controller.dart';
import 'products_controller.dart';

class ProductsView extends GetView<ProductsController> {
  const ProductsView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Obx(() {
        debugPrint('ProductsView: body Obx rebuilding');
        debugPrint('ProductsView: isLoading=${controller.isLoading.value}, products.length=${controller.products.length}');
        
        if (controller.isLoading.value && controller.products.isEmpty) {
          debugPrint('ProductsView: Showing loading state');
          return _buildLoadingState();
        }
        
        if (controller.hasError.value && controller.products.isEmpty) {
          debugPrint('ProductsView: Showing error state');
          return _buildErrorState();
        }
        
        if (controller.products.isEmpty) {
          debugPrint('ProductsView: Showing empty state');
          return _buildEmptyState();
        }
        
        debugPrint('ProductsView: Showing products list with ${controller.products.length} items');
        return _buildProductsList();
      }),
    );
  }
  
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight + 48),
      child: Obx(() {
        if (controller.isSearching.value) {
          // Search mode: show search input in app bar
          return DynamicAppBar(
            showBackButton: false,
            titleWidget: SearchTextField(
              controller: controller.searchController,
              hint: 'Search products...',
              autofocus: true,
              onSubmitted: controller.search,
              onChanged: controller.onSearchChanged,
              fillColor: Colors.white.withValues(alpha: 0.15),
              textColor: Colors.white,
              hintColor: Colors.white70,
              iconColor: Colors.white70,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: controller.clearSearch,
              ),
            ],
            bottom: _buildFilterBar(),
          );
        }
        
        // Normal mode: show title with search action
        return DynamicAppBar(
          title: 'Products',
          showBackButton: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: controller.toggleSearch,
            ),
          ],
          bottom: _buildFilterBar(),
        );
      }),
    );
  }
  
  PreferredSize _buildFilterBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(48),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
        color: AppTheme.primaryColor, // Match DynamicAppBar background
        child: Row(
          children: [
            Obx(() => Text(
              '${controller.products.length} products',
              style: AppTheme.bodySmall.copyWith(
                color: Colors.white70, // White text on primary background
              ),
            )),
            const Spacer(),
            // Show search query indicator when searching
            Obx(() {
              if (controller.searchQuery.value.isNotEmpty) {
                return Row(
                  children: [
                    const Icon(Icons.search, size: 16, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      '"${controller.searchQuery.value}"',
                      style: AppTheme.bodySmall.copyWith(
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLoadingState() {
    return GridView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: AppTheme.spacingMd,
        mainAxisSpacing: AppTheme.spacingMd,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => const ProductCardShimmer(),
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
            const Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              'No products found',
              style: AppTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Obx(() => Text(
              controller.searchQuery.value.isNotEmpty
                  ? 'No results for "${controller.searchQuery.value}"'
                  : 'Check back later for new products',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            )),
            Obx(() {
              if (controller.searchQuery.value.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: AppTheme.spacingLg),
                  child: ElevatedButton(
                    onPressed: controller.clearSearch,
                    child: const Text('Clear Search'),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProductsList() {
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
              heroTagPrefix: 'products',
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
