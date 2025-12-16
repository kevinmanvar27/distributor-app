import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/controllers.dart';
import '../../../data/data.dart';

/// Categories Screen
/// Browse all product categories
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productController = Get.find<ProductController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Get.toNamed('/search'),
          ),
        ],
      ),
      body: Obx(() {
        if (productController.isLoadingCategories.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (productController.categories.isEmpty) {
          return _buildEmptyState(context);
        }

        return RefreshIndicator(
          onRefresh: productController.loadCategories,
          child: _buildCategoriesList(context, productController),
        );
      }),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No categories available',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList(
      BuildContext context, ProductController controller) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    if (isTablet) {
      return _buildGridLayout(context, controller);
    }

    return _buildListLayout(context, controller);
  }

  Widget _buildGridLayout(BuildContext context, ProductController controller) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : 3,
        childAspectRatio: 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: controller.categories.length,
      itemBuilder: (context, index) {
        final category = controller.categories[index];
        return _buildCategoryGridItem(context, category);
      },
    );
  }

  Widget _buildCategoryGridItem(BuildContext context, CategoryModel category) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _navigateToCategory(category),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: category.image != null
                  ? Image.network(
                      category.image!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(context),
                    )
                  : _buildPlaceholder(context),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (category.productCount != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${category.productCount} products',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListLayout(BuildContext context, ProductController controller) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.categories.length,
      itemBuilder: (context, index) {
        final category = controller.categories[index];
        return _buildCategoryListItem(context, category);
      },
    );
  }

  Widget _buildCategoryListItem(BuildContext context, CategoryModel category) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _navigateToCategory(category),
        child: Row(
          children: [
            // Category image
            SizedBox(
              width: 100,
              height: 100,
              child: category.image != null
                  ? Image.network(
                      category.image!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(context),
                    )
                  : _buildPlaceholder(context),
            ),
            // Category info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (category.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        category.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (category.productCount != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${category.productCount} products',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        if (category.subcategories?.isNotEmpty == true) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${category.subcategories!.length} subcategories',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Arrow
            const Padding(
              padding: EdgeInsets.all(16),
              child: Icon(Icons.chevron_right, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Icon(
        Icons.category,
        size: 40,
        color: Theme.of(context).primaryColor.withOpacity(0.5),
      ),
    );
  }

  void _navigateToCategory(CategoryModel category) {
    if (category.subcategories?.isNotEmpty == true) {
      Get.to(() => SubcategoriesScreen(category: category));
    } else {
      Get.toNamed('/products', arguments: {'categoryId': category.id});
    }
  }
}

/// Subcategories Screen
/// Shows subcategories of a parent category
class SubcategoriesScreen extends StatelessWidget {
  final CategoryModel category;

  const SubcategoriesScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Get.toNamed('/search'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // View all products in this category
          Card(
            child: ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.grid_view,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              title: const Text('View All Products'),
              subtitle: Text('Browse all ${category.name} products'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () =>
                  Get.toNamed('/products', arguments: {'categoryId': category.id}),
            ),
          ),
          const SizedBox(height: 16),

          // Section header
          Text(
            'Subcategories',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),

          // Subcategories list
          ...?category.subcategories?.map((subcategory) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: subcategory.image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            subcategory.image!,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _buildSubcategoryPlaceholder(context),
                          ),
                        )
                      : _buildSubcategoryPlaceholder(context),
                  title: Text(subcategory.name),
                  subtitle: subcategory.productCount != null
                      ? Text('${subcategory.productCount} products')
                      : null,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Get.toNamed('/products', arguments: {
                    'categoryId': category.id,
                    'subcategoryId': subcategory.id,
                  }),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildSubcategoryPlaceholder(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.category_outlined,
        color: Colors.grey[400],
      ),
    );
  }
}
