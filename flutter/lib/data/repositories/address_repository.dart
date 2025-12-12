import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../providers/api_provider.dart';
import '../../core/constants/api_endpoints.dart';

/// Address Repository
/// Handles all address-related API calls
class AddressRepository {
  final ApiProvider _api;

  AddressRepository(this._api);

  /// Get all addresses for the current user
  Future<List<AddressModel>> getAddresses() async {
    final response = await _api.get<List<dynamic>>(
      ApiEndpoints.addresses,
      fromJsonT: (data) => data as List<dynamic>,
    );

    if (!response.success || response.data == null) {
      return [];
    }

    return response.data!
        .map((json) => AddressModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get a single address by ID
  Future<AddressModel?> getAddress(int id) async {
    final response = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.addressById(id),
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      return null;
    }

    return AddressModel.fromJson(response.data!);
  }

  /// Create a new address
  Future<AddressModel> createAddress(AddressModel address) async {
    final response = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.addresses,
      body: address.toJson(),
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        message: response.message ?? 'Failed to create address',
        statusCode: response.statusCode,
      );
    }

    return AddressModel.fromJson(response.data!);
  }

  /// Update an existing address
  Future<AddressModel> updateAddress(int id, AddressModel address) async {
    final response = await _api.put<Map<String, dynamic>>(
      ApiEndpoints.addressById(id),
      body: address.toJson(),
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        message: response.message ?? 'Failed to update address',
        statusCode: response.statusCode,
      );
    }

    return AddressModel.fromJson(response.data!);
  }

  /// Delete an address
  Future<void> deleteAddress(int id) async {
    final response = await _api.delete<void>(
      ApiEndpoints.addressById(id),
      fromJsonT: (_) {},
    );

    if (!response.success) {
      throw ApiException(
        message: response.message ?? 'Failed to delete address',
        statusCode: response.statusCode,
      );
    }
  }

  /// Set an address as default
  Future<AddressModel> setDefaultAddress(int id) async {
    final response = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.addressSetDefault(id),
      fromJsonT: (data) => data as Map<String, dynamic>,
    );

    if (!response.success || response.data == null) {
      throw ApiException(
        message: response.message ?? 'Failed to set default address',
        statusCode: response.statusCode,
      );
    }

    return AddressModel.fromJson(response.data!);
  }

  /// Get the default address
  Future<AddressModel?> getDefaultAddress() async {
    try {
      final addresses = await getAddresses();
      return addresses.firstWhere(
        (a) => a.isDefault,
        orElse: () => addresses.isNotEmpty ? addresses.first : throw Exception('No addresses'),
      );
    } catch (e) {
      debugPrint('Error getting default address: $e');
      return null;
    }
  }
}
