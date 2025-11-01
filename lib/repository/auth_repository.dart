import 'package:flutter/material.dart';
import '../api/api_manager.dart';
import '../models/user_model.dart';
import '../models/login_response_model.dart';
import '../models/register_response_model.dart';
import '../models/api_response_model.dart';

class AuthRepository {
  static final APIManager _apiManager = APIManager();

  // Register Customer
  static Future<RegisterResponseModel?> registerCustomer({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? referralCode,
    BuildContext? context,
  }) async {
    try {
      final response = await _apiManager.postAPICall(
        url: '/customers/register',
        params: {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          if (referralCode != null) 'referralCode': referralCode,
        },
        context: context,
      );
      RegisterResponseModel? registerModel = RegisterResponseModel.fromJson(
        response,
      );
      return registerModel;
    } catch (e) {
      print("Error in Register repo: ${e.toString()}");
      rethrow;
    }
  }

  // Login Customer
  static Future<LoginResponseModel?> loginCustomer({
    required String email,
    required String password,
    BuildContext? context,
  }) async {
    try {
      final response = await _apiManager.postAPICall(
        url: '/customers/login',
        params: {'email': email, 'password': password},
        context: context,
      );
      LoginResponseModel? loginModel = LoginResponseModel.fromJson(response);
      return loginModel;
    } catch (e) {
      print("Error in Login repo: ${e.toString()}");
      rethrow;
    }
  }

  // Get Profile
  static Future<UserModel?> getProfile({BuildContext? context}) async {
    try {
      final response = await _apiManager.getAPICall(
        url: '/customers/profile',
        context: context,
      );

      final apiResponse = ApiResponse.fromJson(response);
      if (apiResponse.isSuccess && apiResponse.data != null) {
        // The user data is nested under 'user' key
        final userData = apiResponse.data!['user'];
        if (userData != null) {
          return UserModel.fromJson(userData);
        }
      }
      return null;
    } catch (e) {
      print("Error in Get Profile repo: ${e.toString()}");
      rethrow;
    }
  }

  // Update Profile
  static Future<ApiResponse?> updateProfile({
    required Map<String, dynamic> profileData,
    BuildContext? context,
  }) async {
    try {
      final response = await _apiManager.putAPICall(
        url: '/customers/profile',
        params: profileData,
        context: context,
      );
      ApiResponse? apiResponse = ApiResponse.fromJson(response);
      return apiResponse;
    } catch (e) {
      print("Error in Update Profile repo: ${e.toString()}");
      rethrow;
    }
  }

  // Forgot Password
  static Future<ApiResponse?> forgotPassword({
    required String email,
    BuildContext? context,
  }) async {
    try {
      final response = await _apiManager.postAPICall(
        url: '/customers/forgot-password',
        params: {'email': email},
        context: context,
      );
      ApiResponse? apiResponse = ApiResponse.fromJson(response);
      return apiResponse;
    } catch (e) {
      print("Error in Forgot Password repo: ${e.toString()}");
      rethrow;
    }
  }

  // Reset Password
  static Future<ApiResponse?> resetPassword({
    required String token,
    required String password,
    BuildContext? context,
  }) async {
    try {
      final response = await _apiManager.postAPICall(
        url: '/customers/reset-password',
        params: {'token': token, 'password': password},
        context: context,
      );
      ApiResponse? apiResponse = ApiResponse.fromJson(response);
      return apiResponse;
    } catch (e) {
      print("Error in Reset Password repo: ${e.toString()}");
      rethrow;
    }
  }

  // Change Password
  static Future<ApiResponse?> changePassword({
    required String currentPassword,
    required String newPassword,
    BuildContext? context,
  }) async {
    try {
      final response = await _apiManager.putAPICall(
        url: '/customers/change-password',
        params: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
        context: context,
      );
      ApiResponse? apiResponse = ApiResponse.fromJson(response);
      return apiResponse;
    } catch (e) {
      print("Error in Change Password repo: ${e.toString()}");
      rethrow;
    }
  }

  // Logout
  static Future<ApiResponse?> logout({BuildContext? context}) async {
    try {
      final response = await _apiManager.postAPICall(
        url: '/customers/logout',
        context: context,
      );
      ApiResponse? apiResponse = ApiResponse.fromJson(response);
      return apiResponse;
    } catch (e) {
      print("Error in Logout repo: ${e.toString()}");
      rethrow;
    }
  }

  // Social Login
  static Future<LoginResponseModel?> socialLogin({
    required String provider,
    required String token,
    BuildContext? context,
  }) async {
    try {
      final response = await _apiManager.postAPICall(
        url: '/customers/social-login',
        params: {'provider': provider, 'token': token},
        context: context,
      );
      LoginResponseModel? loginModel = LoginResponseModel.fromJson(response);
      return loginModel;
    } catch (e) {
      print("Error in Social Login repo: ${e.toString()}");
      rethrow;
    }
  }
}
