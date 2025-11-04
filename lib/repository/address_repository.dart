import 'package:flutter/material.dart';
import '../api/api_manager.dart';
import '../models/user_model.dart';
import '../models/api_response_model.dart';

class AddressRepository {
  static final APIManager _apiManager = APIManager();

  // Get all addresses
  static Future<List<UserAddress>> getAddresses({BuildContext? context}) async {
    try {
      final response = await _apiManager.getAPICall(
        url: '/customers/addresses',
        context: context,
      );

      final apiResponse = ApiResponse.fromJson(response);
      if (apiResponse.isSuccess && apiResponse.data != null) {
        final addressesData = apiResponse.data!['addresses'] as List<dynamic>?;
        if (addressesData != null) {
          return addressesData
              .map((addr) => UserAddress.fromJson(addr))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print("Error in Get Addresses repo: ${e.toString()}");
      rethrow;
    }
  }

  // Add new address
  static Future<ApiResponse?> addAddress({
    required Map<String, dynamic> addressData,
    BuildContext? context,
  }) async {
    try {
      final response = await _apiManager.postAPICall(
        url: '/customers/addresses',
        params: addressData,
        context: context,
      );
      ApiResponse? apiResponse = ApiResponse.fromJson(response);
      return apiResponse;
    } catch (e) {
      print("Error in Add Address repo: ${e.toString()}");
      rethrow;
    }
  }

  // Update address
  static Future<ApiResponse?> updateAddress({
    required int addressIndex,
    required Map<String, dynamic> addressData,
    BuildContext? context,
  }) async {
    try {
      final response = await _apiManager.putAPICall(
        url: '/customers/addresses/$addressIndex',
        params: addressData,
        context: context,
      );
      ApiResponse? apiResponse = ApiResponse.fromJson(response);
      return apiResponse;
    } catch (e) {
      print("Error in Update Address repo: ${e.toString()}");
      rethrow;
    }
  }

  // Delete address
  static Future<ApiResponse?> deleteAddress({
    required int addressIndex,
    BuildContext? context,
  }) async {
    try {
      final response = await _apiManager.deleteAPICall(
        url: '/customers/addresses/$addressIndex',
        context: context,
      );
      ApiResponse? apiResponse = ApiResponse.fromJson(response);
      return apiResponse;
    } catch (e) {
      print("Error in Delete Address repo: ${e.toString()}");
      rethrow;
    }
  }

  // Set default address
  static Future<ApiResponse?> setDefaultAddress({
    required int addressIndex,
    BuildContext? context,
  }) async {
    try {
      final response = await _apiManager.putAPICall(
        url: '/customers/addresses/$addressIndex/default',
        params: {},
        context: context,
      );
      ApiResponse? apiResponse = ApiResponse.fromJson(response);
      return apiResponse;
    } catch (e) {
      print("Error in Set Default Address repo: ${e.toString()}");
      rethrow;
    }
  }
}

