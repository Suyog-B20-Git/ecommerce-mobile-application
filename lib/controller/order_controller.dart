import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/order_model.dart';
import '../repository/order_repository.dart';
import '../widgets/snackbar.dart' as CustomSnackBar;
import '../widgets/toastification.dart';

class OrderController extends GetxController {
  // Observable orders list
  final RxList<OrderModel> orders = <OrderModel>[].obs;

  // Observable loading state
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxBool hasMoreOrders = true.obs;

  @override
  void onInit() {
    super.onInit();
    // Don't load orders automatically to avoid build-time reactive updates
    // Orders will be loaded when the orders screen is opened
  }

  // Load orders from API
  Future<void> loadOrders({
    BuildContext? context,
    bool refresh = false,
    String? status,
  }) async {
    try {
      if (refresh) {
        currentPage.value = 1;
        orders.clear();
        hasMoreOrders.value = true;
      }

      if (currentPage.value == 1) {
        isLoading.value = true;
      } else {
        isLoadingMore.value = true;
      }

      final ordersList = await OrderRepository.getOrders(
        page: currentPage.value,
        limit: 20,
        status: status,
        context: context,
      );

      if (refresh || currentPage.value == 1) {
        orders.value = ordersList;
      } else {
        orders.addAll(ordersList);
      }

      // Check if there are more orders
      hasMoreOrders.value = ordersList.length >= 20;
      if (hasMoreOrders.value) {
        currentPage.value++;
      }
    } catch (e) {
      print('Error loading orders: $e');
      if (context != null) {
        CustomSnackBar.SnackBar.error(
          title: 'Error',
          message: 'Failed to load orders',
        );
      }
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  // Load more orders (pagination)
  Future<void> loadMoreOrders({BuildContext? context, String? status}) async {
    if (!hasMoreOrders.value || isLoadingMore.value) return;

    await loadOrders(context: context, status: status);
  }

  // Create new order from data (for API calls)
  Future<bool> createOrderFromData(
    Map<String, dynamic> orderData, {
    BuildContext? context,
  }) async {
    try {
      isLoading.value = true;

      final response = await OrderRepository.createOrder(
        orderData: orderData,
        context: context,
      );

      if (response['status'] == 1) {
        // Reload orders to get updated list
        await loadOrders(context: context, refresh: true);

        if (context != null) {
          ToastHelper.showSuccessToast('Order placed successfully!');
        }
        return true;
      } else {
        if (context != null) {
          CustomSnackBar.SnackBar.error(
            title: 'Error',
            message: response['message'] ?? 'Failed to create order',
          );
        }
        return false;
      }
    } catch (e) {
      print('Error creating order: $e');
      if (context != null) {
        CustomSnackBar.SnackBar.error(
          title: 'Error',
          message: 'Failed to create order. Please try again.',
        );
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Create new order
  Future<bool> createOrder(OrderModel order, {BuildContext? context}) async {
    try {
      print('Creating order: ${order.toJson()}');
      isLoading.value = true;

      final response = await OrderRepository.createOrder(
        orderData: order.toJson(),
        context: context,
      );

      print('Create order response: $response');

      if (response['status'] == 1) {
        print('Order created successfully, reloading orders...');
        // Reload orders to get updated list
        await loadOrders(context: context, refresh: true);

        if (context != null) {
          ToastHelper.showSuccessToast('Order placed successfully!');
        }
        return true;
      } else {
        print('Order creation failed: ${response['message']}');
        if (context != null) {
          CustomSnackBar.SnackBar.error(
            title: 'Error',
            message: response['message'] ?? 'Failed to create order',
          );
        }
        return false;
      }
    } catch (e) {
      print('Error creating order: $e');
      if (context != null) {
        CustomSnackBar.SnackBar.error(
          title: 'Error',
          message: 'Failed to create order. Please try again.',
        );
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Update order status
  Future<bool> updateOrderStatus(
    String orderId,
    String status, {
    String? trackingNumber,
    String? notes,
    BuildContext? context,
  }) async {
    try {
      isLoading.value = true;

      final response = await OrderRepository.updateOrderStatus(
        orderId: orderId,
        status: status,
        trackingNumber: trackingNumber,
        notes: notes,
        context: context,
      );

      if (response['status'] == 1) {
        // Update local order
        final orderIndex = orders.indexWhere((order) => order.id == orderId);
        if (orderIndex != -1) {
          orders[orderIndex] = orders[orderIndex].copyWith(
            status: status,
            trackingNumber: trackingNumber,
            notes: notes,
            updatedAt: DateTime.now(),
          );
        }

        if (context != null) {
          ToastHelper.showSuccessToast('Order status updated successfully!');
        }
        return true;
      } else {
        if (context != null) {
          CustomSnackBar.SnackBar.error(
            title: 'Error',
            message: response['message'] ?? 'Failed to update order status',
          );
        }
        return false;
      }
    } catch (e) {
      print('Error updating order: $e');
      if (context != null) {
        CustomSnackBar.SnackBar.error(
          title: 'Error',
          message: 'Failed to update order status.',
        );
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Cancel order
  Future<bool> cancelOrder(
    String orderId, {
    String? reason,
    BuildContext? context,
  }) async {
    try {
      isLoading.value = true;

      final response = await OrderRepository.cancelOrder(
        orderId: orderId,
        reason: reason,
        context: context,
      );

      if (response['status'] == 1) {
        // Update local order
        final orderIndex = orders.indexWhere((order) => order.id == orderId);
        if (orderIndex != -1) {
          orders[orderIndex] = orders[orderIndex].copyWith(
            status: 'cancelled',
            notes: reason,
            updatedAt: DateTime.now(),
          );
        }

        if (context != null) {
          ToastHelper.showSuccessToast('Order cancelled successfully!');
        }
        return true;
      } else {
        if (context != null) {
          CustomSnackBar.SnackBar.error(
            title: 'Error',
            message: response['message'] ?? 'Failed to cancel order',
          );
        }
        return false;
      }
    } catch (e) {
      print('Error cancelling order: $e');
      if (context != null) {
        CustomSnackBar.SnackBar.error(
          title: 'Error',
          message: 'Failed to cancel order.',
        );
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Get order by ID
  Future<OrderModel?> getOrderById(
    String orderId, {
    BuildContext? context,
  }) async {
    try {
      // First check local orders
      final localOrder = orders.firstWhereOrNull(
        (order) => order.id == orderId,
      );
      if (localOrder != null) {
        return localOrder;
      }

      // If not found locally, fetch from API
      return await OrderRepository.getOrderById(
        orderId: orderId,
        context: context,
      );
    } catch (e) {
      print('Error getting order by ID: $e');
      return null;
    }
  }

  // Get orders by status
  List<OrderModel> getOrdersByStatus(String status) {
    return orders.where((order) => order.status == status).toList();
  }

  // Get order statistics
  Map<String, int> getOrderStats() {
    final stats = <String, int>{};
    for (final order in orders) {
      stats[order.status] = (stats[order.status] ?? 0) + 1;
    }
    return stats;
  }

  // Refresh orders
  Future<void> refreshOrders({BuildContext? context, String? status}) async {
    await loadOrders(context: context, refresh: true, status: status);
  }
}
