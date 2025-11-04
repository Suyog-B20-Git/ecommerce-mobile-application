import 'package:flutter/material.dart';
import '../api/api_manager.dart';
import '../models/product_model.dart';

class WishlistRepository {
  static final APIManager _apiManager = APIManager();

  // Get Wishlist with pagination
  static Future<Map<String, dynamic>> getWishlist({
    int page = 1,
    int limit = 10,
    BuildContext? context,
  }) async {
    final response = await _apiManager.getAPICall(
      url: '/wishlist?page=$page&limit=$limit',
      context: context,
    );

    if (response != null && response['status'] == 1) {
      final List<dynamic> productsData = response['data'] ?? [];
      final products = productsData
          .map((json) => ProductModel.fromJson(json))
          .toList();
      final pagination = response['pagination'] ?? {};
      return {
        'products': products,
        'pagination': pagination,
      };
    }
    return {
      'products': <ProductModel>[],
      'pagination': {'page': page, 'limit': limit, 'total': 0, 'pages': 0},
    };
  }

  // Add to Wishlist
  static Future<Map<String, dynamic>> addToWishlist({
    required String productId,
    BuildContext? context,
  }) async {
    final response = await _apiManager.postAPICall(
      url: '/wishlist',
      params: {'productId': productId},
      context: context,
    );
    return response;
  }

  // Remove from Wishlist
  static Future<Map<String, dynamic>> removeFromWishlist({
    required String productId,
    BuildContext? context,
  }) async {
    final response = await _apiManager.deleteAPICall(
      url: '/wishlist/$productId',
      context: context,
    );
    return response;
  }

  // Clear Wishlist
  static Future<Map<String, dynamic>> clearWishlist({
    BuildContext? context,
  }) async {
    final response = await _apiManager.deleteAPICall(
      url: '/wishlist',
      context: context,
    );
    return response;
  }

  // Check if Product is in Wishlist
  static Future<bool> isInWishlist({
    required String productId,
    BuildContext? context,
  }) async {
    final response = await _apiManager.getAPICall(
      url: '/wishlist/check/$productId',
      context: context,
    );

    if (response != null && response['status'] == 1) {
      return response['data']['isInWishlist'] ?? false;
    }
    return false;
  }

  // Get Wishlist Count
  static Future<int> getWishlistCount({BuildContext? context}) async {
    final response = await _apiManager.getAPICall(
      url: '/wishlist/count',
      context: context,
    );

    if (response != null && response['status'] == 1) {
      return response['data']['count'] ?? 0;
    }
    return 0;
  }
}
