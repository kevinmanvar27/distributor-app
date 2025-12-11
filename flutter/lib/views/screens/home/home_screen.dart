import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/controllers.dart';
import '../../../data/data.dart';
import '../../widgets/widgets.dart';

/// Home Screen
/// Main dashboard with featured content, banners, and quick actions
class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Obx(() {
        if (controller.isLoading.value && !controller.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.refreshHomeData,
          child: CustomScrollView(
            slivers: [
              // Search bar
              SliverToBoxAdapter(child: _buildSearchBar(context)),

              // Banners carousel
              if (controller.hasBanners)
                SliverToBoxAdapter(child: _buildBannerCarousel(context)),

              // Quick stats
              if (controller.quickStats.isNotEmpty)
                SliverToBoxAdapter(child: _buildQuickStats(context)),

              // Categories
              if (controller.hasCategories)
                SliverToBoxAdapter(
                  child: _buildSection(
                    context,
                    title: 'Categories',
                    onSeeAll: () => controller.navigateToSection('categories'),
                    child: _buildCategoriesGrid(context),
                  ),
                ),

              // Featured products
              if (controller.featuredProducts.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildSection(
                    context,
                    title: 'Featured Products',
                    onSeeAll: () => controller.navigateToSection('featured'),
                    child: _buildProductsHorizontalList(
                      context,
                      controller.featuredProducts,
                    ),
                  ),
                ),

              // New arrivals
              if (controller.newArrivals.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildSection(
                    context,
                    title: 'New Arrivals',
                    onSeeAll: () => controller.navigateToSection('new_arrivals'),
                    child: _buildProductsHorizontalList(
                      context,
                      controller.newArrivals,
                    ),
                  ),
                ),

              // Best sellers
              if (controller.bestSellers.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildSection(
                    context,
                    title: 'Best Sellers',
                    onSeeAll: () => controller.navigateToSection('best_sellers'),
                    child: _buildProductsHorizontalList(
                      context,
                      controller.bestSellers,
                    ),
                  ),
                ),

              // Deals of the day
              if (controller.dealsOfTheDay.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildSection(
                    context,
                    title: 'Deals of the Day',
                    onSeeAll: () => controller.navigateToSection('deals'),
                    child: _buildProductsHorizontalList(
                      context,
                      controller.dealsOfTheDay,
                    ),
                  ),
                ),

              // Recently viewed
              if (controller.recentlyViewed.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildSection(
                    context,
                    title: 'Recently Viewed',
                    child: _buildProductsHorizontalList(
                      context,
                      controller.recentlyViewed,
                    ),
                  ),
                ),

              // Bottom padding
              const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
            ],
          ),
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: GetBuilder<AppController>(
        builder: (appController) {
          return Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.store,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                appController.settings.value?.appName ?? 'Distributor',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          );
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () => Get.toNamed('/notifications'),
        ),
        GetBuilder<CartController>(
          builder: (cartController) {
            return IconButton(
              icon: Badge(
                isLabelVisible: cartController.itemCount > 0,
                label: Text(
                  cartController.itemCount.toString(),
                  style: const TextStyle(fontSize: 10),
                ),
                child: const Icon(Icons.shopping_cart_outlined),
              ),
              onPressed: () => Get.toNamed('/cart'),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GestureDetector(
        onTap: () => Get.toNamed('/search'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: Colors.grey[600]),
              const SizedBox(width: 12),
              Text(
                'Search products...',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannerCarousel(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bannerHeight = screenWidth * 0.45;

    return Column(
      children: [
        SizedBox(
          height: bannerHeight,
          child: PageView.builder(
            itemCount: controller.banners.length,
            onPageChanged: controller.setBannerIndex,
            itemBuilder: (context, index) {
              final banner = controller.banners[index];
              return GestureDetector(
                onTap: () => controller.handleBannerTap(banner),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    image: banner['image'] != null
                        ? DecorationImage(
                            image: NetworkImage(banner['image']),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: banner['image'] == null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                banner['title'] ?? 'Special Offer',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              if (banner['subtitle'] != null)
                                Text(
                                  banner['subtitle'],
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                            ],
                          ),
                        )
                      : null,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Page indicators
        Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                controller.banners.length,
                (index) => Container(
                  width: controller.currentBannerIndex.value == index ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: controller.currentBannerIndex.value == index
                        ? Theme.of(context).primaryColor
                        : Colors.grey[300],
                  ),
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildStatCard(
            context,
            icon: Icons.shopping_bag_outlined,
            label: 'Orders',
            value: controller.quickStats['orders_count']?.toString() ?? '0',
            color: Colors.blue,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            context,
            icon: Icons.pending_actions_outlined,
            label: 'Pending',
            value: controller.quickStats['pending_orders']?.toString() ?? '0',
            color: Colors.orange,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            context,
            icon: Icons.favorite_outline,
            label: 'Wishlist',
            value: controller.quickStats['wishlist_count']?.toString() ?? '0',
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    VoidCallback? onSeeAll,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (onSeeAll != null)
                TextButton(
                  onPressed: onSeeAll,
                  child: const Text('See All'),
                ),
            ],
          ),
        ),
        child,
      ],
    );
  }

  Widget _buildCategoriesGrid(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: controller.featuredCategories.length,
        itemBuilder: (context, index) {
          final category = controller.featuredCategories[index];
          return GestureDetector(
            onTap: () => controller.navigateToCategory(category),
            child: Container(
              width: 100,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: category.image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              category.image!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            Icons.category,
                            color: Theme.of(context).primaryColor,
                            size: 32,
                          ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductsHorizontalList(
    BuildContext context,
    List<ProductModel> products,
  ) {
    return SizedBox(
      height: 260,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ProductCard(
            product: product,
            onTap: () => controller.navigateToProduct(product),
            width: 160,
          );
        },
      ),
    );
  }
}
