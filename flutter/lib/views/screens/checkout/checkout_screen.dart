import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/controllers.dart';
import '../../../data/data.dart';

/// Checkout Screen
/// Multi-step checkout flow with address, shipping, and payment
class CheckoutScreen extends GetView<CheckoutController> {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Step indicator
            _buildStepIndicator(context),

            // Step content
            Expanded(
              child: PageView(
                controller: controller.pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildAddressStep(context),
                  _buildShippingStep(context),
                  _buildPaymentStep(context),
                  _buildReviewStep(context),
                ],
              ),
            ),

            // Navigation buttons
            _buildNavigationButtons(context),
          ],
        );
      }),
    );
  }

  Widget _buildStepIndicator(BuildContext context) {
    final steps = ['Address', 'Shipping', 'Payment', 'Review'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (index) {
          if (index.isOdd) {
            // Connector
            return Expanded(
              child: Obx(() => Container(
                    height: 2,
                    color: controller.currentStep.value > index ~/ 2
                        ? Theme.of(context).primaryColor
                        : Colors.grey[300],
                  )),
            );
          }

          // Step circle
          final stepIndex = index ~/ 2;
          return Obx(() {
            final isCompleted = controller.currentStep.value > stepIndex;
            final isCurrent = controller.currentStep.value == stepIndex;

            return Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted || isCurrent
                        ? Theme.of(context).primaryColor
                        : Colors.grey[300],
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : Text(
                            '${stepIndex + 1}',
                            style: TextStyle(
                              color:
                                  isCurrent ? Colors.white : Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  steps[stepIndex],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    color: isCurrent
                        ? Theme.of(context).primaryColor
                        : Colors.grey[600],
                  ),
                ),
              ],
            );
          });
        }),
      ),
    );
  }

  Widget _buildAddressStep(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shipping Address',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          // Saved addresses
          Obx(() {
            if (controller.savedAddresses.isEmpty) {
              return _buildAddNewAddressCard(context);
            }

            return Column(
              children: [
                ...controller.savedAddresses.map((address) =>
                    _buildAddressCard(context, address)),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _showAddAddressDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add New Address'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context, AddressModel address) {
    return Obx(() {
      final isSelected = controller.selectedAddress.value?.id == address.id;

      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: InkWell(
          onTap: () => controller.selectAddress(address),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Radio<int>(
                  value: address.id,
                  groupValue: controller.selectedAddress.value?.id,
                  onChanged: (_) => controller.selectAddress(address),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            address.fullName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (address.isDefault) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Default',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        address.formattedAddress,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      if (address.phone != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          address.phone!,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => _showEditAddressDialog(context, address),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildAddNewAddressCard(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => _showAddAddressDialog(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.add_location_alt,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Add Shipping Address',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShippingStep(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shipping Method',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          Obx(() => Column(
                children: controller.shippingMethods.map((method) {
                  final isSelected =
                      controller.selectedShippingMethod.value?.id == method.id;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: InkWell(
                      onTap: () => controller.selectShippingMethod(method),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Radio<int>(
                              value: method.id,
                              groupValue:
                                  controller.selectedShippingMethod.value?.id,
                              onChanged: (_) =>
                                  controller.selectShippingMethod(method),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    method.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    method.description,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    method.estimatedDelivery,
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              method.price > 0
                                  ? '\$${method.price.toStringAsFixed(2)}'
                                  : 'Free',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: method.price > 0
                                    ? null
                                    : Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )),
        ],
      ),
    );
  }

  Widget _buildPaymentStep(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          Obx(() => Column(
                children: controller.paymentMethods.map((method) {
                  final isSelected =
                      controller.selectedPaymentMethod.value?.id == method.id;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: InkWell(
                      onTap: () => controller.selectPaymentMethod(method),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Radio<int>(
                              value: method.id,
                              groupValue:
                                  controller.selectedPaymentMethod.value?.id,
                              onChanged: (_) =>
                                  controller.selectPaymentMethod(method),
                            ),
                            Icon(
                              _getPaymentIcon(method.type),
                              size: 32,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    method.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  if (method.description != null)
                                    Text(
                                      method.description!,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 13,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )),

          // Notes
          const SizedBox(height: 24),
          Text(
            'Order Notes (Optional)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller.notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Add any special instructions for your order...',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStep(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review Order',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          // Shipping address summary
          _buildReviewSection(
            context,
            title: 'Shipping Address',
            icon: Icons.location_on,
            content: Obx(() {
              final address = controller.selectedAddress.value;
              if (address == null) return const Text('No address selected');
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(address.fullName,
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  Text(address.formattedAddress),
                ],
              );
            }),
            onEdit: () => controller.goToStep(0),
          ),
          const SizedBox(height: 16),

          // Shipping method summary
          _buildReviewSection(
            context,
            title: 'Shipping Method',
            icon: Icons.local_shipping,
            content: Obx(() {
              final method = controller.selectedShippingMethod.value;
              if (method == null) return const Text('No method selected');
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(method.name),
                  Text(
                    method.price > 0
                        ? '\$${method.price.toStringAsFixed(2)}'
                        : 'Free',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              );
            }),
            onEdit: () => controller.goToStep(1),
          ),
          const SizedBox(height: 16),

          // Payment method summary
          _buildReviewSection(
            context,
            title: 'Payment Method',
            icon: Icons.payment,
            content: Obx(() {
              final method = controller.selectedPaymentMethod.value;
              if (method == null) return const Text('No method selected');
              return Text(method.name);
            }),
            onEdit: () => controller.goToStep(2),
          ),
          const SizedBox(height: 24),

          // Order items
          Text(
            'Order Items',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Obx(() => Column(
                children: controller.cartItems
                    .map((item) => _buildOrderItemTile(context, item))
                    .toList(),
              )),
          const SizedBox(height: 24),

          // Order summary
          _buildOrderSummary(context),
        ],
      ),
    );
  }

  Widget _buildReviewSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget content,
    required VoidCallback onEdit,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: onEdit,
                  child: const Text('Edit'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemTile(BuildContext context, CartItemModel item) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.product?.thumbnail ?? 'https://via.placeholder.com/50',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product?.name ?? 'Product',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Qty: ${item.quantity}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
          Text(
            '\$${item.totalPrice.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() => Column(
              children: [
                _buildSummaryRow('Subtotal',
                    '\$${controller.subtotal.value.toStringAsFixed(2)}'),
                if (controller.discount.value > 0)
                  _buildSummaryRow(
                    'Discount',
                    '-\$${controller.discount.value.toStringAsFixed(2)}',
                    isDiscount: true,
                  ),
                _buildSummaryRow(
                    'Shipping', '\$${controller.shipping.value.toStringAsFixed(2)}'),
                _buildSummaryRow(
                    'Tax', '\$${controller.tax.value.toStringAsFixed(2)}'),
                const Divider(height: 24),
                _buildSummaryRow(
                  'Total',
                  '\$${controller.total.value.toStringAsFixed(2)}',
                  isTotal: true,
                ),
              ],
            )),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isTotal = false,
    bool isDiscount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: isDiscount ? Colors.green : null,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              fontSize: isTotal ? 16 : 14,
              color: isDiscount ? Colors.green : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Obx(() => Row(
              children: [
                if (controller.currentStep.value > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: controller.previousStep,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Back'),
                    ),
                  ),
                if (controller.currentStep.value > 0) const SizedBox(width: 12),
                Expanded(
                  flex: controller.currentStep.value > 0 ? 2 : 1,
                  child: ElevatedButton(
                    onPressed: controller.canProceed
                        ? (controller.currentStep.value == 3
                            ? controller.placeOrder
                            : controller.nextStep)
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: controller.isPlacingOrder.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            controller.currentStep.value == 3
                                ? 'Place Order'
                                : 'Continue',
                          ),
                  ),
                ),
              ],
            )),
      ),
    );
  }

  IconData _getPaymentIcon(String type) {
    switch (type.toLowerCase()) {
      case 'card':
      case 'credit_card':
        return Icons.credit_card;
      case 'bank':
      case 'bank_transfer':
        return Icons.account_balance;
      case 'cod':
      case 'cash':
        return Icons.money;
      case 'wallet':
        return Icons.account_balance_wallet;
      default:
        return Icons.payment;
    }
  }

  void _showAddAddressDialog(BuildContext context) {
    Get.toNamed('/add-address');
  }

  void _showEditAddressDialog(BuildContext context, AddressModel address) {
    Get.toNamed('/edit-address/${address.id}');
  }
}
