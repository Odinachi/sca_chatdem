import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';

class NetworkConnectivity {
  static final NetworkConnectivity _instance =
      NetworkConnectivity._privateConstructor();

  NetworkConnectivity._privateConstructor();

  factory NetworkConnectivity() {
    return _instance;
  }

  final networkListener = ValueNotifier(true);

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  final _connectivity = Connectivity();

  void initialize() async {
    final check = await _connectivity.checkConnectivity();
    final initialConnect = check.lastOrNull;
    networkListener.value = initialConnect == ConnectivityResult.wifi ||
        initialConnect == ConnectivityResult.mobile;

    _subscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      final lastConnection = result.lastOrNull;
      networkListener.value = lastConnection == ConnectivityResult.wifi ||
          lastConnection == ConnectivityResult.mobile;
    });
  }

  void dispose() {
    if (_subscription != null) _subscription?.cancel();
  }
}
