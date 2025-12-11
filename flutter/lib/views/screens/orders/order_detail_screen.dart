import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/controllers.dart';
import '../../../data/data.dart';

/// Order Detail Screen
/// Full order details with timeline, items, and actions
class OrderDetailScreen extends GetView<InvoiceController> {
  const OrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'download',
                child: ListTile(
                  leading: Icon(Icons.download),
                  title: Text('Download Invoice'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: ListTile(
                  leading: Icon(Icons.share),
                  title: Text('Share'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'support',
                child: ListTile(
                  leading: Icon(Icons.support_agent),
                  title: Text('Contact Support'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        final invoice = controller.selectedInvoice.value;

        if (controller.isLoadingInvoice.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (invoice == null) {
          return _buildNotFound(context);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order header
              _buildOrderHeader(context, invoice),
              const SizedBox(height: 24),

              // Status timeline
              _buildStatusTimeline(context, invoice),
              const SizedBox(height: 24),

              // Shipping address
              _buildShippingAddress(context, invoice),
              const SizedBox(height: 24),

              // Order items
              _buildOrderItems(context, invoice),
              const SizedBox(height: 24),

              // Payment summary
              _buildPaymentSummary(context, invoice),
              const SizedBox(height: 24),

              // Actions
              _buildActions(context, invoice),
              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildOrderHeader(BuildContext context, ProformaInvoiceModel invoice) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${invoice.invoiceNumber}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Placed on ${invoice.formattedDate}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                _buildStatusBadge(invoice.status),
              ],
            ),
            if (invoice.trackingNumber != null) ...[
              const Divider(height: 24),
              Row(
                children: [
                  Icon(Icons.local_shipping, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tracking Number',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      Text(
                        invoice.trackingNumber!,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => controller.trackOrder(invoice.id),
                    child: const Text('Track'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTimeline(
      BuildContext context, ProformaInvoiceModel invoice) {
    final statuses = [
      {'status': 'pending', 'label': 'Order Placed', 'icon': Icons.receipt},
      {
        'status': 'processing',
        'label': 'Processing',
        'icon': Icons.inventory_2
      },
      {'status': 'shipped', 'label': 'Shipped', 'icon': Icons.local_shipping},
      {
        'status': 'delivered',
        'label': 'Delivered',
        'icon': Icons.check_circle
      },
    ];

    final currentIndex = statuses.indexWhere(
      (s) => s['status'] == invoice.status.toLowerCase(),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Status',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: List.generate(statuses.length * 2 - 1, (index) {
                if (index.isOdd) {
                  // Connector line
                  final lineIndex = index ~/ 2;
                  final isCompleted = lineIndex < currentIndex;
                  return Expanded(
                    child: Container(
                      height: 3,
                      color: isCompleted
                          ? Theme.of(context).primaryColor
                          : Colors.grey[300],
                    ),
                  );
                }

                // Status icon
                final statusIndex = index ~/ 2;
                final status = statuses[statusIndex];
                final isCompleted = statusIndex <= currentIndex;
                final isCurrent = statusIndex == currentIndex;

                return Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted
                            ? Theme.of(context).primaryColor
                            : Colors.grey[300],
                        border: isCurrent
                            ? Border.all(
                                color: Theme.of(context).primaryColor,
                                width: 3,
                              )
                            : null,
                      ),
                      child: Icon(
                        status['icon'] as IconData,
                        color: isCompleted ? Colors.white : Colors.grey[600],
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      status['label'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight:
                            isCurrent ? FontWeight.bold : FontWeight.normal,
                        color: isCompleted
                            ? Theme.of(context).primaryColor
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingAddress(
      BuildContext context, ProformaInvoiceModel invoice) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Shipping Address',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (invoice.shippingAddress != null) ...[
              Text(
                invoice.shippingAddress!.fullName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(invoice.shippingAddress!.formattedAddress),
              if (invoice.shippingAddress!.phone != null) ...[
                const SizedBox(height: 4),
                Text(invoice.shippingAddress!.phone!),
              ],
            ] else
              Text(
                'No shipping address provided',
                style: TextStyle(color: Colors.grey[600]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItems(BuildContext context, ProformaInvoiceModel invoice) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Items (${invoice.items.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...invoice.items.map((item) => _buildOrderItemTile(context, item)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemTile(
      BuildContext context, ProformaInvoiceItemModel item) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.product?.thumbnail ?? 'https://via.placeholder.com/60',
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 60,
                height: 60,
                color: Colors.grey[200],
                child: const Icon(Icons.image),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product?.name ?? 'Product',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty: ${item.quantity} × \$${item.unitPrice.toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
          Text(
            '\$${item.totalPrice.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(
      BuildContext context, ProformaInvoiceModel invoice) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Summary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _buildSummaryRow('Subtotal', '\$${invoice.subtotal.toStringAsFixed(2)}'),
            if (invoice.discount > 0)
              _buildSummaryRow(
                'Discount',
                '-\$${invoice.discount.toStringAsFixed(2)}',
                isDiscount: true,
              ),
            _buildSummaryRow('Tax', '\$${invoice.tax.toStringAsFixed(2)}'),
            _buildSummaryRow(
                'Shipping', '\$${invoice.shippingCost.toStringAsFixed(2)}'),
            const Divider(height: 24),
            _buildSummaryRow(
              'Total',
              '\$${invoice.totalAmount.toStringAsFixed(2)}',
              isTotal: true,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.payment, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Payment Method: ${invoice.paymentMethod ?? 'N/A'}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
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

  Widget _buildActions(BuildContext context, ProformaInvoiceModel invoice) {
    return Column(
      children: [
        if (invoice.canCancel)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showCancelDialog(context, invoice),
              icon: const Icon(Icons.cancel),
              label: const Text('Cancel Order'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        if (invoice.canCancel && invoice.canReorder)
          const SizedBox(height: 12),
        if (invoice.canReorder)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => controller.reorderInvoice(invoice.id),
              icon: const Icon(Icons.replay),
              label: const Text('Reorder'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        if (invoice.canReturn) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Get.toNamed('/return-request/${invoice.id}'),
              icon: const Icon(Icons.assignment_return),
              label: const Text('Request Return'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'pending':
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        break;
      case 'processing':
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[800]!;
        break;
      case 'shipped':
        backgroundColor = Colors.purple[100]!;
        textColor = Colors.purple[800]!;
        break;
      case 'delivered':
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        break;
      case 'cancelled':
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        break;
      default:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status.capitalize!,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
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
            'Order not found',
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

  void _handleMenuAction(String action) {
    final invoice = controller.selectedInvoice.value;
    if (invoice == null) return;

    switch (action) {
      case 'download':
        controller.downloadInvoicePdf(invoice.id);
        break;
      case 'share':
        controller.shareInvoice(invoice);
        break;
      case 'support':
        Get.toNamed('/support', arguments: {'orderId': invoice.id});
        break;
    }
  }

  void _showCancelDialog(BuildContext context, ProformaInvoiceModel invoice) {
    Get.dialog(
      AlertDialog(
        title: const Text('Cancel Order'),
        content: Text(
            'Are you sure you want to cancel order #${invoice.invoiceNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              controller.cancelInvoice(invoice.id);
              Get.back();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}
