import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/models.dart';

/// API Response wrapper
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final Map<String, dynamic>? meta;
  final Map<String, List<String>>? errors;
  final int statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.meta,
    this.errors,
    required this.statusCode,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
    int statusCode,
  ) {
    return ApiResponse(
      success: json['success'] ?? (statusCode >= 200 && statusCode < 300),
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'],
      message: json['message'],
      meta: json['meta'],
      errors: json['errors'] != null
          ? (json['errors'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(
                key,
                (value as List).map((e) => e.toString()).toList(),
              ),
            )
          : null,
      statusCode: statusCode,
    );
  }

  /// Get first error message
  String? get firstError {
    if (errors == null || errors!.isEmpty) return message;
    final firstKey = errors!.keys.first;
    return errors![firstKey]?.first ?? message;
  }

  /// Check if has validation errors
  bool get hasValidationErrors => errors != null && errors!.isNotEmpty;
}

/// Paginated Response
class PaginatedResponse<T> {
  final List<T> data;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final String? nextPageUrl;
  final String? prevPageUrl;

  PaginatedResponse({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final dataList = json['data'] as List? ?? [];
    final meta = json['meta'] ?? json;

    return PaginatedResponse(
      data: dataList.map((e) => fromJsonT(e as Map<String, dynamic>)).toList(),
      currentPage: meta['current_page'] ?? 1,
      lastPage: meta['last_page'] ?? 1,
      perPage: meta['per_page'] ?? dataList.length,
      total: meta['total'] ?? dataList.length,
      nextPageUrl: meta['next_page_url'],
      prevPageUrl: meta['prev_page_url'],
    );
  }

  bool get hasNextPage => currentPage < lastPage;
  bool get hasPrevPage => currentPage > 1;
  bool get isEmpty => data.isEmpty;
  bool get isNotEmpty => data.isNotEmpty;
}

/// API Exception
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, List<String>>? errors;
  final dynamic originalError;

  ApiException({
    required this.message,
    this.statusCode,
    this.errors,
    this.originalError,
  });

  @override
  String toString() => message;

  /// Check if unauthorized
  bool get isUnauthorized => statusCode == 401;

  /// Check if forbidden
  bool get isForbidden => statusCode == 403;

  /// Check if not found
  bool get isNotFound => statusCode == 404;

  /// Check if validation error
  bool get isValidationError => statusCode == 422;

  /// Check if server error
  bool get isServerError => statusCode != null && statusCode! >= 500;

  /// Check if network error
  bool get isNetworkError => statusCode == null;
}

/// API Provider - Base HTTP client for all API calls
class ApiProvider {
  final String baseUrl;
  final http.Client _client;
  String? _authToken;
  final Duration timeout;
  final Map<String, String> _defaultHeaders;

  ApiProvider({
    required this.baseUrl,
    http.Client? client,
    this.timeout = const Duration(seconds: 30),
    Map<String, String>? defaultHeaders,
  })  : _client = client ?? http.Client(),
        _defaultHeaders = defaultHeaders ?? {};

  /// Set auth token
  void setAuthToken(String? token) {
    _authToken = token;
  }

  /// Get auth token
  String? get authToken => _authToken;

  /// Check if authenticated
  bool get isAuthenticated => _authToken != null && _authToken!.isNotEmpty;

  /// Get headers
  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ..._defaultHeaders,
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  /// Build URL with query parameters
  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParams]) {
    final uri = Uri.parse('$baseUrl$endpoint');
    if (queryParams == null || queryParams.isEmpty) return uri;

    final filteredParams = <String, String>{};
    queryParams.forEach((key, value) {
      if (value != null) {
        filteredParams[key] = value.toString();
      }
    });

    return uri.replace(queryParameters: filteredParams);
  }

  /// Handle response
  Future<ApiResponse<T>> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJsonT,
  ) async {
    try {
      final body = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};

      return ApiResponse.fromJson(body, fromJsonT, response.statusCode);
    } catch (e) {
      throw ApiException(
        message: 'Failed to parse response',
        statusCode: response.statusCode,
        originalError: e,
      );
    }
  }

  /// Handle errors
  ApiException _handleError(dynamic error) {
    if (error is ApiException) return error;

    if (error is SocketException) {
      return ApiException(
        message: 'No internet connection',
        originalError: error,
      );
    }

    if (error is http.ClientException) {
      return ApiException(
        message: 'Network error occurred',
        originalError: error,
      );
    }

    return ApiException(
      message: error.toString(),
      originalError: error,
    );
  }

  /// GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    T Function(dynamic)? fromJsonT,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final response = await _client
          .get(uri, headers: _headers)
          .timeout(timeout);

      if (response.statusCode == 401) {
        throw ApiException(
          message: 'Unauthorized',
          statusCode: 401,
        );
      }

      return _handleResponse(response, fromJsonT);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParams,
    T Function(dynamic)? fromJsonT,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final response = await _client
          .post(
            uri,
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout);

      if (response.statusCode == 401) {
        throw ApiException(
          message: 'Unauthorized',
          statusCode: 401,
        );
      }

      return _handleResponse(response, fromJsonT);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParams,
    T Function(dynamic)? fromJsonT,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final response = await _client
          .put(
            uri,
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout);

      if (response.statusCode == 401) {
        throw ApiException(
          message: 'Unauthorized',
          statusCode: 401,
        );
      }

      return _handleResponse(response, fromJsonT);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PATCH request
  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParams,
    T Function(dynamic)? fromJsonT,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final response = await _client
          .patch(
            uri,
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout);

      if (response.statusCode == 401) {
        throw ApiException(
          message: 'Unauthorized',
          statusCode: 401,
        );
      }

      return _handleResponse(response, fromJsonT);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParams,
    T Function(dynamic)? fromJsonT,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final request = http.Request('DELETE', uri);
      request.headers.addAll(_headers);
      if (body != null) {
        request.body = jsonEncode(body);
      }

      final streamedResponse = await _client.send(request).timeout(timeout);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 401) {
        throw ApiException(
          message: 'Unauthorized',
          statusCode: 401,
        );
      }

      return _handleResponse(response, fromJsonT);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Multipart POST (for file uploads)
  Future<ApiResponse<T>> uploadFile<T>(
    String endpoint, {
    required String filePath,
    required String fileField,
    Map<String, String>? fields,
    T Function(dynamic)? fromJsonT,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final request = http.MultipartRequest('POST', uri);

      request.headers.addAll(_headers);
      request.headers.remove('Content-Type'); // Let multipart set this

      if (fields != null) {
        request.fields.addAll(fields);
      }

      request.files.add(await http.MultipartFile.fromPath(fileField, filePath));

      final streamedResponse = await _client.send(request).timeout(timeout);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 401) {
        throw ApiException(
          message: 'Unauthorized',
          statusCode: 401,
        );
      }

      return _handleResponse(response, fromJsonT);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get paginated data
  Future<PaginatedResponse<T>> getPaginated<T>(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    required T Function(Map<String, dynamic>) fromJsonT,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final response = await _client
          .get(uri, headers: _headers)
          .timeout(timeout);

      if (response.statusCode == 401) {
        throw ApiException(
          message: 'Unauthorized',
          statusCode: 401,
        );
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return PaginatedResponse.fromJson(body, fromJsonT);
      }

      throw ApiException(
        message: 'Failed to fetch data',
        statusCode: response.statusCode,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Dispose client
  void dispose() {
    _client.close();
  }
}
