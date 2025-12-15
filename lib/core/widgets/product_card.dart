// Product Card Widget
// 
// Reusable product card with two variants:
// - Grid: Vertical layout with 0.65 aspect ratio for grid views
// - List: Horizontal layout for list views
// 
// Features:
// - Image with hero animation support
// - Sale badge
// - Out of stock overlay
// - Favorite button
// - Add to cart button
// - Price with discount display
// 
// TODO: Customize styles in AppTheme

import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../theme/app_theme.dart';

enum ProductCardVariant { grid, list }

class ProductCard extends StatelessWidget {
  final Product product;
  final ProductCardVariant variant;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final VoidCallback? onFavorite;
  final bool isFavorite;
  final bool showAddToCart;
  final bool showFavorite;
  final String? heroTagPrefix;
  
  const ProductCard({
    super.key,
    required this.product,
    this.variant = ProductCardVariant.grid,
    this.onTap,
    this.onAddToCart,
    this.onFavorite,
    this.isFavorite = false,
    this.showAddToCart = true,
    this.showFavorite = true,
    this.heroTagPrefix,
  });
  
  @override
  Widget build(BuildContext context) {
    return variant == ProductCardVariant.grid
        ? _buildGridCard(context)
        : _buildListCard(context);
  }
  
  Widget _buildGridCard(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: AppTheme.cardDecoration,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section with badges
            AspectRatio(
              aspectRatio: 0.9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildProductImage(),
                  if (product.isOnSale) _buildSaleBadge(),
                  if (!product.inStock) _buildOutOfStockOverlay(),
                  if (showFavorite) _buildFavoriteButton(),
                ],
              ),
            ),
            // Info section
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingSm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppTheme.spacingXs),
                  _buildPriceRow(),
                  // if (showAddToCart && product.inStock) ...[
                  //   const SizedBox(height: AppTheme.spacingSm),
                  //   _buildAddToCartButton(),
                  // ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildListCard(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: AppTheme.cardDecoration,
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            // Image section
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildProductImage(),
                  if (product.isOnSale) _buildSaleBadge(small: true),
                  if (!product.inStock) _buildOutOfStockOverlay(),
                ],
              ),
            ),
            // Info section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      product.name,
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppTheme.spacingXs),
                    if (product.description.isNotEmpty)
                      Text(
                        product.description,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: AppTheme.spacingSm),
                    _buildPriceRow(),
                  ],
                ),
              ),
            ),
            // Actions
            Padding(
              padding: const EdgeInsets.only(right: AppTheme.spacingMd),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (showFavorite)
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? AppTheme.errorColor : AppTheme.textSecondary,
                      ),
                      onPressed: onFavorite,
                    ),
                  if (showAddToCart && product.inStock)
                    IconButton(
                      icon: const Icon(Icons.add_shopping_cart),
                      color: AppTheme.primaryColor,
                      onPressed: onAddToCart,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProductImage() {
    final imageWidget = product.imageUrl != null
        ? Image.network(
            product.imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _buildLoadingPlaceholder();
            },
          )
        : _buildPlaceholder();
    
    if (heroTagPrefix != null) {
      return Hero(
        tag: '${heroTagPrefix}_${product.id}',
        child: imageWidget,
      );
    }
    return imageWidget;
  }
  
  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          size: 48,
          color: Colors.grey,
        ),
      ),
    );
  }
  
  Widget _buildLoadingPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
    );
  }
  
  Widget _buildSaleBadge({bool small = false}) {
    return Positioned(
      top: small ? 4 : 8,
      left: small ? 4 : 8,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: small ? 6 : 8,
          vertical: small ? 2 : 4,
        ),
        decoration: BoxDecoration(
          color: AppTheme.errorColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        child: Text(
          product.discountPercentage > 0
              ? '-${product.discountPercentage}%'
              : 'SALE',
          style: TextStyle(
            color: Colors.white,
            fontSize: small ? 10 : 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  
  Widget _buildOutOfStockOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: const Center(
        child: Text(
          'OUT OF STOCK',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
  
  Widget _buildFavoriteButton() {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        height: 32,
        width: 32,
        decoration: BoxDecoration(
          color: Colors.white38,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? AppTheme.errorColor : AppTheme.textSecondary,
            size: 23,
          ),
          onPressed: onFavorite,
          constraints: const BoxConstraints(
            minWidth: 36,
            minHeight: 36,
          ),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
  
  Widget _buildPriceRow() {
    return Row(
      children: [
        // Show selling price as main price
        Text(
          product.formattedSalePrice,
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        // Show MRP crossed out if there's a discount
        if (product.hasDiscount) ...[
          const SizedBox(width: AppTheme.spacingXs),
          Text(
            product.formattedPrice,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildAddToCartButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onAddToCart,
        icon: const Icon(Icons.add_shopping_cart, size: 18),
        label: const Text('Add to Cart'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 8),
          textStyle: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

/// A shimmer loading placeholder for product cards
class ProductCardShimmer extends StatelessWidget {
  final ProductCardVariant variant;
  
  const ProductCardShimmer({
    super.key,
    this.variant = ProductCardVariant.grid,
  });
  
  @override
  Widget build(BuildContext context) {
    return variant == ProductCardVariant.grid
        ? _buildGridShimmer()
        : _buildListShimmer();
  }
  
  Widget _buildGridShimmer() {
    return Container(
      decoration: AppTheme.cardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder - use Expanded to take available space
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              color: Colors.grey[300],
            ),
          ),
          // Content placeholder
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingSm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    height: 14,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    height: 14,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    height: 32,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildListShimmer() {
    return Container(
      decoration: AppTheme.cardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Container(
            width: 120,
            height: 120,
            color: Colors.grey[300],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 16,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
