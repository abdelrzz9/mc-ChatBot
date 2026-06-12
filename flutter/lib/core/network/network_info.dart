import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get onConnectivityChanged;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;
  final InternetConnection connectionChecker;

  NetworkInfoImpl({
    required this.connectivity,
    required this.connectionChecker,
  });

  @override
  Future<bool> get isConnected async {
    try {
      final results = await connectivity.checkConnectivity();
      if (results.length == 1 && results.contains(ConnectivityResult.none)) {
        return false;
      }
      final hasInternet = await connectionChecker.hasInternetAccess.timeout(
        const Duration(seconds: 3),
      );
      return hasInternet;
    } catch (_) {
      return false;
    }
  }

  @override
  Stream<bool> get onConnectivityChanged {
    return connectivity.onConnectivityChanged.map((results) {
      if (results.length == 1 && results.contains(ConnectivityResult.none)) {
        return false;
      }
      return true;
    });
  }
}
