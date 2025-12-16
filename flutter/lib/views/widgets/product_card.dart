import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/controllers.dart';
import '../../data/data.dart';

/// Reusable Product Card Widget
/// Displays product information in a card format
class ProductCard extends StatelessWidget {
  final ProductModel product;
  final bool showAddToCart;
  final bool showWishlist;
  final VoidCallback? onTap;
  final double? width;

  const ProductCard({
    super.key,
    required this.product,
    this.showAddToCart = true,
    this.showWishlist = true,
    this.onTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap ?? () => Get.toNamed('/product/${product.id}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with badges
              _buildImageSection(context),
              // Product info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      // Price
                      _buildPriceRow(context),
                      if (showAddToCart) ...[
                        const SizedBox(height: 8),
                        _buildAddToCartButton(context),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Image.network(
            product.thumbnail ?? 'https://via.placeholder.com/200',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey[200],
              child: const Icon(Icons.image, size: 40),
            ),
          ),
        ),
        // Sale badge
        if (product.isOnSale)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${product.discountPercentage.toStringAsFixed(0)}% OFF',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        // Wishlist button
        if (showWishlist)
          Positioned(
            top: 8,
            right: 8,
            child: _buildWishlistButton(context),
          ),
        // Out of stock overlay
        if (!product.isInStock)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Text(
                  'Out of Stock',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildWishlistButton(BuildContext context) {
    return GetBuilder<WishlistController>(
      builder: (controller) {
        final isInWishlist = controller.isInWishlist(product.id);
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              isInWishlist ? Icons.favorite : Icons.favorite_border,
              size: 20,
              color: isInWishlist ? Colors.red : Colors.grey,
            ),
            onPressed: () {
              if (isInWishlist) {
                controller.removeFromWishlistByProductId(product.id);
              } else {
                controller.addToWishlist(product);
              }
            },
            constraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 36,
            ),
            padding: EdgeInsets.zero,
          ),
        );
      },
    );
  }

  Widget _buildPriceRow(BuildContext context) {
    return Row(
      children: [
        Text(
          '\$${product.displayPrice.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
            fontSize: 16,
          ),
        ),
        if (product.isOnSale) ...[
          const SizedBox(width: 4),
          Text(
            '\$${product.price.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAddToCartButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: product.isInStock ? () => _addToCart() : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
        child: const Text(
          'Add to Cart',
          style: TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  void _addToCart() {
    final cartController = Get.find<CartController>();
    cartController.addToCart(product);
    Get.snackbar(
      'Added to Cart',
      '${product.name} added to cart',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
}

/// Horizontal Product Card for lists
class ProductCardHorizontal extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;

  const ProductCardHorizontal({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap ?? () => Get.toNamed('/product/${product.id}'),
        child: Row(
          children: [
            // Image
            SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    product.thumbnail ?? 'https://via.placeholder.com/100',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image),
                    ),
                  ),
                  if (product.isOnSale)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${product.discountPercentage.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    if (product.category != null)
                      Text(
                        product.category!.name,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '\$${product.displayPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        if (product.isOnSale) ...[
                          const SizedBox(width: 4),
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Actions
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.add_shopping_cart),
                  onPressed: product.isInStock
                      ? () {
                          final cartController = Get.find<CartController>();
                          cartController.addToCart(product);
                        }
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
