import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mockmaster/utils/popups/loaders.dart';

class MNetworkManager extends GetxController {
  static MNetworkManager get instance => Get.find();

  final Connectivity _connectivity = Connectivity();

  late StreamSubscription<List<ConnectivityResult>>
      _connectivitySubscription;

  final RxList<ConnectivityResult> _connectionStatus =
      <ConnectivityResult>[ConnectivityResult.none].obs;

  /// Initialize network manager
  @override
  void onInit() {
    super.onInit();

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  /// Update connection status
  Future<void> _updateConnectionStatus(
    List<ConnectivityResult> result,
  ) async {
    _connectionStatus.value = result;

    if (_connectionStatus.contains(ConnectivityResult.none)) {
      MLoaders.warningSnackBar(
        title: 'No Internet Connection',
      );
    }
  }

  /// Check internet connection
  Future<bool> isConnected() async {
    try {
      final result = await _connectivity.checkConnectivity();

      if (result.contains(ConnectivityResult.none)) {
        return false;
      }

      return true;
    } on PlatformException {
      return false;
    }
  }

  /// Dispose connectivity stream
  @override
  void onClose() {
    _connectivitySubscription.cancel();
    super.onClose();
  }
}