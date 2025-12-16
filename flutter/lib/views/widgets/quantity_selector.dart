import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Quantity Selector Widget
/// Used for selecting product quantities in cart and product detail screens
class QuantitySelector extends StatelessWidget {
  final int quantity;
  final int minQuantity;
  final int maxQuantity;
  final ValueChanged<int> onChanged;
  final bool enabled;
  final bool showInput;
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? textColor;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.minQuantity = 1,
    this.maxQuantity = 999,
    this.enabled = true,
    this.showInput = false,
    this.size = 32,
    this.backgroundColor,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildButton(
          context,
          icon: Icons.remove,
          onPressed: quantity > minQuantity && enabled
              ? () => onChanged(quantity - 1)
              : null,
        ),
        if (showInput)
          _buildInput(context)
        else
          _buildQuantityDisplay(context),
        _buildButton(
          context,
          icon: Icons.add,
          onPressed: quantity < maxQuantity && enabled
              ? () => onChanged(quantity + 1)
              : null,
        ),
      ],
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required IconData icon,
    VoidCallback? onPressed,
  }) {
    return Material(
      color: onPressed != null
          ? (backgroundColor ?? Theme.of(context).primaryColor.withOpacity(0.1))
          : Colors.grey[200],
      borderRadius: BorderRadius.circular(size / 4),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(size / 4),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            icon,
            size: size * 0.5,
            color: onPressed != null
                ? (iconColor ?? Theme.of(context).primaryColor)
                : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityDisplay(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: size * 1.2),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        quantity.toString(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: size * 0.5,
          fontWeight: FontWeight.bold,
          color: textColor ?? Colors.black87,
        ),
      ),
    );
  }

  Widget _buildInput(BuildContext context) {
    return SizedBox(
      width: size * 2,
      height: size,
      child: TextField(
        controller: TextEditingController(text: quantity.toString()),
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(3),
        ],
        style: TextStyle(
          fontSize: size * 0.45,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
        ),
        enabled: enabled,
        onSubmitted: (value) {
          final newQuantity = int.tryParse(value) ?? quantity;
          final clampedQuantity = newQuantity.clamp(minQuantity, maxQuantity);
          onChanged(clampedQuantity);
        },
      ),
    );
  }
}

/// Compact Quantity Selector - Smaller version for cart items
class CompactQuantitySelector extends StatelessWidget {
  final int quantity;
  final int minQuantity;
  final int maxQuantity;
  final ValueChanged<int> onChanged;
  final bool enabled;
  final bool isLoading;

  const CompactQuantitySelector({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.minQuantity = 1,
    this.maxQuantity = 999,
    this.enabled = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        height: 28,
        width: 90,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return Container(
      height: 28,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCompactButton(
            context,
            icon: Icons.remove,
            onPressed: quantity > minQuantity && enabled
                ? () => onChanged(quantity - 1)
                : null,
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 32),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              quantity.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _buildCompactButton(
            context,
            icon: Icons.add,
            onPressed: quantity < maxQuantity && enabled
                ? () => onChanged(quantity + 1)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactButton(
    BuildContext context, {
    required IconData icon,
    VoidCallback? onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 28,
        height: 26,
        decoration: BoxDecoration(
          color: onPressed != null ? Colors.grey[100] : Colors.grey[50],
        ),
        child: Icon(
          icon,
          size: 16,
          color: onPressed != null
              ? Theme.of(context).primaryColor
              : Colors.grey[400],
        ),
      ),
    );
  }
}

/// Stepper Quantity Selector - Vertical stepper style
class StepperQuantitySelector extends StatelessWidget {
  final int quantity;
  final int minQuantity;
  final int maxQuantity;
  final ValueChanged<int> onChanged;
  final bool enabled;
  final String? label;
  final String? unit;

  const StepperQuantitySelector({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.minQuantity = 1,
    this.maxQuantity = 999,
    this.enabled = true,
    this.label,
    this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              label!,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStepperButton(
                context,
                icon: Icons.remove,
                onPressed: quantity > minQuantity && enabled
                    ? () => onChanged(quantity - 1)
                    : null,
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 60),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    Text(
                      quantity.toString(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (unit != null)
                      Text(
                        unit!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
              _buildStepperButton(
                context,
                icon: Icons.add,
                onPressed: quantity < maxQuantity && enabled
                    ? () => onChanged(quantity + 1)
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepperButton(
    BuildContext context, {
    required IconData icon,
    VoidCallback? onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 48,
          height: 56,
          decoration: BoxDecoration(
            color: onPressed != null
                ? Theme.of(context).primaryColor.withOpacity(0.1)
                : Colors.grey[100],
          ),
          child: Icon(
            icon,
            color: onPressed != null
                ? Theme.of(context).primaryColor
                : Colors.grey[400],
          ),
        ),
      ),
    );
  }
}

/// Bulk Quantity Selector - For B2B bulk ordering
class BulkQuantitySelector extends StatelessWidget {
  final int quantity;
  final int minOrderQuantity;
  final int maxOrderQuantity;
  final int incrementStep;
  final ValueChanged<int> onChanged;
  final bool enabled;
  final String? unit;
  final List<int>? quickSelectOptions;

  const BulkQuantitySelector({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.minOrderQuantity = 1,
    this.maxOrderQuantity = 9999,
    this.incrementStep = 1,
    this.enabled = true,
    this.unit,
    this.quickSelectOptions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main quantity selector
        Row(
          children: [
            _buildBulkButton(
              context,
              icon: Icons.remove,
              onPressed: quantity > minOrderQuantity && enabled
                  ? () => onChanged(
                      (quantity - incrementStep).clamp(minOrderQuantity, maxOrderQuantity))
                  : null,
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      quantity.toString(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (unit != null)
                      Text(
                        unit!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            _buildBulkButton(
              context,
              icon: Icons.add,
              onPressed: quantity < maxOrderQuantity && enabled
                  ? () => onChanged(
                      (quantity + incrementStep).clamp(minOrderQuantity, maxOrderQuantity))
                  : null,
            ),
          ],
        ),
        // Quick select options
        if (quickSelectOptions != null && quickSelectOptions!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: quickSelectOptions!.map((option) {
              final isSelected = quantity == option;
              return InkWell(
                onTap: enabled ? () => onChanged(option) : null,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Text(
                    '$option${unit != null ? ' $unit' : ''}',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
        // Min order info
        if (minOrderQuantity > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Minimum order: $minOrderQuantity${unit != null ? ' $unit' : ''}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBulkButton(
    BuildContext context, {
    required IconData icon,
    VoidCallback? onPressed,
  }) {
    return Material(
      color: onPressed != null
          ? Theme.of(context).primaryColor
          : Colors.grey[300],
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(
            icon,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
