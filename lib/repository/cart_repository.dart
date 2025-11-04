import 'package:flutter/material.dart';
import '../api/api_manager.dart';
import '../models/cart_model.dart';

class CartRepository {
  static final APIManager _apiManager = APIManager();

  // Get Cart
  static Future<CartModel?> getCart({
    int page = 1,
    int limit = 20,
    BuildContext? context,
  }) async {
    final response = await _apiManager.getAPICall(
      url: '/cart?page=$page&limit=$limit',
      context: context,
    );

    if (response != null && response['status'] == 1) {
      return CartModel.fromJson(response['data']);
    }
    return null;
  }

  // Get Cart with Pagination Info
  static Future<Map<String, dynamic>?> getCartWithPagination({
    int page = 1,
    int limit = 20,
    BuildContext? context,
  }) async {
    final response = await _apiManager.getAPICall(
      url: '/cart?page=$page&limit=$limit',
      context: context,
    );

    if (response != null && response['status'] == 1) {
      return {
        'cart': CartModel.fromJson(response['data']),
        'pagination':
            response['pagination'] ??
            {
              'currentPage': page,
              'totalPages': 1,
              'totalItems': 0,
              'hasNext': false,
            },
      };
    }
    return null;
  }

  // Add to Cart
  static Future<Map<String, dynamic>> addToCart({
    required String productId,
    required int quantity,
    String? variantId,
    Map<String, dynamic>? variantAttributes,
    BuildContext? context,
  }) async {
    // Debug logs for add to cart payload
    try {
      print(
        '[CartRepository] AddToCart payload => productId: ' +
            productId +
            ', quantity: ' +
            quantity.toString() +
            ', variantId: ' +
            (variantId?.toString() ?? 'null') +
            ', variantAttributes: ' +
            (variantAttributes?.toString() ?? 'null'),
      );
    } catch (_) {}

    final response = await _apiManager.postAPICall(
      url: '/cart',
      params: {
        'productId': productId,
        'quantity': quantity,
        if (variantId != null) 'variantId': variantId,
        if (variantAttributes != null) 'variantAttributes': variantAttributes,
      },
      context: context,
    );
    try {
      print('[CartRepository] AddToCart response => ' + response.toString());
    } catch (_) {}
    return response;
  }

  // Update Cart Item
  static Future<Map<String, dynamic>> updateCartItem({
    required String itemId,
    required int quantity,
    BuildContext? context,
  }) async {
    final response = await _apiManager.putAPICall(
      url: '/cart/$itemId',
      params: {'quantity': quantity},
      context: context,
    );
    return response;
  }

  // Remove from Cart
  static Future<Map<String, dynamic>> removeFromCart({
    required String itemId,
    BuildContext? context,
  }) async {
    final response = await _apiManager.deleteAPICall(
      url: '/cart/$itemId',
      context: context,
    );
    return response;
  }

  // Clear Cart
  static Future<Map<String, dynamic>> clearCart({BuildContext? context}) async {
    final response = await _apiManager.deleteAPICall(
      url: '/cart',
      context: context,
    );
    return response;
  }

  // Apply Coupon
  static Future<Map<String, dynamic>> applyCoupon({
    required String couponCode,
    BuildContext? context,
  }) async {
    final response = await _apiManager.postAPICall(
      url: '/cart/apply-coupon',
      params: {'couponCode': couponCode},
      context: context,
    );
    return response;
  }

  // Remove Coupon
  static Future<Map<String, dynamic>> removeCoupon({
    BuildContext? context,
  }) async {
    final response = await _apiManager.deleteAPICall(
      url: '/cart/remove-coupon',
      context: context,
    );
    return response;
  }

  // Get Cart Count
  static Future<int> getCartCount({BuildContext? context}) async {
    final response = await _apiManager.getAPICall(
      url: '/cart/count',
      context: context,
    );

    if (response != null && response['status'] == 1) {
      return response['data']['count'] ?? 0;
    }
    return 0;
  }
}
