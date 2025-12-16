import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/controllers.dart';
import '../../../data/data.dart';

/// Orders Screen
/// List of all orders with filtering and search
class OrdersScreen extends GetView<InvoiceController> {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Status filter tabs
          _buildStatusTabs(context),

          // Orders list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.invoices.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.invoices.isEmpty) {
                return _buildEmptyState(context);
              }

              return RefreshIndicator(
                onRefresh: controller.refreshInvoices,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.invoices.length +
                      (controller.hasMorePages ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= controller.invoices.length) {
                      controller.loadMoreInvoices();
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final invoice = controller.invoices[index];
                    return _buildOrderCard(context, invoice);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTabs(BuildContext context) {
    final statuses = [
      {'label': 'All', 'value': null},
      {'label': 'Pending', 'value': 'pending'},
      {'label': 'Processing', 'value': 'processing'},
      {'label': 'Shipped', 'value': 'shipped'},
      {'label': 'Delivered', 'value': 'delivered'},
      {'label': 'Cancelled', 'value': 'cancelled'},
    ];

    return Container(
      height: 50,
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
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: statuses.length,
        itemBuilder: (context, index) {
          final status = statuses[index];
          return Obx(() {
            final isSelected =
                controller.selectedStatus.value == status['value'];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(status['label'] as String),
                selected: isSelected,
                onSelected: (_) =>
                    controller.filterByStatus(status['value'] as String?),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, ProformaInvoiceModel invoice) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => controller.navigateToInvoiceDetail(invoice),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${invoice.invoiceNumber}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  _buildStatusBadge(invoice.status),
                ],
              ),
              const SizedBox(height: 8),

              // Date
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    invoice.formattedDate,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Items preview
              if (invoice.items.isNotEmpty) ...[
                Row(
                  children: [
                    // Product images
                    ...invoice.items.take(3).map((item) => Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              item.product?.thumbnail ??
                                  'https://via.placeholder.com/40',
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 40,
                                height: 40,
                                color: Colors.grey[200],
                                child: const Icon(Icons.image, size: 20),
                              ),
                            ),
                          ),
                        )),
                    if (invoice.items.length > 3)
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(
                            '+${invoice.items.length - 3}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${invoice.items.length} item${invoice.items.length > 1 ? 's' : ''}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Text(
                    '\$${invoice.totalAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),

              // Actions
              if (invoice.canCancel || invoice.canReorder) ...[
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (invoice.canCancel)
                      TextButton(
                        onPressed: () => _showCancelDialog(context, invoice),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Cancel'),
                      ),
                    if (invoice.canReorder)
                      TextButton(
                        onPressed: () => controller.reorderInvoice(invoice.id),
                        child: const Text('Reorder'),
                      ),
                    TextButton.icon(
                      onPressed: () =>
                          controller.navigateToInvoiceDetail(invoice),
                      icon: const Icon(Icons.arrow_forward, size: 16),
                      label: const Text('View Details'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.capitalize!,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'No orders yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your order history will appear here',
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Get.toNamed('/products'),
            icon: const Icon(Icons.shopping_bag),
            label: const Text('Start Shopping'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Search Orders'),
        content: TextField(
          controller: controller.searchController,
          decoration: const InputDecoration(
            hintText: 'Enter order number...',
            prefixIcon: Icon(Icons.search),
          ),
          onSubmitted: (value) {
            controller.searchInvoices(value);
            Get.back();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.searchInvoices(controller.searchController.text);
              Get.back();
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
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
