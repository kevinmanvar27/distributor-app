import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;

import '../constants/api_endpoints.dart';
import '../constants/app_constants.dart';
import 'storage_service.dart';

/// Dio HTTP Client with interceptors for authentication and error handling
class DioClient extends GetxService {
  late Dio _dio;
  final StorageService _storage = Get.find<StorageService>();

  Dio get dio => _dio;

  /// Initialize the Dio client
  Future<DioClient> init() async {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.apiBaseUrl,
        connectTimeout: const Duration(milliseconds: AppConstants.connectionTimeout),
        receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(_authInterceptor());
    _dio.interceptors.add(_loggingInterceptor());
    _dio.interceptors.add(_errorInterceptor());

    return this;
  }

  /// Auth interceptor to add token to requests
  InterceptorsWrapper _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Get token from storage
        final token = await _storage.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    );
  }

  /// Logging interceptor for debugging
  InterceptorsWrapper _loggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        debugPrint('┌─────────────────────────────────────────────────────────────');
        debugPrint('│ REQUEST: ${options.method} ${options.uri}');
        debugPrint('│ Headers: ${options.headers}');
        if (options.data != null) {
          debugPrint('│ Body: ${options.data}');
        }
        debugPrint('└─────────────────────────────────────────────────────────────');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint('┌─────────────────────────────────────────────────────────────');
        debugPrint('│ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
        debugPrint('│ Data: ${response.data}');
        debugPrint('└─────────────────────────────────────────────────────────────');
        return handler.next(response);
      },
      onError: (error, handler) {
        debugPrint('┌─────────────────────────────────────────────────────────────');
        debugPrint('│ ERROR: ${error.response?.statusCode} ${error.requestOptions.uri}');
        debugPrint('│ Message: ${error.message}');
        debugPrint('│ Response: ${error.response?.data}');
        debugPrint('└─────────────────────────────────────────────────────────────');
        return handler.next(error);
      },
    );
  }

  /// Error interceptor for handling common errors
  InterceptorsWrapper _errorInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) async {
        // Handle 401 Unauthorized - Token expired
        if (error.response?.statusCode == 401) {
          // Clear auth data and redirect to login
          await _storage.clearAuthData();
          Get.offAllNamed('/login');
          return handler.reject(error);
        }
        return handler.next(error);
      },
    );
  }

  // ==================== HTTP Methods ====================

  /// GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Upload file with multipart form data
  Future<Response> uploadFile(
    String path, {
    required String filePath,
    required String fieldName,
    Map<String, dynamic>? additionalData,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
  }) async {
    final formData = FormData.fromMap({
      fieldName: await MultipartFile.fromFile(filePath),
      if (additionalData != null) ...additionalData,
    });

    return await _dio.post(
      path,
      data: formData,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      ),
    );
  }

  /// Download file
  Future<Response> downloadFile(
    String path,
    String savePath, {
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) async {
    return await _dio.download(
      path,
      savePath,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }
}

/// API Response wrapper for consistent error handling
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final Map<String, dynamic>? errors;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.errors,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic)? fromJson) {
    return ApiResponse(
      success: json['success'] ?? false,
      data: json['data'] != null && fromJson != null ? fromJson(json['data']) : json['data'],
      message: json['message'],
      errors: json['errors'],
    );
  }

  factory ApiResponse.error(String message) {
    return ApiResponse(
      success: false,
      message: message,
    );
  }
}

/// Exception class for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ApiException({
    required this.message,
    this.statusCode,
    this.errors,
  });

  @override
  String toString() => message;

  /// Create from DioException
  factory ApiException.fromDioException(DioException e) {
    String message;
    int? statusCode = e.response?.statusCode;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timeout. Please try again.';
        break;
      case DioExceptionType.connectionError:
        message = 'No internet connection. Please check your network.';
        break;
      case DioExceptionType.badResponse:
        final responseData = e.response?.data;
        if (responseData is Map<String, dynamic>) {
          message = responseData['message'] ?? 'Server error occurred.';
          return ApiException(
            message: message,
            statusCode: statusCode,
            errors: responseData['errors'],
          );
        }
        message = _getStatusMessage(statusCode);
        break;
      case DioExceptionType.cancel:
        message = 'Request was cancelled.';
        break;
      default:
        message = 'Something went wrong. Please try again.';
    }

    return ApiException(message: message, statusCode: statusCode);
  }

  static String _getStatusMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return 'Session expired. Please login again.';
      case 403:
        return 'You do not have permission to perform this action.';
      case 404:
        return 'Resource not found.';
      case 422:
        return 'Validation error. Please check your input.';
      case 500:
        return 'Server error. Please try again later.';
      case 502:
        return 'Bad gateway. Please try again later.';
      case 503:
        return 'Service unavailable. Please try again later.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
