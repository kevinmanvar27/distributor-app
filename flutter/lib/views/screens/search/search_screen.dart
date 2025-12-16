import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/controllers.dart';
import '../../../data/data.dart';
import '../../widgets/widgets.dart';

/// Search Screen
/// Advanced product search with filters and suggestions
class SearchScreen extends GetView<SearchController> {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: _buildSearchField(context),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Active filters
          _buildActiveFilters(context),
          // Results
          Expanded(
            child: Obx(() {
              // Show suggestions when query is empty
              if (controller.searchQuery.isEmpty) {
                return _buildSuggestionsView(context);
              }

              // Show loading
              if (controller.isSearching.value &&
                  controller.searchResults.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              // Show results
              if (controller.searchResults.isEmpty) {
                return _buildNoResults(context);
              }

              return _buildSearchResults(context);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(right: 8),
      child: TextField(
        controller: controller.searchTextController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Search products...',
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: Obx(() => controller.searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: controller.clearSearch,
                )
              : const SizedBox.shrink()),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceVariant,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onChanged: controller.onSearchQueryChanged,
        onSubmitted: (_) => controller.performSearch(),
        textInputAction: TextInputAction.search,
      ),
    );
  }

  Widget _buildActiveFilters(BuildContext context) {
    return Obx(() {
      final filters = controller.activeFilters;
      if (filters.isEmpty) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...filters.map((filter) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Chip(
                      label: Text(filter),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () => controller.removeFilter(filter),
                    ),
                  )),
              TextButton(
                onPressed: controller.clearAllFilters,
                child: const Text('Clear all'),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSuggestionsView(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Recent searches
        Obx(() {
          if (controller.recentSearches.isEmpty) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Searches',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextButton(
                    onPressed: controller.clearRecentSearches,
                    child: const Text('Clear'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.recentSearches
                    .map((search) => ActionChip(
                          avatar: const Icon(Icons.history, size: 16),
                          label: Text(search),
                          onPressed: () => controller.searchFromHistory(search),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),
            ],
          );
        }),

        // Popular searches
        Obx(() {
          if (controller.popularSearches.isEmpty) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Popular Searches',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.popularSearches
                    .map((search) => ActionChip(
                          avatar: const Icon(Icons.trending_up, size: 16),
                          label: Text(search),
                          onPressed: () => controller.searchFromHistory(search),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),
            ],
          );
        }),

        // Categories
        Obx(() {
          if (controller.categories.isEmpty) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Browse Categories',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 0.9,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: controller.categories.length > 8
                    ? 8
                    : controller.categories.length,
                itemBuilder: (context, index) {
                  final category = controller.categories[index];
                  return _buildCategoryItem(context, category);
                },
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildCategoryItem(BuildContext context, CategoryModel category) {
    return InkWell(
      onTap: () => controller.searchByCategory(category),
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: category.image != null
                ? ClipOval(
                    child: Image.network(
                      category.image!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.category,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  )
                : Icon(
                    Icons.category,
                    color: Theme.of(context).primaryColor,
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            category.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try different keywords or filters',
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: controller.clearSearch,
            child: const Text('Clear Search'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    return Column(
      children: [
        // Results header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() => Text(
                    '${controller.totalResults} results',
                    style: TextStyle(color: Colors.grey[600]),
                  )),
              // Sort dropdown
              Obx(() => DropdownButton<String>(
                    value: controller.sortBy.value,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(
                          value: 'relevance', child: Text('Relevance')),
                      DropdownMenuItem(
                          value: 'price_asc', child: Text('Price: Low to High')),
                      DropdownMenuItem(
                          value: 'price_desc',
                          child: Text('Price: High to Low')),
                      DropdownMenuItem(value: 'newest', child: Text('Newest')),
                      DropdownMenuItem(
                          value: 'best_selling', child: Text('Best Selling')),
                    ],
                    onChanged: (value) {
                      if (value != null) controller.setSortBy(value);
                    },
                  )),
            ],
          ),
        ),
        // Results grid
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollEndNotification &&
                  notification.metrics.extentAfter < 200) {
                controller.loadMoreResults();
              }
              return false;
            },
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:
                    MediaQuery.of(context).size.width > 600 ? 3 : 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: controller.searchResults.length +
                  (controller.hasMoreResults ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= controller.searchResults.length) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ProductCard(product: controller.searchResults[index]);
              },
            ),
          ),
        ),
      ],
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) =>
            _buildFilterContent(context, scrollController),
      ),
    );
  }

  Widget _buildFilterContent(
      BuildContext context, ScrollController scrollController) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filters',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  controller.clearAllFilters();
                  Get.back();
                },
                child: const Text('Reset'),
              ),
            ],
          ),
        ),
        // Filter content
        Expanded(
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              // Price range
              _buildPriceRangeFilter(context),
              const SizedBox(height: 24),

              // Categories
              _buildCategoryFilter(context),
              const SizedBox(height: 24),

              // Availability
              _buildAvailabilityFilter(context),
              const SizedBox(height: 24),

              // Rating
              _buildRatingFilter(context),
            ],
          ),
        ),
        // Apply button
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                controller.applyFilters();
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Apply Filters'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRangeFilter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Price Range',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Obx(() => RangeSlider(
              values: RangeValues(
                controller.minPrice.value,
                controller.maxPrice.value,
              ),
              min: 0,
              max: controller.maxPriceLimit.value,
              divisions: 20,
              labels: RangeLabels(
                '\$${controller.minPrice.value.toStringAsFixed(0)}',
                '\$${controller.maxPrice.value.toStringAsFixed(0)}',
              ),
              onChanged: (values) {
                controller.minPrice.value = values.start;
                controller.maxPrice.value = values.end;
              },
            )),
        Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('\$${controller.minPrice.value.toStringAsFixed(0)}'),
                Text('\$${controller.maxPrice.value.toStringAsFixed(0)}'),
              ],
            )),
      ],
    );
  }

  Widget _buildCategoryFilter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categories',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Obx(() => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.categories.map((category) {
                final isSelected =
                    controller.selectedCategories.contains(category.id);
                return FilterChip(
                  label: Text(category.name),
                  selected: isSelected,
                  onSelected: (_) => controller.toggleCategory(category.id),
                );
              }).toList(),
            )),
      ],
    );
  }

  Widget _buildAvailabilityFilter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Availability',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Obx(() => Column(
              children: [
                CheckboxListTile(
                  title: const Text('In Stock'),
                  value: controller.inStockOnly.value,
                  onChanged: (value) =>
                      controller.inStockOnly.value = value ?? false,
                  contentPadding: EdgeInsets.zero,
                ),
                CheckboxListTile(
                  title: const Text('On Sale'),
                  value: controller.onSaleOnly.value,
                  onChanged: (value) =>
                      controller.onSaleOnly.value = value ?? false,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            )),
      ],
    );
  }

  Widget _buildRatingFilter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Minimum Rating',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Obx(() => Row(
              children: List.generate(5, (index) {
                final rating = index + 1;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => controller.minRating.value = rating.toDouble(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: controller.minRating.value >= rating
                            ? Theme.of(context).primaryColor
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: controller.minRating.value >= rating
                                ? Colors.white
                                : Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$rating',
                            style: TextStyle(
                              color: controller.minRating.value >= rating
                                  ? Colors.white
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            )),
      ],
    );
  }
}
