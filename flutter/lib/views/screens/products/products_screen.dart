import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/controllers.dart';
import '../../../data/data.dart';
import '../../widgets/widgets.dart';

/// Products Screen
/// Product listing with search, filters, and sorting
class ProductsScreen extends GetView<ProductController> {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          // Search and filter bar
          _buildSearchFilterBar(context),

          // Products grid/list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.products.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.products.isEmpty) {
                return _buildEmptyState(context);
              }

              return RefreshIndicator(
                onRefresh: controller.refreshProducts,
                child: controller.isGridView.value
                    ? _buildProductsGrid(context)
                    : _buildProductsList(context),
              );
            }),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Products'),
      actions: [
        // View toggle
        Obx(() => IconButton(
              icon: Icon(
                controller.isGridView.value
                    ? Icons.view_list
                    : Icons.grid_view,
              ),
              onPressed: controller.toggleViewMode,
            )),
        // Sort
        IconButton(
          icon: const Icon(Icons.sort),
          onPressed: () => _showSortOptions(context),
        ),
      ],
    );
  }

  Widget _buildSearchFilterBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: controller.searchController,
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: controller.clearSearch,
                    )
                  : const SizedBox.shrink()),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            onSubmitted: (_) => controller.searchProducts(),
          ),
          const SizedBox(height: 12),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Filter button
                Obx(() => FilterChip(
                      label: const Text('Filters'),
                      avatar: const Icon(Icons.filter_list, size: 18),
                      selected: controller.hasActiveFilters,
                      onSelected: (_) => _showFilterSheet(context),
                    )),
                const SizedBox(width: 8),

                // Category filter
                Obx(() => controller.selectedCategory.value != null
                    ? Chip(
                        label: Text(controller.selectedCategory.value!.name),
                        onDeleted: controller.clearCategoryFilter,
                      )
                    : const SizedBox.shrink()),

                // In stock filter
                Obx(() => FilterChip(
                      label: const Text('In Stock'),
                      selected: controller.inStockOnly.value,
                      onSelected: (selected) =>
                          controller.setInStockFilter(selected),
                    )),
                const SizedBox(width: 8),

                // On sale filter
                Obx(() => FilterChip(
                      label: const Text('On Sale'),
                      selected: controller.onSaleOnly.value,
                      onSelected: (selected) =>
                          controller.setOnSaleFilter(selected),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsGrid(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 900 ? 4 : (screenWidth > 600 ? 3 : 2);

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.extentAfter < 200) {
          controller.loadMoreProducts();
        }
        return false;
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 0.65,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: controller.products.length + (controller.hasMorePages ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= controller.products.length) {
            return const Center(child: CircularProgressIndicator());
          }

          final product = controller.products[index];
          return ProductCard(
            product: product,
            onTap: () => controller.navigateToProduct(product),
          );
        },
      ),
    );
  }

  Widget _buildProductsList(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.extentAfter < 200) {
          controller.loadMoreProducts();
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.products.length + (controller.hasMorePages ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= controller.products.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final product = controller.products[index];
          return ProductListTile(
            product: product,
            onTap: () => controller.navigateToProduct(product),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No products found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: controller.clearAllFilters,
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }

  void _showSortOptions(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sort By',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...controller.sortOptions.map((option) => Obx(() => RadioListTile<String>(
                  title: Text(option['label']!),
                  value: option['value']!,
                  groupValue: controller.sortBy.value,
                  onChanged: (value) {
                    if (value != null) {
                      controller.setSortOption(value);
                      Get.back();
                    }
                  },
                ))),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextButton(
                    onPressed: () {
                      controller.clearAllFilters();
                      Get.back();
                    },
                    child: const Text('Clear All'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Price range
              Text(
                'Price Range',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Obx(() => RangeSlider(
                    values: RangeValues(
                      controller.minPrice.value,
                      controller.maxPrice.value,
                    ),
                    min: 0,
                    max: controller.maxPriceLimit.value,
                    divisions: 100,
                    labels: RangeLabels(
                      '\$${controller.minPrice.value.toStringAsFixed(0)}',
                      '\$${controller.maxPrice.value.toStringAsFixed(0)}',
                    ),
                    onChanged: (values) {
                      controller.setPriceRange(values.start, values.end);
                    },
                  )),
              const SizedBox(height: 16),

              // Categories
              Text(
                'Categories',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Obx(() => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: controller.categories.map((category) {
                      final isSelected =
                          controller.selectedCategory.value?.id == category.id;
                      return FilterChip(
                        label: Text(category.name),
                        selected: isSelected,
                        onSelected: (_) {
                          if (isSelected) {
                            controller.clearCategoryFilter();
                          } else {
                            controller.filterByCategory(category);
                          }
                        },
                      );
                    }).toList(),
                  )),
              const SizedBox(height: 24),

              // Apply button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    controller.applyFilters();
                    Get.back();
                  },
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
