import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';

import '../api/api_manager.dart';
import '../utils/connection.dart';
import '../utils/connection_manager.dart';
import '../utils/jwt_config.dart';

class AppController extends GetxController {
  final Connection connection = Connection();
  final ConnectionManager connectionManager = ConnectionManager();
  late StreamSubscription<bool> connectionSubscription;
  String? userToken;

  @override
  void onInit() async {
    super.onInit();
    APIManager.init(this);
    userToken = await JwtConfig.fetchLocalUserToken() ?? '';

    // Initialize network service
    await initializeConnectionServices();
  }

  @override
  void onClose() {
    connectionSubscription.cancel();
    super.onClose();
  }

  void updateToken(String? token) {
    userToken = token;
    JwtConfig.storeUserToken(token);
  }

  void removeToken() {
    userToken = '';
    JwtConfig.removeLocalUserToken();
  }

  // String getInitialRoute() {
  //   if (userToken != null && userToken!.isNotEmpty) {
  //     if (isStore ?? true) {
  //       return Routes.ADD_STORE_SCREEN;
  //     } else {
  //       return Routes.DASHBOARD_SCREEN;
  //     }
  //   } else {
  //     return Routes.LOGIN_SCREEN;
  //   }
  // }

  /// Connection
  Future<void> initializeConnectionServices() async {
    connection.initValue = await Connection.checkInternet();
    connectionSubscription = connection.onChangeConnectivity.listen((event) {
      log('Has internet $event');
    });
  }
}
