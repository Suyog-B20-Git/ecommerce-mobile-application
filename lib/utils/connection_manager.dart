import 'dart:async';

import '../api/api_manager.dart';
import 'connection.dart';

class ConnectionManager {
  final Connection _connection = Connection();
  StreamSubscription? _connectionSubscription;
  static final APIManager _apiManager = APIManager();

  ConnectionManager() {
    _setupListener();
  }

  void _setupListener() {
    _connectionSubscription = _connection.connectionStatusStream.listen((bool hasInternet) {
      if (hasInternet) {
        retryAllFailedRequests();
      }
    });
  }

  Future<void> retryAllFailedRequests() async {
    if (_apiManager.failedRequests.isNotEmpty) {
      _apiManager.retryAllFailedRequests();
    }
  }

  void dispose() {
    _connectionSubscription?.cancel();
  }
}
