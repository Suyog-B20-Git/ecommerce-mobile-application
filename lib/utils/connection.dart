import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

class Connection {
  static final Connectivity _connectivity = Connectivity();
  bool _hasInternet = false;
  final StreamController<bool> _connectionStatusController = StreamController<bool>.broadcast();

  Connection() {
    _init();
  }

  Future<void> _init() async {
    // Initial check
    _hasInternet = await _checkInternet(await _connectivity.checkConnectivity());
    _connectionStatusController.add(_hasInternet);

    // Listen for changes
    _connectivity.onConnectivityChanged.asyncMap(_checkInternet).listen((bool hasInternet) {
      _hasInternet = hasInternet;
      _connectionStatusController.add(hasInternet);
    });
  }

  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;

  set initValue(bool value) {
    _hasInternet = value;
  }

  bool get hasInternet => _hasInternet;

  Future<bool> _listenChangeConnectivity(List<ConnectivityResult> event) async {
    return _checkInternet(event);
  }

  static Future<bool> _checkInternet(List<ConnectivityResult> event) async {
    bool anyNetwork = event.any((e) => e == ConnectivityResult.mobile || e == ConnectivityResult.wifi);
    if (anyNetwork) {
      try {
        final result = await InternetAddress.lookup('google.com');
        anyNetwork = result.isNotEmpty && result.first.rawAddress.isNotEmpty;
      } catch (_) {
        anyNetwork = false;
      }
    }
    return anyNetwork;
  }

  static Future<bool> checkInternet() async {
    return _checkInternet(await _connectivity.checkConnectivity());
  }

  Stream<bool> get onChangeConnectivity => _connectivity.onConnectivityChanged.asyncMap(_listenChangeConnectivity);
}
