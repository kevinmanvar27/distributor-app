//
// Search View
// Dedicated search screen with:
// - Search input in AppBar
// - Grid view of results
// - Infinite scroll pagination
// - Empty/loading/error states
//

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/dynamic_appbar.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/product_card.dart';
import '../cart/cart_controller.dart';
import '../wishlist/wishlist_controller.dart';
import 'search_controller.dart' as search;

class SearchView extends GetView<search.SearchController> {
  const SearchView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Obx(() {
        // Initial state - no search yet
        if (!controller.hasSearched.value) {
          return _buildInitialState();
        }
        
        // Loading state
        if (controller.isLoading.value && controller.searchResults.isEmpty) {
          return _buildLoadingState();
        }
        
        // Error state
        if (controller.hasError.value && controller.searchResults.isEmpty) {
          return _buildErrorState();
        }
        
        // Empty results
        if (controller.searchResults.isEmpty) {
          return _buildEmptyState();
        }
        
        // Results
        return _buildResultsList();
      }),
    );
  }
  
  PreferredSizeWidget _buildAppBar() {
    return DynamicAppBar(
      titleWidget: SearchTextField(
        controller: controller.searchInputController,
        hint: 'Search products...',
        autofocus: true,
        onChanged: controller.onSearchChanged,
        onSubmitted: controller.onSearchSubmitted,
        fillColor: Colors.white.withValues(alpha: 0.15),
        textColor: Colors.white,
        hintColor: Colors.white70,
        iconColor: Colors.white70,
      ),
      actions: [
        Obx(() {
          if (controller.searchQuery.value.isNotEmpty) {
            return IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: controller.clearSearch,
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }
  
  Widget _buildInitialState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 80,
              color: AppTheme.textTertiary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            Text(
              'Search Products',
              style: AppTheme.headingMedium,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              'Enter a product name, brand, or category to search',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
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
              'Search Failed',
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
              onPressed: () => controller.onSearchSubmitted(controller.searchQuery.value),
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
              Icons.search_off,
              size: 64,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              'No Results Found',
              style: AppTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Obx(() => Text(
              'No products match "${controller.searchQuery.value}"',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            )),
            const SizedBox(height: AppTheme.spacingLg),
            ElevatedButton(
              onPressed: controller.clearSearch,
              child: const Text('Clear Search'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildResultsList() {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification) {
          final metrics = notification.metrics;
          if (metrics.pixels >= metrics.maxScrollExtent - 200) {
            controller.loadMoreResults();
          }
        }
        return false;
      },
      child: Column(
        children: [
          // Results count header
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMd,
              vertical: AppTheme.spacingSm,
            ),
            child: Row(
              children: [
                Obx(() => Text(
                  '${controller.searchResults.length} results for "${controller.searchQuery.value}"',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                )),
              ],
            ),
          ),
          // Results grid
          Expanded(
            child: Obx(() => GridView.builder(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: AppTheme.spacingMd,
                mainAxisSpacing: AppTheme.spacingMd,
              ),
              itemCount: controller.searchResults.length + (controller.hasMore.value ? 1 : 0),
              itemBuilder: (context, index) {
                // Loading indicator at the end
                if (index >= controller.searchResults.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppTheme.spacingMd),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                
                final product = controller.searchResults[index];
                final wishlistController = Get.find<WishlistController>();
                return ProductCard(
                  product: product,
                  variant: ProductCardVariant.grid,
                  onTap: () => controller.goToProductDetail(product),
                  onAddToCart: () {
                    final cartController = Get.find<CartController>();
                    cartController.addToCart(product);
                  },
                  onFavorite: () {
                    wishlistController.toggleWishlist(product);
                  },
                  isFavorite: wishlistController.isInWishlist(product.id),
                );
              },
            )),
          ),
        ],
      ),
    );
  }
}
