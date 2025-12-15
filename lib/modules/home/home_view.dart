// Home View
// 
// Home screen displaying data from /home API ONLY:
// - Categories section (displayed as icons) - CLICKABLE to open subcategories
// - Featured Products section
// - Latest Products section

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/dynamic_appbar.dart';
import '../../models/home_data.dart';
import '../../routes/app_routes.dart';
import '../cart/cart_controller.dart';
import '../main/main_controller.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DynamicAppBar(
        title: 'Distributor',
        showBackButton: false,
        actions: [
          // Search icon - navigates to Products tab with search mode
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _navigateToSearch,
          ),
          _buildCartButton(),
        ],
      ),
      body: Obx(() {
        debugPrint('HomeView: Obx rebuilding - isLoading=${controller.isLoading.value}, categories=${controller.categories.length}, featured=${controller.featuredProducts.length}, latest=${controller.latestProducts.length}');
        
        // Loading state
        if (controller.isLoading.value && !controller.hasContent) {
          return const Center(child: CircularProgressIndicator());
        }
        
        // Error state
        if (controller.hasError.value && !controller.hasContent) {
          return _buildErrorState();
        }
        
        // Empty state
        if (!controller.hasContent) {
          return _buildEmptyState();
        }
        
        // Content
        return RefreshIndicator(
          onRefresh: controller.refreshHomeData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Categories section (as icons)
                if (controller.categories.isNotEmpty)
                  _buildCategoriesSection(),
                
                // Featured Products section
                if (controller.featuredProducts.isNotEmpty)
                  _buildProductSection(
                    title: 'Featured Products',
                    products: controller.featuredProducts,
                  ),
                
                // Latest Products section
                if (controller.latestProducts.isNotEmpty)
                  _buildProductSection(
                    title: 'Latest Products',
                    products: controller.latestProducts,
                  ),
                
                // Bottom padding
                const SizedBox(height: AppTheme.spacingXl),
              ],
            ),
          ),
        );
      }),
    );
  }
  
  /// Navigate to dedicated search screen
  void _navigateToSearch() {
    Get.toNamed(Routes.search);
  }
  
  Widget _buildCartButton() {
    return Obx(() {
      final cartController = Get.find<CartController>();
      final count = cartController.cartCount;
      
      return Stack(
        children: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              try {
                final mainController = Get.find<MainController>();
                mainController.changeTab(2);
              } catch (_) {}
            },
          ),
          if (count > 0)
            Positioned(
              right: 4,
              top: 4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppTheme.errorColor,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Text(
                  count > 99 ? '99+' : count.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      );
    });
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
              'Something went wrong',
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
              onPressed: controller.loadHomeData,
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
              Icons.home_outlined,
              size: 64,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              'No content available',
              style: AppTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              'Check back later for updates',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            ElevatedButton.icon(
              onPressed: controller.refreshHomeData,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build categories section with icons
  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.spacingMd,
            AppTheme.spacingMd,
            AppTheme.spacingMd,
            AppTheme.spacingSm,
          ),
          child: Text(
            'Categories',
            style: AppTheme.titleLarge,
          ),
        ),
        SizedBox(
          height: 110,
          child: Obx(() => ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
            itemCount: controller.categories.length,
            itemBuilder: (context, index) {
              final category = controller.categories[index];
              return _buildCategoryItem(category);
            },
          )),
        ),
      ],
    );
  }
  
  /// Build single category item as icon - CLICKABLE to open subcategories
  Widget _buildCategoryItem(HomeCategory category) {
    // Map category names to icons
    IconData categoryIcon = _getCategoryIcon(category.name);
    
    return GestureDetector(
      onTap: () => _navigateToSubcategories(category),
      child: Container(
        width: 85,
        margin: const EdgeInsets.only(right: AppTheme.spacingSm),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Category icon container
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(
                  color: AppTheme.borderColor,
                  width: 1,
                ),
              ),
              child: Center(
                child: Icon(
                  categoryIcon,
                  color: AppTheme.primaryColor,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingXs),
            // Category name
            Text(
              category.name,
              style: AppTheme.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
  
  /// Navigate to subcategories screen
  void _navigateToSubcategories(HomeCategory category) {
    Get.toNamed(
      '/subcategories/${category.id}',
      arguments: category,
    );
  }
  
  /// Get icon for category based on name
  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();
    
    if (name.contains('electronic') || name.contains('device')) {
      return Icons.devices;
    } else if (name.contains('phone') || name.contains('mobile')) {
      return Icons.phone_android;
    } else if (name.contains('laptop') || name.contains('computer')) {
      return Icons.laptop;
    } else if (name.contains('tv') || name.contains('television')) {
      return Icons.tv;
    } else if (name.contains('camera')) {
      return Icons.camera_alt;
    } else if (name.contains('audio') || name.contains('speaker') || name.contains('headphone')) {
      return Icons.headphones;
    } else if (name.contains('watch') || name.contains('wearable')) {
      return Icons.watch;
    } else if (name.contains('home') || name.contains('appliance')) {
      return Icons.home;
    } else if (name.contains('kitchen')) {
      return Icons.kitchen;
    } else if (name.contains('fashion') || name.contains('cloth')) {
      return Icons.checkroom;
    } else if (name.contains('beauty') || name.contains('cosmetic')) {
      return Icons.face;
    } else if (name.contains('sport') || name.contains('fitness')) {
      return Icons.fitness_center;
    } else if (name.contains('book') || name.contains('stationery')) {
      return Icons.book;
    } else if (name.contains('toy') || name.contains('game')) {
      return Icons.toys;
    } else if (name.contains('food') || name.contains('grocery')) {
      return Icons.local_grocery_store;
    } else if (name.contains('health') || name.contains('medicine')) {
      return Icons.medical_services;
    } else if (name.contains('tool') || name.contains('hardware')) {
      return Icons.build;
    } else if (name.contains('furniture')) {
      return Icons.chair;
    } else if (name.contains('garden') || name.contains('outdoor')) {
      return Icons.park;
    } else if (name.contains('pet')) {
      return Icons.pets;
    } else if (name.contains('baby') || name.contains('kid')) {
      return Icons.child_care;
    } else if (name.contains('car') || name.contains('auto')) {
      return Icons.directions_car;
    } else if (name.contains('office')) {
      return Icons.business_center;
    } else {
      return Icons.category;
    }
  }
  
  /// Build product section (Featured or Latest)
  Widget _buildProductSection({
    required String title,
    required List<HomeProduct> products,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.spacingMd,
            AppTheme.spacingLg,
            AppTheme.spacingMd,
            AppTheme.spacingSm,
          ),
          child: Text(
            title,
            style: AppTheme.titleLarge,
          ),
        ),
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return _buildProductCard(product);
            },
          ),
        ),
      ],
    );
  }
  
  /// Build product card - CLICKABLE, navigates to Product Detail
  Widget _buildProductCard(HomeProduct product) {
    return GestureDetector(
      onTap: () => _navigateToProductDetail(product.id),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppTheme.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppTheme.radiusMd),
                ),
                child: Container(
                  width: double.infinity,
                  color: Colors.grey[100],
                  child: product.imageUrl != null
                      ? Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: AppTheme.textSecondary,
                              size: 32,
                            ),
                          ),
                        )
                      : const Center(
                          child: Icon(
                            Icons.image_outlined,
                            color: AppTheme.textSecondary,
                            size: 32,
                          ),
                        ),
                ),
              ),
            ),
            // Product details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingSm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name
                    Text(
                      product.name,
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // Price row
                    Row(
                      children: [
                        Text(
                          '₹${product.sellingPriceValue.toStringAsFixed(0)}',
                          style: AppTheme.titleSmall.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (product.hasDiscount) ...[
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '₹${product.mrpValue.toStringAsFixed(0)}',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.textSecondary,
                                decoration: TextDecoration.lineThrough,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                    // Stock status
                    if (!product.inStock)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          'Out of Stock',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.errorColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Navigate to product detail screen
  void _navigateToProductDetail(int productId) {
    Get.toNamed(
      Routes.productDetail.replaceFirst(':id', productId.toString()),
    );
  }
}
