import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Price Display Widget
/// Formats and displays prices with currency symbol and optional discount
class PriceDisplay extends StatelessWidget {
  final double price;
  final double? originalPrice;
  final String currencySymbol;
  final String currencyCode;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? priceColor;
  final Color? originalPriceColor;
  final bool showCurrencyCode;
  final TextAlign textAlign;
  final int decimalDigits;

  const PriceDisplay({
    super.key,
    required this.price,
    this.originalPrice,
    this.currencySymbol = '\$',
    this.currencyCode = 'USD',
    this.fontSize = 16,
    this.fontWeight = FontWeight.bold,
    this.priceColor,
    this.originalPriceColor,
    this.showCurrencyCode = false,
    this.textAlign = TextAlign.start,
    this.decimalDigits = 2,
  });

  @override
  Widget build(BuildContext context) {
    final hasDiscount = originalPrice != null && originalPrice! > price;
    final formatter = NumberFormat.currency(
      symbol: currencySymbol,
      decimalDigits: decimalDigits,
    );

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      children: [
        // Current price
        Text(
          showCurrencyCode
              ? '${formatter.format(price)} $currencyCode'
              : formatter.format(price),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: priceColor ?? (hasDiscount ? Colors.red : Colors.black87),
          ),
          textAlign: textAlign,
        ),
        // Original price (if discounted)
        if (hasDiscount)
          Text(
            formatter.format(originalPrice),
            style: TextStyle(
              fontSize: fontSize * 0.85,
              fontWeight: FontWeight.normal,
              color: originalPriceColor ?? Colors.grey,
              decoration: TextDecoration.lineThrough,
            ),
            textAlign: textAlign,
          ),
      ],
    );
  }
}

/// Compact Price Display - Single line with smaller original price
class CompactPriceDisplay extends StatelessWidget {
  final double price;
  final double? originalPrice;
  final String currencySymbol;
  final double fontSize;
  final Color? priceColor;

  const CompactPriceDisplay({
    super.key,
    required this.price,
    this.originalPrice,
    this.currencySymbol = '\$',
    this.fontSize = 14,
    this.priceColor,
  });

  @override
  Widget build(BuildContext context) {
    final hasDiscount = originalPrice != null && originalPrice! > price;
    final formatter = NumberFormat.currency(
      symbol: currencySymbol,
      decimalDigits: 2,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          formatter.format(price),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: priceColor ?? (hasDiscount ? Colors.red : Colors.black87),
          ),
        ),
        if (hasDiscount) ...[
          const SizedBox(width: 4),
          Text(
            formatter.format(originalPrice),
            style: TextStyle(
              fontSize: fontSize * 0.75,
              color: Colors.grey,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      ],
    );
  }
}

/// Large Price Display - For product detail pages
class LargePriceDisplay extends StatelessWidget {
  final double price;
  final double? originalPrice;
  final String currencySymbol;
  final String? unit;
  final double? discountPercentage;
  final Color? priceColor;

  const LargePriceDisplay({
    super.key,
    required this.price,
    this.originalPrice,
    this.currencySymbol = '\$',
    this.unit,
    this.discountPercentage,
    this.priceColor,
  });

  @override
  Widget build(BuildContext context) {
    final hasDiscount = originalPrice != null && originalPrice! > price;
    final formatter = NumberFormat.currency(
      symbol: currencySymbol,
      decimalDigits: 2,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formatter.format(price),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: priceColor ?? (hasDiscount ? Colors.red : Theme.of(context).primaryColor),
              ),
            ),
            if (unit != null)
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 4),
                child: Text(
                  '/ $unit',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),
          ],
        ),
        if (hasDiscount)
          Row(
            children: [
              Text(
                formatter.format(originalPrice),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              if (discountPercentage != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '-${discountPercentage!.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
      ],
    );
  }
}

/// Price Range Display - For products with variants
class PriceRangeDisplay extends StatelessWidget {
  final double minPrice;
  final double maxPrice;
  final String currencySymbol;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? priceColor;

  const PriceRangeDisplay({
    super.key,
    required this.minPrice,
    required this.maxPrice,
    this.currencySymbol = '\$',
    this.fontSize = 16,
    this.fontWeight = FontWeight.bold,
    this.priceColor,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      symbol: currencySymbol,
      decimalDigits: 2,
    );

    // If min and max are the same, show single price
    if (minPrice == maxPrice) {
      return Text(
        formatter.format(minPrice),
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: priceColor ?? Colors.black87,
        ),
      );
    }

    return Text(
      '${formatter.format(minPrice)} - ${formatter.format(maxPrice)}',
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: priceColor ?? Colors.black87,
      ),
    );
  }
}

/// Price Summary Row - For checkout summaries
class PriceSummaryRow extends StatelessWidget {
  final String label;
  final double amount;
  final String currencySymbol;
  final bool isTotal;
  final bool isDiscount;
  final bool isFree;
  final Color? labelColor;
  final Color? amountColor;

  const PriceSummaryRow({
    super.key,
    required this.label,
    required this.amount,
    this.currencySymbol = '\$',
    this.isTotal = false,
    this.isDiscount = false,
    this.isFree = false,
    this.labelColor,
    this.amountColor,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      symbol: currencySymbol,
      decimalDigits: 2,
    );

    String displayAmount;
    if (isFree) {
      displayAmount = 'FREE';
    } else if (isDiscount) {
      displayAmount = '-${formatter.format(amount.abs())}';
    } else {
      displayAmount = formatter.format(amount);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: labelColor ?? (isTotal ? Colors.black87 : Colors.grey[700]),
            ),
          ),
          Text(
            displayAmount,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: amountColor ??
                  (isDiscount
                      ? Colors.green
                      : (isTotal
                          ? Theme.of(context).primaryColor
                          : Colors.black87)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Price Summary Card - Complete order summary
class PriceSummaryCard extends StatelessWidget {
  final double subtotal;
  final double? discount;
  final String? discountCode;
  final double? shipping;
  final double? tax;
  final double total;
  final String currencySymbol;
  final bool showDivider;

  const PriceSummaryCard({
    super.key,
    required this.subtotal,
    this.discount,
    this.discountCode,
    this.shipping,
    this.tax,
    required this.total,
    this.currencySymbol = '\$',
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            PriceSummaryRow(
              label: 'Subtotal',
              amount: subtotal,
              currencySymbol: currencySymbol,
            ),
            if (discount != null && discount! > 0)
              PriceSummaryRow(
                label: discountCode != null ? 'Discount ($discountCode)' : 'Discount',
                amount: discount!,
                currencySymbol: currencySymbol,
                isDiscount: true,
              ),
            if (shipping != null)
              PriceSummaryRow(
                label: 'Shipping',
                amount: shipping!,
                currencySymbol: currencySymbol,
                isFree: shipping == 0,
              ),
            if (tax != null)
              PriceSummaryRow(
                label: 'Tax',
                amount: tax!,
                currencySymbol: currencySymbol,
              ),
            if (showDivider) ...[
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
            ],
            PriceSummaryRow(
              label: 'Total',
              amount: total,
              currencySymbol: currencySymbol,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }
}

/// Savings Display - Shows how much user is saving
class SavingsDisplay extends StatelessWidget {
  final double savings;
  final String currencySymbol;
  final double? percentage;

  const SavingsDisplay({
    super.key,
    required this.savings,
    this.currencySymbol = '\$',
    this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    if (savings <= 0) return const SizedBox.shrink();

    final formatter = NumberFormat.currency(
      symbol: currencySymbol,
      decimalDigits: 2,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.savings_outlined,
            color: Colors.green,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'You save ${formatter.format(savings)}',
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (percentage != null) ...[
            const SizedBox(width: 4),
            Text(
              '(${percentage!.toStringAsFixed(0)}%)',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Unit Price Display - For B2B pricing
class UnitPriceDisplay extends StatelessWidget {
  final double price;
  final String unit;
  final String currencySymbol;
  final int? minQuantity;
  final List<TierPrice>? tierPricing;

  const UnitPriceDisplay({
    super.key,
    required this.price,
    required this.unit,
    this.currencySymbol = '\$',
    this.minQuantity,
    this.tierPricing,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      symbol: currencySymbol,
      decimalDigits: 2,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              formatter.format(price),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              ' / $unit',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        if (minQuantity != null && minQuantity! > 1)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Min. order: $minQuantity $unit',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
        if (tierPricing != null && tierPricing!.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text(
            'Volume Pricing:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...tierPricing!.map((tier) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${tier.minQuantity}+ $unit',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      '${formatter.format(tier.price)} / $unit',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ],
    );
  }
}

/// Tier Price Model
class TierPrice {
  final int minQuantity;
  final double price;

  const TierPrice({
    required this.minQuantity,
    required this.price,
  });
}
