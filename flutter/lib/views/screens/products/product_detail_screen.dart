import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/controllers.dart';
import '../../../data/data.dart';
import '../../widgets/widgets.dart';

/// Product Detail Screen
/// Displays full product information with variants, pricing, and add to cart
class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ProductController productController = Get.find<ProductController>();
  final CartController cartController = Get.find<CartController>();
  final WishlistController wishlistController = Get.find<WishlistController>();

  int _quantity = 1;
  int _currentImageIndex = 0;
  final PageController _imagePageController = PageController();

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final product = productController.selectedProduct.value;

        if (productController.isLoadingProduct.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (product == null) {
          return _buildNotFound(context);
        }

        return CustomScrollView(
          slivers: [
            // App bar with image gallery
            _buildSliverAppBar(context, product),

            // Product details
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and SKU
                    _buildTitleSection(context, product),
                    const SizedBox(height: 16),

                    // Price section
                    _buildPriceSection(context, product),
                    const SizedBox(height: 16),

                    // Stock status
                    _buildStockStatus(context, product),
                    const SizedBox(height: 16),

                    // Variants
                    if (product.variants.isNotEmpty) ...[
                      _buildVariantsSection(context, product),
                      const SizedBox(height: 16),
                    ],

                    // Quantity selector
                    _buildQuantitySection(context, product),
                    const SizedBox(height: 24),

                    // Add to cart button
                    _buildAddToCartButton(context, product),
                    const SizedBox(height: 24),

                    // Description
                    _buildDescriptionSection(context, product),
                    const SizedBox(height: 24),

                    // Specifications
                    if (product.specifications.isNotEmpty) ...[
                      _buildSpecificationsSection(context, product),
                      const SizedBox(height: 24),
                    ],

                    // Related products
                    _buildRelatedProducts(context),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, ProductModel product) {
    final images = product.images.isNotEmpty
        ? product.images
        : [product.thumbnail ?? 'https://via.placeholder.com/400'];

    return SliverAppBar(
      expandedHeight: 350,
      pinned: true,
      actions: [
        // Share
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () => productController.shareProduct(product),
        ),
        // Wishlist
        Obx(() {
          final isWishlisted = wishlistController.isInWishlist(product.id);
          return IconButton(
            icon: Icon(
              isWishlisted ? Icons.favorite : Icons.favorite_border,
              color: isWishlisted ? Colors.red : null,
            ),
            onPressed: () => wishlistController.toggleWishlist(product),
          );
        }),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Image gallery
            PageView.builder(
              controller: _imagePageController,
              onPageChanged: (index) {
                setState(() => _currentImageIndex = index);
              },
              itemCount: images.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _showFullScreenImage(context, images, index),
                  child: Image.network(
                    images[index],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image, size: 80),
                    ),
                  ),
                );
              },
            ),

            // Page indicators
            if (images.length > 1)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    images.length,
                    (index) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentImageIndex == index
                            ? Theme.of(context).primaryColor
                            : Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ),

            // Sale badge
            if (product.isOnSale)
              Positioned(
                top: 100,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${product.discountPercentage.toStringAsFixed(0)}% OFF',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection(BuildContext context, ProductModel product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category
        if (product.category != null)
          Text(
            product.category!.name,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        const SizedBox(height: 4),

        // Name
        Text(
          product.name,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),

        // SKU and brand
        Row(
          children: [
            Text(
              'SKU: ${product.sku}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            if (product.brand != null) ...[
              const SizedBox(width: 16),
              Text(
                'Brand: ${product.brand}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildPriceSection(BuildContext context, ProductModel product) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '\$${product.displayPrice.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
        ),
        if (product.isOnSale) ...[
          const SizedBox(width: 12),
          Text(
            '\$${product.price.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                ),
          ),
        ],
        const Spacer(),
        if (product.minOrderQuantity > 1)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Min. Order: ${product.minOrderQuantity}',
              style: TextStyle(
                color: Colors.orange[800],
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStockStatus(BuildContext context, ProductModel product) {
    final isInStock = product.stockQuantity > 0;
    final isLowStock = product.stockQuantity > 0 && product.stockQuantity <= 10;

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isInStock
                ? (isLowStock ? Colors.orange : Colors.green)
                : Colors.red,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          isInStock
              ? (isLowStock
                  ? 'Low Stock (${product.stockQuantity} left)'
                  : 'In Stock')
              : 'Out of Stock',
          style: TextStyle(
            color: isInStock
                ? (isLowStock ? Colors.orange : Colors.green)
                : Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildVariantsSection(BuildContext context, ProductModel product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Variants',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: product.variants.map((variant) {
            final isSelected =
                productController.selectedVariant.value?.id == variant.id;
            return ChoiceChip(
              label: Text(variant.name),
              selected: isSelected,
              onSelected: (_) => productController.selectVariant(variant),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuantitySection(BuildContext context, ProductModel product) {
    final maxQty = product.stockQuantity > 0 ? product.stockQuantity : 99;

    return Row(
      children: [
        Text(
          'Quantity',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: _quantity > product.minOrderQuantity
                    ? () => setState(() => _quantity--)
                    : null,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '$_quantity',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _quantity < maxQty
                    ? () => setState(() => _quantity++)
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddToCartButton(BuildContext context, ProductModel product) {
    final isInStock = product.stockQuantity > 0;

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isInStock
                ? () {
                    cartController.addToCart(
                      product,
                      quantity: _quantity,
                      variant: productController.selectedVariant.value,
                    );
                    Get.snackbar(
                      'Added to Cart',
                      '${product.name} x $_quantity added to cart',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                : null,
            icon: const Icon(Icons.shopping_cart),
            label: Text(isInStock ? 'Add to Cart' : 'Out of Stock'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton(
          onPressed: isInStock
              ? () {
                  cartController.addToCart(
                    product,
                    quantity: _quantity,
                    variant: productController.selectedVariant.value,
                  );
                  Get.toNamed('/checkout');
                }
              : null,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
          child: const Text('Buy Now'),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(BuildContext context, ProductModel product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          product.description,
          style: TextStyle(
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSpecificationsSection(
      BuildContext context, ProductModel product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Specifications',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: product.specifications.entries.map((entry) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[200]!),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        entry.key,
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        entry.value.toString(),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRelatedProducts(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Related Products',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (productController.relatedProducts.isEmpty) {
            return const SizedBox.shrink();
          }

          return SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: productController.relatedProducts.length,
              itemBuilder: (context, index) {
                final product = productController.relatedProducts[index];
                return Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 12),
                  child: ProductCard(
                    product: product,
                    onTap: () => productController.navigateToProduct(product),
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildNotFound(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Product not found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(
      BuildContext context, List<String> images, int initialIndex) {
    Get.to(
      () => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: PageView.builder(
          controller: PageController(initialPage: initialIndex),
          itemCount: images.length,
          itemBuilder: (context, index) {
            return InteractiveViewer(
              child: Center(
                child: Image.network(
                  images[index],
                  fit: BoxFit.contain,
                ),
              ),
            );
          },
        ),
      ),
      fullscreenDialog: true,
    );
  }
}
