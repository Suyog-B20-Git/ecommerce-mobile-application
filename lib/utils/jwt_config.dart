import 'package:jwt_decoder/jwt_decoder.dart';

import 'app_enums.dart';
import 'storage_config.dart';

class JwtConfig {
  JwtConfig._();
  // Secret key
  static final String _key = 'hello';

  // Store legacy single token (kept for backward compatibility)
  static String? storeUserToken(String? token) {
    LocalStorage.storeValue(StorageKey.userToken, token);
    return token;
  }

  // Fetch legacy single token (kept for backward compatibility)
  static Future<String?> fetchLocalUserToken() async {
    String? token = await LocalStorage.fetchValue(StorageKey.userToken);
    if (token == null || JwtDecoder.isExpired(token)) return null;
    return token;
  }

  static Future<void> removeLocalUserToken() async {
    LocalStorage.removeValue(StorageKey.userToken);
  }

  // New helpers: Access token
  static Future<void> storeUserAccessToken(String token) async {
    await LocalStorage.storeValue(StorageKey.accessToken, token);
  }

  static Future<String?> fetchLocalUserAccessToken() async {
    final token = await LocalStorage.fetchValue(StorageKey.accessToken);
    return token;
  }

  static Future<void> removeLocalUserAccessToken() async {
    await LocalStorage.removeValue(StorageKey.accessToken);
  }

  // New helpers: Refresh token
  static Future<void> storeUserRefreshToken(String token) async {
    await LocalStorage.storeValue(StorageKey.refreshToken, token);
  }

  static Future<String?> fetchLocalUserRefreshToken() async {
    final token = await LocalStorage.fetchValue(StorageKey.refreshToken);
    return token;
  }

  static Future<void> removeLocalUserRefreshToken() async {
    await LocalStorage.removeValue(StorageKey.refreshToken);
  }
}
