
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class NetworkService {
  final Connectivity _connectivity;

  NetworkService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  Future<bool> get isConnected async {
    try {
      var result = await _connectivity.checkConnectivity();
      if (result.contains(ConnectivityResult.none)) {
        return false;
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking connectivity: $e');
      }
      return false;
    }
  }

  Stream<ConnectivityResult> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged.map((event) => event.first);
}
