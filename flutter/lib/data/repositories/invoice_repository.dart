import '../providers/api_provider.dart';
import '../models/models.dart';

/// Invoice Filter Options
class InvoiceFilter {
  final InvoiceStatus? status;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? sortBy;
  final String? sortOrder;

  InvoiceFilter({
    this.status,
    this.fromDate,
    this.toDate,
    this.sortBy,
    this.sortOrder,
  });

  Map<String, dynamic> toQueryParams() {
    return {
      if (status != null) 'status': status!.value,
      if (fromDate != null) 'from_date': fromDate!.toIso8601String().split('T')[0],
      if (toDate != null) 'to_date': toDate!.toIso8601String().split('T')[0],
      if (sortBy != null) 'sort_by': sortBy,
      if (sortOrder != null) 'sort_order': sortOrder,
    };
  }
}

/// Invoice Repository - Handles proforma invoice API calls
class InvoiceRepository {
  final ApiProvider _api;

  InvoiceRepository(this._api);

  /// Get all invoices with pagination
  Future<PaginatedResponse<ProformaInvoiceModel>> getInvoices({
    int page = 1,
    int perPage = 20,
    InvoiceFilter? filter,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
      ...?filter?.toQueryParams(),
    };

    return _api.getPaginated<ProformaInvoiceModel>(
      '/api/v1/proforma-invoices',
      queryParams: queryParams,
      fromJsonT: (json) => ProformaInvoiceModel.fromJson(json),
    );
  }

  /// Get single invoice by ID
  Future<ProformaInvoiceModel> getInvoice(int id) async {
    final response = await _api.get<Map<String, dynamic>>(
      '/api/v1/proforma-invoices/$id',
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        message: response.message ?? 'Invoice not found',
        statusCode: response.statusCode,
      );
    }

    return ProformaInvoiceModel.fromJson(response.data!);
  }

  /// Get invoice by number
  Future<ProformaInvoiceModel> getInvoiceByNumber(String invoiceNumber) async {
    final response = await _api.get<Map<String, dynamic>>(
      '/api/v1/proforma-invoices/number/$invoiceNumber',
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        message: response.message ?? 'Invoice not found',
        statusCode: response.statusCode,
      );
    }

    return ProformaInvoiceModel.fromJson(response.data!);
  }

  /// Create invoice from cart
  Future<ProformaInvoiceModel> createFromCart({
    String? notes,
    String? shippingAddress,
    String? billingAddress,
  }) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/api/v1/proforma-invoices/create-from-cart',
      body: {
        if (notes != null) 'notes': notes,
        if (shippingAddress != null) 'shipping_address': shippingAddress,
        if (billingAddress != null) 'billing_address': billingAddress,
      },
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        message: response.message ?? 'Failed to create invoice',
        statusCode: response.statusCode,
        errors: response.errors,
      );
    }

    return ProformaInvoiceModel.fromJson(response.data!);
  }

  /// Create invoice with items
  Future<ProformaInvoiceModel> createInvoice({
    required List<Map<String, dynamic>> items,
    String? notes,
    String? shippingAddress,
    String? billingAddress,
  }) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/api/v1/proforma-invoices',
      body: {
        'items': items,
        if (notes != null) 'notes': notes,
        if (shippingAddress != null) 'shipping_address': shippingAddress,
        if (billingAddress != null) 'billing_address': billingAddress,
      },
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        message: response.message ?? 'Failed to create invoice',
        statusCode: response.statusCode,
        errors: response.errors,
      );
    }

    return ProformaInvoiceModel.fromJson(response.data!);
  }

  /// Update invoice
  Future<ProformaInvoiceModel> updateInvoice(
    int id, {
    List<Map<String, dynamic>>? items,
    String? notes,
    String? shippingAddress,
    String? billingAddress,
  }) async {
    final body = <String, dynamic>{};
    if (items != null) body['items'] = items;
    if (notes != null) body['notes'] = notes;
    if (shippingAddress != null) body['shipping_address'] = shippingAddress;
    if (billingAddress != null) body['billing_address'] = billingAddress;

    final response = await _api.put<Map<String, dynamic>>(
      '/api/v1/proforma-invoices/$id',
      body: body,
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        message: response.message ?? 'Failed to update invoice',
        statusCode: response.statusCode,
        errors: response.errors,
      );
    }

    return ProformaInvoiceModel.fromJson(response.data!);
  }

  /// Cancel invoice
  Future<ProformaInvoiceModel> cancelInvoice(int id, {String? reason}) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/api/v1/proforma-invoices/$id/cancel',
      body: {
        if (reason != null) 'reason': reason,
      },
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        message: response.message ?? 'Failed to cancel invoice',
        statusCode: response.statusCode,
      );
    }

    return ProformaInvoiceModel.fromJson(response.data!);
  }

  /// Request return for invoice
  Future<ProformaInvoiceModel> requestReturn(int id, {
    required String reason,
    List<Map<String, dynamic>>? items,
  }) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/api/v1/proforma-invoices/$id/return',
      body: {
        'reason': reason,
        if (items != null) 'items': items,
      },
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        message: response.message ?? 'Failed to request return',
        statusCode: response.statusCode,
        errors: response.errors,
      );
    }

    return ProformaInvoiceModel.fromJson(response.data!);
  }

  /// Get invoice PDF URL
  Future<String> getInvoicePdfUrl(int id) async {
    final response = await _api.get<Map<String, dynamic>>(
      '/api/v1/proforma-invoices/$id/pdf',
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        message: response.message ?? 'Failed to get PDF URL',
        statusCode: response.statusCode,
      );
    }

    return response.data!['url'] ?? response.data!['pdf_url'] ?? '';
  }

  /// Download invoice PDF
  Future<String> downloadInvoicePdf(int id) async {
    final response = await _api.get<Map<String, dynamic>>(
      '/api/v1/proforma-invoices/$id/download',
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        message: response.message ?? 'Failed to download PDF',
        statusCode: response.statusCode,
      );
    }

    return response.data!['download_url'] ?? '';
  }

  /// Get recent invoices
  Future<List<ProformaInvoiceModel>> getRecentInvoices({int limit = 5}) async {
    final response = await _api.get<List<dynamic>>(
      '/api/v1/proforma-invoices/recent',
      queryParams: {'limit': limit},
      fromJsonT: (data) => data as List<dynamic>,
    );

    if (!response.success || response.data == null) {
      return [];
    }

    return response.data!
        .map((e) => ProformaInvoiceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get invoice statistics
  Future<Map<String, dynamic>> getInvoiceStats() async {
    final response = await _api.get<Map<String, dynamic>>(
      '/api/v1/proforma-invoices/stats',
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      return {};
    }

    return response.data!;
  }

  /// Search invoices
  Future<PaginatedResponse<ProformaInvoiceModel>> searchInvoices({
    required String query,
    int page = 1,
    int perPage = 20,
  }) async {
    return _api.getPaginated<ProformaInvoiceModel>(
      '/api/v1/proforma-invoices/search',
      queryParams: {
        'q': query,
        'page': page,
        'per_page': perPage,
      },
      fromJsonT: (json) => ProformaInvoiceModel.fromJson(json),
    );
  }

  /// Reorder from invoice (add all items to cart)
  Future<Map<String, dynamic>> reorderFromInvoice(int id) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/api/v1/proforma-invoices/$id/reorder',
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        message: response.message ?? 'Failed to reorder',
        statusCode: response.statusCode,
      );
    }

    return response.data!;
  }

  /// Get invoices by status
  Future<PaginatedResponse<ProformaInvoiceModel>> getInvoicesByStatus(
    InvoiceStatus status, {
    int page = 1,
    int perPage = 20,
  }) async {
    return _api.getPaginated<ProformaInvoiceModel>(
      '/api/v1/proforma-invoices/status/${status.value}',
      queryParams: {'page': page, 'per_page': perPage},
      fromJsonT: (json) => ProformaInvoiceModel.fromJson(json),
    );
  }

  /// Get pending invoices count
  Future<int> getPendingCount() async {
    final response = await _api.get<Map<String, dynamic>>(
      '/api/v1/proforma-invoices/pending-count',
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      return 0;
    }

    return response.data!['count'] ?? 0;
  }

  /// Add note to invoice
  Future<ProformaInvoiceModel> addNote(int id, String note) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/api/v1/proforma-invoices/$id/notes',
      body: {'note': note},
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        message: response.message ?? 'Failed to add note',
        statusCode: response.statusCode,
      );
    }

    return ProformaInvoiceModel.fromJson(response.data!);
  }

  /// Get invoice timeline/history
  Future<List<Map<String, dynamic>>> getInvoiceTimeline(int id) async {
    final response = await _api.get<List<dynamic>>(
      '/api/v1/proforma-invoices/$id/timeline',
      fromJsonT: (data) => data as List<dynamic>,
    );

    if (!response.success || response.data == null) {
      return [];
    }

    return response.data!.map((e) => e as Map<String, dynamic>).toList();
  }
}
