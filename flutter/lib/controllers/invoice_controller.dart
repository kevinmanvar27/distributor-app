import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/data.dart';

/// Invoice Controller
/// Manages proforma invoices, orders, and checkout
class InvoiceController extends GetxController {
  final InvoiceRepository _invoiceRepository;

  InvoiceController({
    InvoiceRepository? invoiceRepository,
  }) : _invoiceRepository = invoiceRepository ?? InvoiceRepository(Get.find());

  // Observable state - Invoices
  final RxList<ProformaInvoiceModel> invoices = <ProformaInvoiceModel>[].obs;
  final RxList<ProformaInvoiceModel> recentInvoices = <ProformaInvoiceModel>[].obs;
  final Rx<ProformaInvoiceModel?> selectedInvoice = Rx<ProformaInvoiceModel?>(null);
  
  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isLoadingDetails = false.obs;
  final RxBool isCreating = false.obs;
  final RxBool isUpdating = false.obs;
  
  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxInt totalInvoices = 0.obs;
  final RxBool hasMore = true.obs;
  
  // Filter
  final Rx<InvoiceFilter> currentFilter = InvoiceFilter().obs;
  final Rx<InvoiceStatus?> statusFilter = Rx<InvoiceStatus?>(null);
  final RxString searchQuery = ''.obs;
  
  // Statistics
  final RxMap<String, dynamic> statistics = <String, dynamic>{}.obs;
  
  final RxString errorMessage = ''.obs;

  // Getters
  int get invoiceCount => invoices.length;
  bool get isEmpty => invoices.isEmpty;
  
  List<ProformaInvoiceModel> get pendingInvoices =>
      invoices.where((i) => i.status == InvoiceStatus.pending).toList();
  
  List<ProformaInvoiceModel> get approvedInvoices =>
      invoices.where((i) => i.status == InvoiceStatus.approved).toList();
  
  List<ProformaInvoiceModel> get completedInvoices =>
      invoices.where((i) => i.status == InvoiceStatus.completed).toList();

  @override
  void onInit() {
    super.onInit();
    loadInvoices();
    loadStatistics();
  }

  /// Load invoices with current filter
  Future<void> loadInvoices({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      hasMore.value = true;
      invoices.clear();
    }

    if (!hasMore.value && !refresh) return;

    isLoading.value = refresh || invoices.isEmpty;
    isLoadingMore.value = !refresh && invoices.isNotEmpty;
    errorMessage.value = '';

    try {
      final filter = currentFilter.value.copyWith(
        status: statusFilter.value,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
      );

      final response = await _invoiceRepository.getInvoices(
        page: currentPage.value,
        perPage: 20,
        filter: filter,
      );

      if (refresh) {
        invoices.value = response.data;
      } else {
        invoices.addAll(response.data);
      }

      currentPage.value = response.currentPage;
      totalPages.value = response.lastPage;
      totalInvoices.value = response.total;
      hasMore.value = response.hasNextPage;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      _showError(e.message);
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  /// Load more invoices (pagination)
  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;
    currentPage.value++;
    await loadInvoices();
  }

  /// Load recent invoices
  Future<void> loadRecentInvoices() async {
    try {
      final response = await _invoiceRepository.getRecentInvoices(limit: 5);
      recentInvoices.value = response;
    } on ApiException catch (e) {
      // Silently fail
    }
  }

  /// Load invoice details
  Future<ProformaInvoiceModel?> loadInvoiceDetails(int invoiceId) async {
    isLoadingDetails.value = true;

    try {
      final invoice = await _invoiceRepository.getInvoiceById(invoiceId);
      selectedInvoice.value = invoice;
      return invoice;
    } on ApiException catch (e) {
      _showError(e.message);
      return null;
    } finally {
      isLoadingDetails.value = false;
    }
  }

  /// Create invoice from cart
  Future<ProformaInvoiceModel?> createFromCart({
    String? notes,
    String? shippingAddress,
    String? billingAddress,
  }) async {
    isCreating.value = true;

    try {
      final invoice = await _invoiceRepository.createFromCart(
        notes: notes,
        shippingAddress: shippingAddress,
        billingAddress: billingAddress,
      );

      // Add to list
      invoices.insert(0, invoice);
      
      // Clear cart
      final cartController = Get.find<CartController>();
      await cartController.loadCart();

      Get.snackbar(
        'Order Placed',
        'Your proforma invoice #${invoice.invoiceNumber} has been created',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        duration: const Duration(seconds: 5),
        mainButton: TextButton(
          onPressed: () => Get.toNamed('/invoice/${invoice.id}'),
          child: const Text('View'),
        ),
      );

      return invoice;
    } on ApiException catch (e) {
      _showError(e.message);
      return null;
    } finally {
      isCreating.value = false;
    }
  }

  /// Create invoice with custom items
  Future<ProformaInvoiceModel?> createWithItems({
    required List<Map<String, dynamic>> items,
    String? notes,
    String? shippingAddress,
    String? billingAddress,
  }) async {
    isCreating.value = true;

    try {
      final invoice = await _invoiceRepository.createWithItems(
        items: items,
        notes: notes,
        shippingAddress: shippingAddress,
        billingAddress: billingAddress,
      );

      invoices.insert(0, invoice);

      Get.snackbar(
        'Order Placed',
        'Your proforma invoice #${invoice.invoiceNumber} has been created',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );

      return invoice;
    } on ApiException catch (e) {
      _showError(e.message);
      return null;
    } finally {
      isCreating.value = false;
    }
  }

  /// Update invoice
  Future<bool> updateInvoice(int invoiceId, {
    String? notes,
    String? shippingAddress,
    String? billingAddress,
  }) async {
    isUpdating.value = true;

    try {
      final invoice = await _invoiceRepository.updateInvoice(
        invoiceId,
        notes: notes,
        shippingAddress: shippingAddress,
        billingAddress: billingAddress,
      );

      // Update in list
      final index = invoices.indexWhere((i) => i.id == invoiceId);
      if (index != -1) {
        invoices[index] = invoice;
      }
      
      if (selectedInvoice.value?.id == invoiceId) {
        selectedInvoice.value = invoice;
      }

      Get.snackbar(
        'Updated',
        'Invoice has been updated',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );

      return true;
    } on ApiException catch (e) {
      _showError(e.message);
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  /// Cancel invoice
  Future<bool> cancelInvoice(int invoiceId, {String? reason}) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this order? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cancel Order'),
          ),
        ],
      ),
    );

    if (confirmed != true) return false;

    isUpdating.value = true;

    try {
      final invoice = await _invoiceRepository.cancelInvoice(invoiceId, reason: reason);

      // Update in list
      final index = invoices.indexWhere((i) => i.id == invoiceId);
      if (index != -1) {
        invoices[index] = invoice;
      }
      
      if (selectedInvoice.value?.id == invoiceId) {
        selectedInvoice.value = invoice;
      }

      Get.snackbar(
        'Cancelled',
        'Order has been cancelled',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
      );

      return true;
    } on ApiException catch (e) {
      _showError(e.message);
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  /// Request return
  Future<bool> requestReturn(int invoiceId, {
    required String reason,
    List<int>? itemIds,
  }) async {
    isUpdating.value = true;

    try {
      await _invoiceRepository.requestReturn(
        invoiceId,
        reason: reason,
        itemIds: itemIds,
      );

      Get.snackbar(
        'Return Requested',
        'Your return request has been submitted',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );

      // Reload invoice
      await loadInvoiceDetails(invoiceId);

      return true;
    } on ApiException catch (e) {
      _showError(e.message);
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  /// Reorder (create new invoice from existing)
  Future<ProformaInvoiceModel?> reorder(int invoiceId) async {
    isCreating.value = true;

    try {
      final invoice = await _invoiceRepository.reorder(invoiceId);

      invoices.insert(0, invoice);

      Get.snackbar(
        'Reordered',
        'New order #${invoice.invoiceNumber} has been created',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        mainButton: TextButton(
          onPressed: () => Get.toNamed('/invoice/${invoice.id}'),
          child: const Text('View'),
        ),
      );

      return invoice;
    } on ApiException catch (e) {
      _showError(e.message);
      return null;
    } finally {
      isCreating.value = false;
    }
  }

  /// Download invoice PDF
  Future<String?> downloadPdf(int invoiceId) async {
    try {
      final filePath = await _invoiceRepository.downloadPdf(invoiceId);

      Get.snackbar(
        'Downloaded',
        'Invoice PDF has been downloaded',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );

      return filePath;
    } on ApiException catch (e) {
      _showError(e.message);
      return null;
    }
  }

  /// View invoice PDF
  Future<String?> viewPdf(int invoiceId) async {
    try {
      return await _invoiceRepository.viewPdf(invoiceId);
    } on ApiException catch (e) {
      _showError(e.message);
      return null;
    }
  }

  /// Get invoice timeline/history
  Future<List<Map<String, dynamic>>> getTimeline(int invoiceId) async {
    try {
      return await _invoiceRepository.getInvoiceTimeline(invoiceId);
    } on ApiException catch (e) {
      _showError(e.message);
      return [];
    }
  }

  /// Load statistics
  Future<void> loadStatistics() async {
    try {
      final stats = await _invoiceRepository.getStatistics();
      statistics.value = stats;
    } catch (e) {
      // Silently fail
    }
  }

  /// Update invoice notes
  Future<bool> updateNotes(int invoiceId, String notes) async {
    try {
      await _invoiceRepository.updateNotes(invoiceId, notes);
      
      // Update local
      final index = invoices.indexWhere((i) => i.id == invoiceId);
      if (index != -1) {
        // Reload to get updated data
        await loadInvoiceDetails(invoiceId);
      }

      return true;
    } on ApiException catch (e) {
      _showError(e.message);
      return false;
    }
  }

  /// Filter by status
  void filterByStatus(InvoiceStatus? status) {
    statusFilter.value = status;
    loadInvoices(refresh: true);
  }

  /// Search invoices
  void search(String query) {
    searchQuery.value = query;
    loadInvoices(refresh: true);
  }

  /// Clear search
  void clearSearch() {
    searchQuery.value = '';
    loadInvoices(refresh: true);
  }

  /// Set sort option
  void setSortOption(String sortBy, String sortOrder) {
    currentFilter.value = currentFilter.value.copyWith(
      sortBy: sortBy,
      sortOrder: sortOrder,
    );
    loadInvoices(refresh: true);
  }

  /// Clear all filters
  void clearFilters() {
    statusFilter.value = null;
    searchQuery.value = '';
    currentFilter.value = InvoiceFilter();
    loadInvoices(refresh: true);
  }

  /// Get invoice by ID from local list
  ProformaInvoiceModel? getInvoiceById(int id) {
    return invoices.firstWhereOrNull((i) => i.id == id);
  }

  /// Refresh all data
  Future<void> refreshAll() async {
    await Future.wait([
      loadInvoices(refresh: true),
      loadRecentInvoices(),
      loadStatistics(),
    ]);
  }

  /// Show error snackbar
  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade900,
      duration: const Duration(seconds: 3),
    );
  }
}

/// Invoice Filter Extension for copyWith
/// Uses wrapper objects to distinguish between "not provided" and "explicitly set to null"
extension InvoiceFilterCopyWith on InvoiceFilter {
  InvoiceFilter copyWith({
    Object? status = _sentinel,
    Object? search = _sentinel,
    Object? startDate = _sentinel,
    Object? endDate = _sentinel,
    Object? minAmount = _sentinel,
    Object? maxAmount = _sentinel,
    Object? sortBy = _sentinel,
    Object? sortOrder = _sentinel,
  }) {
    return InvoiceFilter(
      status: status == _sentinel ? this.status : status as InvoiceStatus?,
      search: search == _sentinel ? this.search : search as String?,
      startDate: startDate == _sentinel ? this.startDate : startDate as DateTime?,
      endDate: endDate == _sentinel ? this.endDate : endDate as DateTime?,
      minAmount: minAmount == _sentinel ? this.minAmount : minAmount as double?,
      maxAmount: maxAmount == _sentinel ? this.maxAmount : maxAmount as double?,
      sortBy: sortBy == _sentinel ? this.sortBy : sortBy as String?,
      sortOrder: sortOrder == _sentinel ? this.sortOrder : sortOrder as String?,
    );
  }
}

/// Sentinel value to distinguish between "not provided" and "explicitly set to null"
const _sentinel = Object();
