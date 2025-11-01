import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../repository/dashboard_repository.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

class DashboardController extends GetxController {
  // Observable variables
  final isLoading = false.obs;
  final isBannersLoading = false.obs;
  final banners = <Map<String, dynamic>>[].obs;
  final featuredCategories = <CategoryModel>[].obs;
  final featuredProducts = <ProductModel>[].obs;
  final trendingProducts = <ProductModel>[].obs;
  final newArrivals = <ProductModel>[].obs;
  final bestSellers = <ProductModel>[].obs;
  final offers = <Map<String, dynamic>>[].obs;
  final notifications = <Map<String, dynamic>>[].obs;
  final appSettings = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    // Dashboard data will be loaded from the dashboard screen
    // after successful authentication
  }

  // Load dashboard data
  Future<void> loadDashboardData({BuildContext? context}) async {
    try {
      // Add a small delay to ensure we're not in the build phase
      await Future.delayed(Duration(milliseconds: 100));
      isLoading.value = true;

      // Load all dashboard data in parallel
      await Future.wait([
        loadBanners(context: context),
        loadFeaturedCategories(context: context),
        loadFeaturedProducts(context: context),
        loadTrendingProducts(context: context),
        loadNewArrivals(context: context),
        // loadBestSellers(context: context),
        // loadOffers(context: context),
        // loadNotifications(context: context),
        // loadAppSettings(context: context),
      ]);
    } catch (e) {
      if (context != null) {
        _showErrorMessage(context, 'Failed to load dashboard data');
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Load banners
  Future<void> loadBanners({BuildContext? context}) async {
    try {
      isBannersLoading.value = true;
      final bannersData = await DashboardRepository.getBanners(
        context: context,
      );
      banners.value = bannersData;
    } catch (e) {
      if (context != null) {
        _showErrorMessage(context, 'Failed to load banners');
      }
    } finally {
      isBannersLoading.value = false;
    }
  }

  // Load featured categories
  Future<void> loadFeaturedCategories({BuildContext? context}) async {
    try {
      final categories = await DashboardRepository.getFeaturedCategories(
        context: context,
      );
      featuredCategories.value = categories;
    } catch (e) {
      if (context != null) {
        _showErrorMessage(context, 'Failed to load featured categories');
      }
    }
  }

  // Load featured products
  Future<void> loadFeaturedProducts({BuildContext? context}) async {
    try {
      final products = await DashboardRepository.getFeaturedProducts(
        context: context,
      );
      featuredProducts.value = products;
    } catch (e) {
      if (context != null) {
        _showErrorMessage(context, 'Failed to load featured products');
      }
    }
  }

  // Load trending products
  Future<void> loadTrendingProducts({BuildContext? context}) async {
    try {
      final products = await DashboardRepository.getTrendingProducts(
        context: context,
      );
      print('Trending products loaded: ${products.length}');
      trendingProducts.value = products;
    } catch (e) {
      print('Trending products error: $e');
      if (context != null) {
        _showErrorMessage(context, 'Failed to load trending products');
      }
    }
  }

  // Load new arrivals
  Future<void> loadNewArrivals({BuildContext? context}) async {
    try {
      final products = await DashboardRepository.getNewArrivals(
        context: context,
      );
      print('New arrivals loaded: ${products.length}');
      newArrivals.value = products;
    } catch (e) {
      print('New arrivals error: $e');
      if (context != null) {
        _showErrorMessage(context, 'Failed to load new arrivals');
      }
    }
  }

  // Load best sellers
  Future<void> loadBestSellers({BuildContext? context}) async {
    try {
      final products = await DashboardRepository.getBestSellers(
        context: context,
      );
      print('Best sellers loaded: ${products.length}');
      bestSellers.value = products;
    } catch (e) {
      print('Best sellers error: $e');
      if (context != null) {
        _showErrorMessage(context, 'Failed to load best sellers');
      }
    }
  }

  // Load offers
  Future<void> loadOffers({BuildContext? context}) async {
    try {
      final offersData = await DashboardRepository.getOffers(context: context);
      offers.value = offersData;
    } catch (e) {
      if (context != null) {
        _showErrorMessage(context, 'Failed to load offers');
      }
    }
  }

  // Load notifications
  Future<void> loadNotifications({BuildContext? context}) async {
    try {
      final notificationsData = await DashboardRepository.getNotifications(
        context: context,
      );
      notifications.value = notificationsData;
    } catch (e) {
      if (context != null) {
        _showErrorMessage(context, 'Failed to load notifications');
      }
    }
  }

  // Load app settings
  Future<void> loadAppSettings({BuildContext? context}) async {
    try {
      final settings = await DashboardRepository.getAppSettings(
        context: context,
      );
      if (settings['status'] == 1) {
        appSettings.value = settings['data'] ?? {};
      }
    } catch (e) {
      if (context != null) {
        _showErrorMessage(context, 'Failed to load app settings');
      }
    }
  }

  // Mark notification as read
  Future<void> markNotificationAsRead({
    required String notificationId,
    BuildContext? context,
  }) async {
    try {
      final response = await DashboardRepository.markNotificationAsRead(
        notificationId: notificationId,
        context: context,
      );

      if (response['status'] == 1) {
        // Remove notification from list
        notifications.removeWhere(
          (notification) => notification['id'] == notificationId,
        );
      } else {
        if (context != null) {
          _showErrorMessage(
            context,
            response['message'] ?? 'Failed to mark notification as read',
          );
        }
      }
    } catch (e) {
      if (context != null) {
        _showErrorMessage(context, 'Failed to mark notification as read');
      }
    }
  }

  // Refresh dashboard data
  Future<void> refreshDashboard({BuildContext? context}) async {
    await loadDashboardData(context: context);
  }

  // Helper method to show error messages
  void _showErrorMessage(BuildContext context, String message) {
    // You can implement your preferred error handling here
    // For example, using SnackBar or Toast
    print('Dashboard Error: $message');
  }
}
