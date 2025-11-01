import 'package:flutter/material.dart';
import '../api/api_manager.dart';
import '../models/order_model.dart';
import '../models/api_response_model.dart';

class OrderRepository {
  static final APIManager _apiManager = APIManager();

  // Get all orders for a customer
  static Future<List<OrderModel>> getOrders({
    int page = 1,
    int limit = 20,
    String? status,
    BuildContext? context,
  }) async {
    try {
      final Map<String, dynamic> params = {'page': page, 'limit': limit};

      if (status != null && status.isNotEmpty) {
        params['status'] = status;
      }

      final response = await _apiManager.getAPICall(
        url: '/orders',
        queryParameters: params,
        context: context,
      );

      final apiResponse = ApiResponse.fromJson(response);
      if (apiResponse.isSuccess && apiResponse.data != null) {
        final List<dynamic> ordersData = apiResponse.data!['orders'] ?? [];

        if (ordersData.isEmpty) {
          return [];
        }

        try {
          final orders = ordersData
              .map((order) => OrderModel.fromJson(order))
              .toList();
          return orders;
        } catch (e) {
          print('Error parsing orders: $e');
          return [];
        }
      }
      return [];
    } catch (e) {
      print("Error in Get Orders repo: ${e.toString()}");
      rethrow;
    }
  }

  // Get order by ID
  static Future<OrderModel?> getOrderById({
    required String orderId,
    BuildContext? context,
  }) async {
    try {
      final response = await _apiManager.getAPICall(
        url: '/orders/$orderId',
        context: context,
      );

      final apiResponse = ApiResponse.fromJson(response);
      if (apiResponse.isSuccess && apiResponse.data != null) {
        return OrderModel.fromJson(apiResponse.data!);
      }
      return null;
    } catch (e) {
      print("Error in Get Order by ID repo: ${e.toString()}");
      rethrow;
    }
  }

  // Create new order
  static Future<Map<String, dynamic>> createOrder({
    required Map<String, dynamic> orderData,
    BuildContext? context,
  }) async {
    try {
      final response = await _apiManager.postAPICall(
        url: '/orders',
        params: orderData,
        context: context,
      );
      return response;
    } catch (e) {
      print("Error in Create Order repo: ${e.toString()}");
      rethrow;
    }
  }

  // Update order status (for admin)
  static Future<Map<String, dynamic>> updateOrderStatus({
    required String orderId,
    required String status,
    String? trackingNumber,
    String? notes,
    BuildContext? context,
  }) async {
    try {
      final response = await _apiManager.putAPICall(
        url: '/orders/$orderId/status',
        params: {
          'status': status,
          if (trackingNumber != null) 'trackingNumber': trackingNumber,
          if (notes != null) 'notes': notes,
        },
        context: context,
      );
      return response;
    } catch (e) {
      print("Error in Update Order Status repo: ${e.toString()}");
      rethrow;
    }
  }

  // Cancel order
  static Future<Map<String, dynamic>> cancelOrder({
    required String orderId,
    String? reason,
    BuildContext? context,
  }) async {
    try {
      final response = await _apiManager.putAPICall(
        url: '/orders/$orderId/cancel',
        params: {if (reason != null) 'reason': reason},
        context: context,
      );
      return response;
    } catch (e) {
      print("Error in Cancel Order repo: ${e.toString()}");
      rethrow;
    }
  }

  // Get order statistics
  static Future<Map<String, dynamic>> getOrderStats({
    BuildContext? context,
  }) async {
    try {
      final response = await _apiManager.getAPICall(
        url: '/orders/stats',
        context: context,
      );
      return response;
    } catch (e) {
      print("Error in Get Order Stats repo: ${e.toString()}");
      rethrow;
    }
  }
}
