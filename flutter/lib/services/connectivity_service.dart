import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import '../utils/helpers.dart';

/// Connectivity Service - Monitors network connectivity
class ConnectivityService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// Observable connectivity status
  final Rx<ConnectivityStatus> status = ConnectivityStatus.unknown.obs;

  /// Check if connected
  bool get isConnected =>
      status.value == ConnectivityStatus.wifi ||
      status.value == ConnectivityStatus.mobile ||
      status.value == ConnectivityStatus.ethernet;

  /// Check if disconnected
  bool get isDisconnected => status.value == ConnectivityStatus.none;

  /// Initialize connectivity service
  Future<ConnectivityService> init() async {
    // Get initial status
    final result = await _connectivity.checkConnectivity();
    _updateStatus(result);

    // Listen for changes
    _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus);

    return this;
  }

  /// Update connectivity status
  void _updateStatus(List<ConnectivityResult> results) {
    final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
    
    final previousStatus = status.value;
    
    switch (result) {
      case ConnectivityResult.wifi:
        status.value = ConnectivityStatus.wifi;
        break;
      case ConnectivityResult.mobile:
        status.value = ConnectivityStatus.mobile;
        break;
      case ConnectivityResult.ethernet:
        status.value = ConnectivityStatus.ethernet;
        break;
      case ConnectivityResult.vpn:
        status.value = ConnectivityStatus.vpn;
        break;
      case ConnectivityResult.bluetooth:
        status.value = ConnectivityStatus.bluetooth;
        break;
      case ConnectivityResult.none:
        status.value = ConnectivityStatus.none;
        break;
      default:
        status.value = ConnectivityStatus.unknown;
    }

    // Show notification on status change
    if (previousStatus != ConnectivityStatus.unknown) {
      if (previousStatus != ConnectivityStatus.none &&
          status.value == ConnectivityStatus.none) {
        _showDisconnectedNotification();
      } else if (previousStatus == ConnectivityStatus.none &&
          status.value != ConnectivityStatus.none) {
        _showConnectedNotification();
      }
    }
  }

  /// Show disconnected notification
  void _showDisconnectedNotification() {
    UIHelpers.showSnackbar(
      title: 'No Internet',
      message: 'You are currently offline. Some features may not be available.',
      isError: true,
    );
  }

  /// Show connected notification
  void _showConnectedNotification() {
    UIHelpers.showSnackbar(
      title: 'Back Online',
      message: 'Your internet connection has been restored.',
      isSuccess: true,
    );
  }

  /// Check current connectivity
  Future<bool> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _updateStatus(result);
    return isConnected;
  }

  /// Get connection type name
  String get connectionTypeName {
    switch (status.value) {
      case ConnectivityStatus.wifi:
        return 'WiFi';
      case ConnectivityStatus.mobile:
        return 'Mobile Data';
      case ConnectivityStatus.ethernet:
        return 'Ethernet';
      case ConnectivityStatus.vpn:
        return 'VPN';
      case ConnectivityStatus.bluetooth:
        return 'Bluetooth';
      case ConnectivityStatus.none:
        return 'No Connection';
      default:
        return 'Unknown';
    }
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}

/// Connectivity Status Enum
enum ConnectivityStatus {
  wifi,
  mobile,
  ethernet,
  vpn,
  bluetooth,
  none,
  unknown,
}

/// Extension for easy connectivity checks
extension ConnectivityStatusExtension on ConnectivityStatus {
  bool get isConnected =>
      this == ConnectivityStatus.wifi ||
      this == ConnectivityStatus.mobile ||
      this == ConnectivityStatus.ethernet ||
      this == ConnectivityStatus.vpn;

  bool get isDisconnected => this == ConnectivityStatus.none;

  String get displayName {
    switch (this) {
      case ConnectivityStatus.wifi:
        return 'WiFi';
      case ConnectivityStatus.mobile:
        return 'Mobile Data';
      case ConnectivityStatus.ethernet:
        return 'Ethernet';
      case ConnectivityStatus.vpn:
        return 'VPN';
      case ConnectivityStatus.bluetooth:
        return 'Bluetooth';
      case ConnectivityStatus.none:
        return 'No Connection';
      default:
        return 'Unknown';
    }
  }
}
