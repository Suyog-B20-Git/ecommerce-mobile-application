import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as material;
import 'package:get/get.dart' as getx;
import 'package:jwt_decoder/jwt_decoder.dart';

import '../controller/app_controller.dart';
import '../routes/routes.dart';
import '../utils/app_enums.dart';
import '../utils/config.dart';
import '../utils/jwt_config.dart';
import '../widgets/custom_loader.dart';
import '../widgets/snackbar.dart';
import '../widgets/toastification.dart';
import 'api_exception.dart';

class APIManager {
  static late AppController _appController;
  static late APIManager _apiManager;

  // Check Network Internet Connection
  var isNoInternetMessageDisplayed = false;

  // Store Failed Request
  final List<PendingRequest> failedRequests = [];

  // Refresh token synchronization
  bool _isRefreshing = false;
  final List<Completer<void>> _refreshWaiters = [];

  factory APIManager.init(AppController appController) {
    _appController = appController;
    _apiManager = APIManager._internal();
    return _apiManager;
  }

  factory APIManager() {
    return _apiManager;
  }

  static CancelToken cancelToken = CancelToken();

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      baseUrl: Config.domainUrl,
    ),
  );

  APIManager._internal() {
    // Add Interceptors for common tasks (authentication, caching, etc.)
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          options.headers['Content-Type'] = 'application/json';
          // Skip auth header for auth endpoints and public endpoints
          if (options.path == "/auth/login" ||
              options.path == "/auth/refresh-tokens" ||
              options.path == "/admin/auth/register" ||
              options.path == "/location/countrySuggestions" ||
              options.path == "/location/stateSuggestions" ||
              options.path == "/location/citySuggestions") {
            return handler.next(options);
          }

          // Skip auth for requests when on login or signup screen
          if (getx.Get.currentRoute == Routes.LOGIN_SCREEN ||
              getx.Get.currentRoute == Routes.REGISTER_SCREEN) {
            return handler.next(options);
          }

          // Check if user is authenticated before making any requests
          if (_appController.userToken == null ||
              _appController.userToken!.isEmpty) {
            // Cancel the request if user is not authenticated
            return handler.reject(
              DioException(
                requestOptions: options,
                error: 'User not authenticated',
                type: DioExceptionType.cancel,
              ),
            );
          }

          final token = await _getValidAccessToken();
          if (token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
            if (kDebugMode) {
              print(
                'APIManager: Adding Authorization header for ${options.path}',
              );
            }
          } else {
            if (kDebugMode) {
              print('APIManager: No token available for ${options.path}');
            }
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // Skip token refresh if on login or signup screen
          if (getx.Get.currentRoute == Routes.LOGIN_SCREEN ||
              getx.Get.currentRoute == Routes.REGISTER_SCREEN) {
            return handler.next(error);
          }

          // Skip token refresh if user is not authenticated
          if (_appController.userToken == null ||
              _appController.userToken!.isEmpty) {
            return handler.next(error);
          }

          // If unauthorized, try to refresh and retry once
          if (error.response?.statusCode == 401 &&
              !_isAuthEndpoint(error.requestOptions.path)) {
            try {
              await _refreshTokensIfNeeded();
              final retryRequest = await _retryRequest(error.requestOptions);
              return handler.resolve(retryRequest);
            } catch (e) {
              // If refresh failed, the user should already be logged out
              // Forward the original error
              return handler.next(error);
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  bool _isAuthEndpoint(String path) {
    return path == "/auth/login" || path == "/auth/refresh-tokens";
  }

  Future<String> _getValidAccessToken() async {
    // Skip token retrieval if on login or signup screen
    if (getx.Get.currentRoute == Routes.LOGIN_SCREEN ||
        getx.Get.currentRoute == Routes.REGISTER_SCREEN) {
      return '';
    }

    // Prefer new access token storage; fallback to legacy single token
    final stored =
        await JwtConfig.fetchLocalUserAccessToken() ??
        _appController.userToken ??
        '';

    if (kDebugMode) {
      print(
        'APIManager: Retrieved token: ${stored.isNotEmpty ? "Present" : "Empty"}',
      );
    }

    if (stored.isEmpty) return '';

    // Check if token is expired
    if (JwtDecoder.isExpired(stored)) {
      if (kDebugMode) {
        print('APIManager: Token expired, attempting refresh');
      }

      // Don't try to refresh if we're on login screen or if no valid session
      if (getx.Get.currentRoute == Routes.LOGIN_SCREEN ||
          _appController.userToken == null) {
        return '';
      }

      await _refreshTokensIfNeeded();
      final refreshed =
          await JwtConfig.fetchLocalUserAccessToken() ??
          _appController.userToken ??
          '';
      return refreshed;
    }
    return stored;
  }

  Future<void> _refreshTokensIfNeeded() async {
    // Skip refresh if on login or signup screen
    if (getx.Get.currentRoute == Routes.LOGIN_SCREEN ||
        getx.Get.currentRoute == Routes.REGISTER_SCREEN) {
      return;
    }

    if (_isRefreshing) {
      final waiter = Completer<void>();
      _refreshWaiters.add(waiter);
      return waiter.future;
    }
    _isRefreshing = true;
    try {
      final refreshToken = await JwtConfig.fetchLocalUserRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        // Only handle as failure if we're not on login screen
        if (getx.Get.currentRoute != Routes.LOGIN_SCREEN) {
          await _handleRefreshFailure('No refresh token available');
        }
        return;
      }

      // Check if refresh token is expired before making API call
      if (JwtDecoder.isExpired(refreshToken)) {
        // Only handle as failure if we're not on login screen
        if (getx.Get.currentRoute != Routes.LOGIN_SCREEN) {
          await _handleRefreshFailure('Refresh token has expired');
        }
        return;
      }

      final response = await _dio.post(
        '/auth/refresh-tokens',
        data: {'refreshToken': refreshToken},
      );
      final data = response.data;
      final tokens = data['tokens'];
      final access = tokens?['access']?['token'] as String?;
      final refresh = tokens?['refresh']?['token'] as String?;

      if (access != null && access.isNotEmpty) {
        await JwtConfig.storeUserAccessToken(access);
        // Keep AppController token in sync for backward compatibility
        _appController.updateToken(access);
      }
      if (refresh != null && refresh.isNotEmpty) {
        await JwtConfig.storeUserRefreshToken(refresh);
      }
    } catch (e) {
      // Handle refresh failure - logout user
      await _handleRefreshFailure('Failed to refresh tokens: ${e.toString()}');
    } finally {
      _isRefreshing = false;
      for (final waiter in _refreshWaiters) {
        if (!waiter.isCompleted) waiter.complete();
      }
      _refreshWaiters.clear();
    }
  }

  Future<void> _handleRefreshFailure(String reason) async {
    try {
      // Skip handling if on login or signup screen
      if (getx.Get.currentRoute == Routes.LOGIN_SCREEN ||
          getx.Get.currentRoute == Routes.REGISTER_SCREEN) {
        return;
      }

      // Stop all refresh operations
      _isRefreshing = false;
      for (final waiter in _refreshWaiters) {
        if (!waiter.isCompleted) waiter.complete();
      }
      _refreshWaiters.clear();

      // Cancel all ongoing requests
      cancelToken.cancel();
      cancelToken = CancelToken();

      // Clear all stored tokens
      await JwtConfig.removeLocalUserAccessToken();
      await JwtConfig.removeLocalUserRefreshToken();
      await JwtConfig.removeLocalUserToken();

      // Clear AppController token
      _appController.removeToken();

      // Only navigate to login screen if not already there
      if (getx.Get.currentRoute != Routes.LOGIN_SCREEN) {
        getx.Get.offAllNamed(Routes.LOGIN_SCREEN);

        // Show user-friendly message only if we navigated
        if (getx.Get.context != null) {
          SnackBar.error(message: 'Session expired. Please login again.');
        }
      }

      if (kDebugMode) {
        print('Refresh token failure: $reason');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during logout: $e');
      }
    }
  }

  Future<Response<dynamic>> _retryRequest(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: Map<String, dynamic>.from(requestOptions.headers),
      responseType: requestOptions.responseType,
      contentType: requestOptions.contentType,
    );
    // Inject fresh Authorization header
    final token = await _getValidAccessToken();
    if (token.isNotEmpty) {
      options.headers = {
        ...options.headers ?? {},
        'Authorization': 'Bearer $token',
      };
    }
    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
      cancelToken: requestOptions.cancelToken,
      onReceiveProgress: requestOptions.onReceiveProgress,
      onSendProgress: requestOptions.onSendProgress,
    );
  }

  // Function to check & return if the token is valid
  String get getAuthToken {
    return _appController.userToken ?? '';
  }

  // GET
  Future<dynamic> getAPICall({
    required String url,
    material.BuildContext? context,
    Map<String, dynamic>? queryParameters,
    bool showLoading = false,
    int timeOut = 20,
  }) async {
    if (_appController.connection.hasInternet) {
      if (showLoading && context != null) {
        Loader.instance.showLoader(context);
      }
      try {
        final response = await _dio
            .get(
              url,
              queryParameters: queryParameters,
              cancelToken: cancelToken,
            )
            .timeout(
              Duration(seconds: timeOut),
              onTimeout: () {
                throw TimeoutException(message: 'Timeout');
              },
            );

        Loader.instance.removeLoader();
        logAPICallDetails(response);
        var responseJson = _response(response);
        return responseJson;
      } on TimeoutException {
        return {"status": "error", "message": "Request timed out"};
      } on DioException catch (error) {
        handleDioError(error);
        return error.response?.data ??
            {"status": "error", "message": "Unknown error"};
      } finally {
        Loader.instance.removeLoader();
      }
    } else {
      handleNoInternet();
      return null;
    }
  }

  // POST
  Future<dynamic> postAPICall({
    required String url,
    var params,
    material.BuildContext? context,
    Map<String, dynamic>? queryParameters,
    bool showLoading = true,
    int timeOut = 20,
  }) async {
    // Check internet is on or not
    if (_appController.connection.hasInternet) {
      if (showLoading) Loader.instance.showLoader(context!);
      if (kDebugMode) {
        print('------------------ $url');
      }
      try {
        final response = await _dio
            .post(
              url,
              data: params,
              queryParameters: queryParameters,
              // options: Options(
              //   headers: {'Content-Type': 'application/json'},
              // ),
              cancelToken: cancelToken,
            )
            .timeout(
              Duration(seconds: timeOut),
              onTimeout: () {
                throw TimeoutException(message: 'Timeout');
              },
            );
        Loader.instance.removeLoader();
        logAPICallDetails(response);
        var responseJson = _response(response);
        return responseJson;
      } on TimeoutException {
        return {"status": "error", "message": "Request timed out"};
      } on DioException catch (error) {
        try {
          handleDioError(error);
          return error.response?.data ??
              {"status": "error", "message": "Unknown error"};
        } catch (e) {
          return error.response?.data;
        }
      } finally {
        if (showLoading) Loader.instance.removeLoader();
      }
    } else {
      handleNoInternet();
      return null;
    }
  }

  // PUT
  Future<dynamic> putAPICall({
    required String url,
    var params,
    material.BuildContext? context,
    Map<String, dynamic>? queryParameters,
    bool showLoading = true,
    int timeOut = 20,
  }) async {
    if (_appController.connection.hasInternet) {
      if (showLoading && context != null) {
        Loader.instance.showLoader(context);
      }
      try {
        final response = await _dio
            .put(
              url,
              data: params,
              queryParameters: queryParameters,
              options: Options(headers: {'Content-Type': 'application/json'}),
              cancelToken: cancelToken,
            )
            .timeout(
              Duration(seconds: timeOut),
              onTimeout: () {
                throw TimeoutException(message: 'Timeout');
              },
            );
        Loader.instance.removeLoader();
        logAPICallDetails(response);
        var responseJson = _response(response);
        return responseJson;
      } on TimeoutException {
        return {"status": "error", "message": "Request timed out"};
      } on DioException catch (error) {
        try {
          handleDioError(error);
          return error.response?.data ??
              {"status": "error", "message": "Unknown error"};
        } catch (e) {
          log("Error Response -> ${error.response!.data}");
          return error.response?.data;
        }
      } finally {
        Loader.instance.removeLoader();
        if (kDebugMode) {
          log('finally');
        }
      }
    } else {
      handleNoInternet();
      return null;
    }
  }

  // PATCH
  Future<dynamic> patchAPICall({
    required String url,
    var params,
    material.BuildContext? context,
    Map<String, dynamic>? queryParameters,
    bool showLoading = true,
    int timeOut = 20,
  }) async {
    // Check internet is on or not
    if (_appController.connection.hasInternet) {
      if (showLoading && context != null) {
        Loader.instance.showLoader(context);
      }
      try {
        final response = await _dio
            .patch(
              url,
              data: params,
              queryParameters: queryParameters,
              // options: Options(
              //   headers: {'Content-Type': 'application/json'},
              // ),
              cancelToken: cancelToken,
            )
            .timeout(
              Duration(seconds: timeOut),
              onTimeout: () {
                throw TimeoutException(message: 'Timeout');
              },
            );
        Loader.instance.removeLoader();
        logAPICallDetails(response);
        var responseJson = _response(response);
        return responseJson;
      } on TimeoutException {
        handleTimeoutException();
        return null;
      } on DioException catch (error) {
        return handleDioError(error);
      } finally {
        debugPrint('finally');
        Loader.instance.removeLoader();
      }
    } else {
      handleNoInternet();
      return null;
    }
  }

  // Delete
  Future<dynamic> deleteAPICall({
    required String url,
    var params,
    material.BuildContext? context,
    Map<String, dynamic>? queryParameters,
    bool showLoading = true,
    int timeOut = 20,
  }) async {
    // Check if internet is available
    if (_appController.connection.hasInternet) {
      if (showLoading && context != null) {
        Loader.instance.showLoader(context);
      }
      try {
        final response = await _dio
            .delete(
              url,
              data: params,
              queryParameters: queryParameters,
              cancelToken: cancelToken,
            )
            .timeout(
              Duration(seconds: timeOut),
              onTimeout: () {
                throw TimeoutException(message: 'Timeout');
              },
            );

        Loader.instance.removeLoader();
        logAPICallDetails(response);
        var responseJson = _response(response);
        return responseJson;
      } on TimeoutException {
        return {"status": "error", "message": "Request timed out"};
      } on DioException catch (error) {
        try {
          handleDioError(error);
          return error.response?.data ??
              {"status": "error", "message": "Unknown error"};
        } catch (e) {
          return error.response?.data;
        }
      } finally {
        debugPrint('finally');
        Loader.instance.removeLoader();
      }
    } else {
      handleNoInternet();
      return null;
    }
  }

  // MULTIPART POST API call
  Future<dynamic> multipartPostAPICall({
    required String url,
    material.BuildContext? context,
    String? fileKey1,
    File? file1,
    String? fileKey2,
    File? file2,
    String? fileKey3,
    File? file3,
    required Map<String, dynamic> params,
    Map<String, dynamic>? queryParameters,
    bool showLoading = true,
    int timeOut = 60,
  }) async {
    if (_appController.connection.hasInternet) {
      if (showLoading && context != null) {
        Loader.instance.showLoader(context);
      }
      try {
        final formDataMap = {...params};
        if (fileKey1 != null && file1 != null) {
          formDataMap[fileKey1] = await MultipartFile.fromFile(
            file1.path,
            filename: file1.path.split('/').last,
          );
        }
        if (fileKey2 != null && file2 != null) {
          formDataMap[fileKey2] = await MultipartFile.fromFile(
            file2.path,
            filename: file2.path.split('/').last,
          );
        }
        if (fileKey3 != null && file3 != null) {
          formDataMap[fileKey3] = await MultipartFile.fromFile(
            file3.path,
            filename: file3.path.split('/').last,
          );
        }

        final formData = FormData.fromMap(formDataMap);

        final response = await _dio
            .post(
              url,
              data: formData,
              queryParameters: queryParameters,
              options: Options(
                headers: {'Content-Type': 'multipart/form-data'},
              ),
              cancelToken: cancelToken,
            )
            .timeout(
              Duration(seconds: timeOut),
              onTimeout: () => throw TimeoutException(message: 'Timeout'),
            );

        var responseJson = _response(response);
        logAPICallDetails(response);
        return responseJson;
      } on TimeoutException {
        handleTimeoutException();
      } on DioException catch (error) {
        return handleDioError(error);
      } finally {
        Loader.instance.removeLoader();
      }
    } else {
      handleNoInternet();
      return null;
    }
  }

  //MULTIPART PUT API call
  Future<dynamic> multipartPutAPICall({
    required String url,
    material.BuildContext? context,
    String? fileKey1,
    File? file1,
    String? fileKey2,
    File? file2,
    dynamic params,
    String? paraName,
    Map<String, dynamic>? queryParameters,
    bool showLoading = true,
    int timeOut = 60,
  }) async {
    if (_appController.connection.hasInternet) {
      if (showLoading && context != null) {
        Loader.instance.showLoader(context);
      }

      try {
        FormData formData;

        if (params is Map<String, dynamic>) {
          formData = FormData.fromMap({
            ...params,
            if (fileKey1 != null && file1 != null)
              fileKey1: await MultipartFile.fromFile(
                file1.path,
                filename: file1.path.split('/').last,
              ),
            if (fileKey2 != null && file2 != null)
              fileKey2: await MultipartFile.fromFile(
                file2.path,
                filename: file2.path.split('/').last,
              ),
          });
        } else if (params is String && paraName != null) {
          formData = FormData.fromMap({
            paraName: params,
            if (fileKey1 != null && file1 != null)
              fileKey1: await MultipartFile.fromFile(
                file1.path,
                filename: file1.path.split('/').last,
              ),
            if (fileKey2 != null && file2 != null)
              fileKey2: await MultipartFile.fromFile(
                file2.path,
                filename: file2.path.split('/').last,
              ),
          });
        } else {
          formData = FormData.fromMap({
            if (fileKey1 != null && file1 != null)
              fileKey1: await MultipartFile.fromFile(
                file1.path,
                filename: file1.path.split('/').last,
              ),
            if (fileKey2 != null && file2 != null)
              fileKey2: await MultipartFile.fromFile(
                file2.path,
                filename: file2.path.split('/').last,
              ),
          });
        }

        final response = await _dio
            .put(
              url,
              data: formData,
              queryParameters: queryParameters,
              options: Options(
                headers: {'Content-Type': 'multipart/form-data'},
              ),
              cancelToken: cancelToken,
            )
            .timeout(
              Duration(seconds: timeOut),
              onTimeout: () => throw TimeoutException(message: 'Timeout'),
            );

        Loader.instance.removeLoader();
        var responseJson = _response(response);
        logAPICallDetails(response);
        return responseJson;
      } on TimeoutException {
        handleTimeoutException();
      } on DioException catch (error) {
        handleDioError(error);
      } finally {
        Loader.instance.removeLoader();
      }
    } else {
      handleNoInternet();
      return null;
    }
  }

  // MULTIPART PATCH
  Future<dynamic> multipartPatchAPICall2Image({
    required String url,
    material.BuildContext? context,
    String? fileKey1,
    File? file1,
    String? fileKey2,
    File? file2,
    dynamic params,
    String? paraName,
    Map<String, dynamic>? queryParameters,
    bool showLoading = true,
    int timeOut = 60,
  }) async {
    if (_appController.connection.hasInternet) {
      if (showLoading && context != null) {
        Loader.instance.showLoader(context);
      }

      try {
        FormData formData;

        if (params is Map<String, dynamic>) {
          formData = FormData.fromMap({
            ...params,
            if (fileKey1 != null && file1 != null)
              fileKey1: await MultipartFile.fromFile(
                file1.path,
                filename: file1.path.split('/').last,
              ),
            if (fileKey2 != null && file2 != null)
              fileKey2: await MultipartFile.fromFile(
                file2.path,
                filename: file2.path.split('/').last,
              ),
          });
        } else if (params is String && paraName != null) {
          formData = FormData.fromMap({
            paraName: params,
            if (fileKey1 != null && file1 != null)
              fileKey1: await MultipartFile.fromFile(
                file1.path,
                filename: file1.path.split('/').last,
              ),
            if (fileKey2 != null && file2 != null)
              fileKey2: await MultipartFile.fromFile(
                file2.path,
                filename: file2.path.split('/').last,
              ),
          });
        } else {
          formData = FormData.fromMap({
            if (fileKey1 != null && file1 != null)
              fileKey1: await MultipartFile.fromFile(
                file1.path,
                filename: file1.path.split('/').last,
              ),
            if (fileKey2 != null && file2 != null)
              fileKey2: await MultipartFile.fromFile(
                file2.path,
                filename: file2.path.split('/').last,
              ),
          });
        }

        final response = await _dio
            .patch(
              url,
              data: formData,
              queryParameters: queryParameters,
              options: Options(
                headers: {'Content-Type': 'multipart/form-data'},
              ),
              cancelToken: cancelToken,
            )
            .timeout(
              Duration(seconds: timeOut),
              onTimeout: () => throw TimeoutException(message: 'Timeout'),
            );

        Loader.instance.removeLoader();
        var responseJson = _response(response);
        logAPICallDetails(response);
        return responseJson;
      } on TimeoutException {
        return handleTimeoutException();
      } on DioException catch (error) {
        return handleDioError(error);
      } finally {
        Loader.instance.removeLoader();
      }
    } else {
      handleNoInternet();
      return null;
    }
  }

  // Multipart Patch API call
  Future<dynamic> multipartPatchAPICall({
    required String url,
    Map<String, File?>? files,
    required Map<String, dynamic> params,
    Map<String, dynamic>? queryParameters,
    bool showLoading = true,
    int timeOut = 60,
  }) async {
    if (_appController.connection.hasInternet) {
      // Loader.instance.showLoader();
      try {
        final formData = FormData.fromMap({
          ...params,
          if (files != null) ...{
            for (var entry in files.entries)
              if (entry.value != null)
                entry.key: await MultipartFile.fromFile(
                  entry.value!.path,
                  filename: entry.value!.path.split('/').last,
                ),
          },
        });
        final response = await _dio
            .patch(
              url,
              data: formData,
              queryParameters: queryParameters,
              options: Options(
                headers: {'Content-Type': 'multipart/form-data'},
              ),
              cancelToken: cancelToken,
            )
            .timeout(
              Duration(seconds: timeOut),
              onTimeout: () {
                throw TimeoutException(message: 'Timeout');
              },
            );
        var responseJson = _response(response);
        logAPICallDetails(response);
        return responseJson;
      } on TimeoutException {
        handleTimeoutException();
      } on DioException catch (error) {
        handleDioError(error);
      } finally {
        // Loader.instance.removeLoader();
      }
    } else {
      handleNoInternet();
      return null;
    }
  }

  // Multipart post api call for multiple files
  Future<dynamic> multipartPostMultiFilesAPICall({
    required String url,
    Map<String, File?>? files,
    required Map<String, dynamic> params,
    Map<String, dynamic>? queryParameters,
    bool showLoading = true,
    int timeOut = 60,
  }) async {
    if (_appController.connection.hasInternet) {
      // Loader.instance.showLoader();
      try {
        final formData = FormData.fromMap({
          ...params,
          if (files != null) ...{
            for (var entry in files.entries)
              if (entry.value != null)
                entry.key: await MultipartFile.fromFile(
                  entry.value!.path,
                  filename: entry.value!.path.split('/').last,
                ),
          },
        });
        final response = await _dio
            .post(
              url,
              data: formData,
              queryParameters: queryParameters,
              options: Options(
                headers: {'Content-Type': 'multipart/form-data'},
              ),
              cancelToken: cancelToken,
            )
            .timeout(
              Duration(seconds: timeOut),
              onTimeout: () {
                throw TimeoutException(message: 'Timeout');
              },
            );
        var responseJson = _response(response);
        logAPICallDetails(response);
        return responseJson;
      } on TimeoutException {
        handleTimeoutException();
      } on DioException catch (error) {
        handleDioError(error);
      } finally {
        // Loader.instance.removeLoader();
      }
    } else {
      handleNoInternet();
      return null;
    }
  }

  Future<dynamic> multipartPostFilesArrayAPICall({
    required String url,
    Map<String, List<File>>? files,
    material.BuildContext? context,
    dynamic params,
    dynamic paraName,
    Map<String, dynamic>? queryParameters,
    bool showLoading = true,
    int timeOut = 60,
  }) async {
    if (_appController.connection.hasInternet) {
      if (showLoading && context != null) {
        Loader.instance.showLoader(context);
      }
      try {
        FormData formData;

        if (params is Map<String, dynamic>) {
          formData = FormData.fromMap({
            ...params,
            if (files != null) ...{
              for (var entry in files.entries)
                entry.key: [
                  for (var file in entry.value)
                    await MultipartFile.fromFile(
                      file.path,
                      filename: file.path.split('/').last,
                    ),
                ],
            },
          });
        } else if (params is String) {
          formData = FormData.fromMap({
            "$paraName": params,
            if (files != null) ...{
              for (var entry in files.entries)
                entry.key: [
                  for (var file in entry.value)
                    await MultipartFile.fromFile(
                      file.path,
                      filename: file.path.split('/').last,
                    ),
                ],
            },
          });
        } else {
          formData = FormData.fromMap({
            if (files != null) ...{
              for (var entry in files.entries)
                entry.key: [
                  for (var file in entry.value)
                    await MultipartFile.fromFile(
                      file.path,
                      filename: file.path.split('/').last,
                    ),
                ],
            },
          });
        }

        final response = await _dio
            .post(
              url,
              data: formData,
              queryParameters: queryParameters ?? {},
              options: Options(
                headers: {'Content-Type': 'multipart/form-data'},
              ),
              cancelToken: cancelToken,
            )
            .timeout(
              Duration(seconds: timeOut),
              onTimeout: () {
                throw TimeoutException(message: 'Request timed out');
              },
            );

        Loader.instance.removeLoader();
        var responseJson = _response(response);
        logAPICallDetails(response);
        return responseJson;
      } on TimeoutException {
        return {"status": "error", "message": "Request timed out"};
      } on DioException catch (error) {
        try {
          handleDioError(error);
          return error.response?.data ??
              {"status": "error", "message": "Unknown error"};
        } catch (e) {
          log("Error Response -> ${error.response!.data}");
          return error.response?.data;
        }
      } finally {
        Loader.instance.removeLoader();
      }
    } else {
      handleNoInternet();
      return null;
    }
  }

  // Array and individual images of post
  Future<dynamic> multipartPostMultiSingleFilesAPICall({
    required String url,
    material.BuildContext? context,
    String? fileKey1,
    File? file1,
    String? fileKey2,
    File? file2,
    String? fileKey3,
    File? file3,
    String? fileKey4,
    File? file4,
    List<File>? fileArray,
    String? arrayKey,
    required Map<String, dynamic> params,
    Map<String, dynamic>? queryParameters,
    bool showLoading = true,
    int timeOut = 60,
  }) async {
    if (_appController.connection.hasInternet) {
      if (showLoading && context != null) {
        Loader.instance.showLoader(context);
      }

      try {
        final formDataMap = {...params};

        // Safely add individual files if they exist
        Future<void> addFile(String? key, File? file) async {
          if (key != null && key.isNotEmpty && file != null) {
            formDataMap[key] = await MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
            );
          }
        }

        await addFile(fileKey1, file1);
        await addFile(fileKey2, file2);
        await addFile(fileKey3, file3);
        await addFile(fileKey4, file4);

        // Safely add file array only if key and list are valid
        if (arrayKey != null &&
            arrayKey.isNotEmpty &&
            fileArray != null &&
            fileArray.isNotEmpty) {
          final multipartFiles = await Future.wait(
            fileArray.map((file) async {
              return await MultipartFile.fromFile(
                file.path,
                filename: file.path.split('/').last,
              );
            }),
          );

          formDataMap[arrayKey] = multipartFiles;
        }

        final formData = FormData.fromMap(formDataMap);

        final response = await _dio
            .post(
              url,
              data: formData,
              queryParameters: queryParameters,
              options: Options(
                headers: {'Content-Type': 'multipart/form-data'},
              ),
              cancelToken: cancelToken,
            )
            .timeout(
              Duration(seconds: timeOut),
              onTimeout: () => throw TimeoutException(message: 'Timeout'),
            );

        var responseJson = _response(response);
        logAPICallDetails(response);
        return responseJson;
      } on TimeoutException {
        handleTimeoutException();
      } on DioException catch (error) {
        return handleDioError(error);
      } finally {
        Loader.instance.removeLoader();
      }
    } else {
      handleNoInternet();
      return null;
    }
  }

  // Array and individual images of patch
  Future<dynamic> multipartPatchMultiSingleFilesAPICall({
    required String url,
    material.BuildContext? context,
    String? fileKey1,
    File? file1,
    String? fileKey2,
    File? file2,
    String? fileKey3,
    File? file3,
    String? fileKey4,
    File? file4,
    List<File>? fileArray,
    String? arrayKey,
    required Map<String, dynamic> params,
    Map<String, dynamic>? queryParameters,
    bool showLoading = true,
    int timeOut = 60,
  }) async {
    if (_appController.connection.hasInternet) {
      if (showLoading && context != null) {
        Loader.instance.showLoader(context);
      }

      try {
        final formDataMap = {...params};

        // Safely add individual files if they exist
        Future<void> addFile(String? key, File? file) async {
          if (key != null && key.isNotEmpty && file != null) {
            formDataMap[key] = await MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
            );
          }
        }

        await addFile(fileKey1, file1);
        await addFile(fileKey2, file2);
        await addFile(fileKey3, file3);
        await addFile(fileKey4, file4);

        // Safely add file array only if key and list are valid
        if (arrayKey != null &&
            arrayKey.isNotEmpty &&
            fileArray != null &&
            fileArray.isNotEmpty) {
          final multipartFiles = await Future.wait(
            fileArray.map((file) async {
              return await MultipartFile.fromFile(
                file.path,
                filename: file.path.split('/').last,
              );
            }),
          );

          formDataMap[arrayKey] = multipartFiles;
        }

        final formData = FormData.fromMap(formDataMap);

        final response = await _dio
            .patch(
              url,
              data: formData,
              queryParameters: queryParameters,
              options: Options(
                headers: {'Content-Type': 'multipart/form-data'},
              ),
              cancelToken: cancelToken,
            )
            .timeout(
              Duration(seconds: timeOut),
              onTimeout: () => throw TimeoutException(message: 'Timeout'),
            );

        var responseJson = _response(response);
        logAPICallDetails(response);
        return responseJson;
      } on TimeoutException {
        handleTimeoutException();
      } on DioException catch (error) {
        return handleDioError(error);
      } finally {
        Loader.instance.removeLoader();
      }
    } else {
      handleNoInternet();
      return null;
    }
  }

  // Retry Pending API
  Future<void> retryAllFailedRequests() async {
    if (failedRequests.isEmpty) return;

    final List<PendingRequest> requestsToRetry = List.from(failedRequests);
    failedRequests.clear();
    isNoInternetMessageDisplayed = false;

    for (var request in requestsToRetry) {
      dynamic response;

      switch (request.method) {
        case ApiMethod.get:
          response = await getAPICall(
            url: request.url,
            queryParameters: request.queryParams,
            context: request.context,
            showLoading: request.showLoading,
          );
          break;

        default:
          break;
      }

      //Execute success callback
      if (response != null && request.onSuccess != null) {
        try {
          await request.onSuccess!(response);
          log("onSuccess executed for ${request.url}");
        } catch (e) {
          log("Error in onSuccess for ${request.url}: $e");
        }
      } else {
        log("No response or no onSuccess for ${request.url}");
      }
    }
  }

  // Function to cancel any ongoing requests
  void cancelRequests() {
    cancelToken.cancel();
    cancelToken = CancelToken();
  }

  // Function to completely stop all API activities (for logout)
  void stopAllActivities() {
    // Stop refresh operations
    _isRefreshing = false;
    for (final waiter in _refreshWaiters) {
      if (!waiter.isCompleted) waiter.complete();
    }
    _refreshWaiters.clear();

    // Cancel all requests
    cancelToken.cancel();
    cancelToken = CancelToken();

    // Clear failed requests
    failedRequests.clear();
  }

  void handleNoInternet() {
    if (isNoInternetMessageDisplayed == false) {
      ToastHelper.showErrorToast("No Internet Connection");
      isNoInternetMessageDisplayed = true;
    }
  }

  void handleSessionExpired() {
    // if (isSessionExpiredMessageDisplayed == false) {
    //   // errorSnackBar(message: 'Your session has expired!');
    //   isSessionExpiredMessageDisplayed = true;
    // }
  }

  // void handleDioError(DioException error) {
  //   Map<String, dynamic> errorResponse = {"status": 0, "message": "An unknown error occurred"};
  //
  //   switch (error.type) {
  //     case DioExceptionType.connectionTimeout:
  //     case DioExceptionType.sendTimeout:
  //     case DioExceptionType.receiveTimeout:
  //       errorResponse["message"] = "The request timed out.";
  //       break;
  //
  //     case DioExceptionType.badResponse:
  //       if (error.response != null) {
  //         var message = error.response?.data;
  //         if (message is Set<String>) {
  //           errorResponse["message"] = "Expected a Map<String, dynamic> but received Set<String>.";
  //         } else if (message is Map<String, dynamic>) {
  //           throw FetchDataException(message.toString());
  //         } else {
  //           errorResponse["message"] = "Bad response format.";
  //         }
  //       } else {
  //         errorResponse["message"] = "Received invalid status code.";
  //       }
  //       break;
  //
  //     case DioExceptionType.cancel:
  //       errorResponse["message"] = "Request was cancelled.";
  //       break;
  //
  //     case DioExceptionType.unknown:
  //       if (error.error is SocketException) {
  //         errorResponse["message"] = "No Internet connection.";
  //       } else {
  //         errorResponse["message"] = "Unexpected error occurred.";
  //       }
  //       break;
  //
  //     default:
  //       errorResponse["message"] = "Something went wrong.";
  //       break;
  //   }
  //
  //   if (kDebugMode) {
  //     print("Dio Error: $errorResponse");
  //   }
  //
  //   throw FetchDataException(errorResponse["message"]);
  // }

  dynamic handleDioError(DioException error) {
    if (kDebugMode) {
      print("API ERROR: ${error.response?.data ?? error.message}");
    }

    Map<String, dynamic> errorResponse = {
      "status": 0,
      "message": "Something went wrong",
    };

    if (error.response != null) {
      var data = error.response?.data;
      if (data is Map<String, dynamic>) {
        errorResponse["message"] = data["message"] ?? "Unknown error";
      } else if (data is Set<String>) {
        errorResponse["message"] = "Expected a Map but got a Set.";
      } else {
        errorResponse["message"] = "Unexpected response format.";
      }
    } else {
      errorResponse["message"] = "No response from server.";
    }

    return errorResponse;
  }

  void handleTimeoutException() {
    throw TimeoutException(message: 'Timeout');
  }

  void handleBadRequest(dynamic data) {
    final message = data is Map<String, dynamic> && data.containsKey('message')
        ? data['message']
        : data;
    SnackBar.error(message: '$message');
    throw BadRequestException(message, 400);
  }

  void handleUnauthorized(dynamic data) {
    final message = data is Map<String, dynamic> && data.containsKey('message')
        ? data['message']
        : data;
    SnackBar.error(message: '$message');
    throw UnauthorizedException(message, 401);
  }

  void handleForbidden(dynamic data) {
    final message = data is Map<String, dynamic> && data.containsKey('message')
        ? data['message']
        : data;
    SnackBar.error(message: '$message');
    throw UnauthorizedException(message, 403);
  }

  void handleNotFound(String message) {
    SnackBar.error(message: message);

    throw FetchDataException(message, 404);
  }

  void handleGenericBadResponse(int? statusCode, dynamic data) {
    SnackBar.error(message: 'Received invalid status code: $statusCode');
    // errorSnackBar(message: 'Received invalid status code: $statusCode');
    log('\x1B[91m[Error Response ($statusCode)] => $data\x1B[0m');
    throw FetchDataException('Received invalid status code: $statusCode');
  }

  void handleGenericError(error, StackTrace stackTrace) {
    if (error.toString().contains('Connection closed while receiving data')) {
      SnackBar.error(
        message: 'An error occurred while communicating with the server',
      );
      // errorSnackBar(message: 'An error occurred while communicating with the server');
    } else if (error.toString().contains(
      'Connection closed before full header was received',
    )) {
      log('\x1B[91m[Handle Generic Error] => Request Canceled\x1B[0m');
    } else {
      SnackBar.error(message: 'Server error');
      // errorSnackBar(message: 'Server error');
    }
    throw FetchDataException('Server Error');
  }

  dynamic _response(Response response) async {
    switch (response.statusCode) {
      // Successfully get api response
      case 200:
      case 201:
      case 202:
        return response.data;
      // No content
      case 204:
        log('\x1B[91m[No Content (204)] => ${response.data}\x1B[0m');
        return;
      // Bad request need to check url
      case 400:
        handleBadRequest(response.data);
        return response.data;
      // Unauthorized
      case 401:
        handleUnauthorized(response.data);
        break;
      // Authorisation token invalid
      case 403:
        handleForbidden(response.data);
        break;
      // Not Found
      case 404:
        log('\x1B[91m[Not Found (404)] => ${response.data}\x1B[0m');
        break;
      // Conflict
      case 409:
        log('\x1B[91m[Conflict (409)] => ${response.data}\x1B[0m');
        break;
      // Error occurred while communication with server
      case 500:
      default:
        SnackBar.error(
          message:
              'An error occurred while communicating to server with status code: ${response.statusCode}',
        );
        // errorSnackBar(message: 'An error occurred while communicating to server with status code: ${response.statusCode}');
        log(
          '\x1B[91m[Internal Server Error (${response.statusCode})] => ${response.data}\x1B[0m',
        );
        throw FetchDataException(
          'Error occurred with code : ${response.statusCode}',
        );
    }
  }

  // Helper function to log API call details
  void logAPICallDetails(Response response) {
    log(
      '\x1B[90m<--------------------------- [API CALL] --------------------------->\x1B[0m',
    );
    log('\x1B[94m[Method] => \x1B[95m${response.requestOptions.method}\x1B[0m');
    log(
      '\x1B[94m[Headers] => \x1B[95m${response.requestOptions.headers}\x1B[0m',
    );
    log('\x1B[94m[Url] => \x1B[95m${response.requestOptions.uri}\x1B[0m');
    if (response.requestOptions.method == 'POST' ||
        response.requestOptions.method == 'PUT') {
      var data = response.requestOptions.data;
      if (data is FormData) {
        log('\x1B[94m[Body] => \x1B[95mFormData\x1B[0m');
        for (var element in data.fields) {
          log('\x1B[94m[${element.key}] => \x1B[95m${element.value}\x1B[0m');
        }
        for (var element in data.files) {
          log(
            '\x1B[94m[${element.key}] => \x1B[95m${element.value.filename}\x1B[0m',
          );
        }
      } else {
        log('\x1B[94m[Body] => \x1B[95m${json.encode(data)}\x1B[0m');
      }
    }
    if (response.statusCode != null && (response.statusCode! - 200) < 10) {
      log(
        '\x1B[94m[Response (${response.statusCode})] => \x1B[96m$response\x1B[0m',
      );
    }
  }
}
