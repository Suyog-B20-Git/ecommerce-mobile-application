import 'package:flutter/material.dart';
import '../api/api_manager.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

class DashboardRepository {
  static final APIManager _apiManager = APIManager();

  // Get Dashboard Data
  static Future<Map<String, dynamic>> getDashboardData({
    int limit = 20,
    BuildContext? context,
  }) async {
    final response = await _apiManager.getAPICall(
      url: '/dashboard',
      queryParameters: {'limit': limit},
      context: context,
    );
    return response;
  }

  // Get Banner/Slider Data
  static Future<List<Map<String, dynamic>>> getBanners({
    BuildContext? context,
  }) async {
    final response = await _apiManager.getAPICall(
      url: '/banners',
      context: context,
    );

    if (response != null && response['status'] == 1) {
      final List<dynamic> bannersData = response['data'] ?? [];
      return bannersData.cast<Map<String, dynamic>>();
    }
    return [];
  }

  // Get Featured Categories
  static Future<List<CategoryModel>> getFeaturedCategories({
    int limit = 8,
    BuildContext? context,
  }) async {
    final response = await _apiManager.getAPICall(
      url: '/dashboard/categories',
      queryParameters: {'limit': limit},
      context: context,
    );

    if (response != null && response['status'] == 1) {
      final List<dynamic> categoriesData = response['data'] ?? [];
      return categoriesData
          .map((json) => CategoryModel.fromJson(json))
          .toList();
    }
    return [];
  }

  // Get Featured Products
  static Future<List<ProductModel>> getFeaturedProducts({
    int limit = 10,
    BuildContext? context,
  }) async {
    final response = await _apiManager.getAPICall(
      url: '/dashboard/products/featured',
      queryParameters: {'limit': limit},
      context: context,
    );

    if (response != null && response['status'] == 1) {
      final List<dynamic> productsData = response['data'] ?? [];
      return productsData.map((json) => ProductModel.fromJson(json)).toList();
    }
    return [];
  }

  // Get Trending Products
  static Future<List<ProductModel>> getTrendingProducts({
    int limit = 10,
    BuildContext? context,
  }) async {
    final response = await _apiManager.getAPICall(
      url: '/dashboard/products/trending',
      queryParameters: {'limit': limit},
      context: context,
    );

    if (response != null && response['status'] == 1) {
      final List<dynamic> productsData = response['data'] ?? [];
      return productsData.map((json) => ProductModel.fromJson(json)).toList();
    }
    return [];
  }

  // Get New Arrivals
  static Future<List<ProductModel>> getNewArrivals({
    int limit = 10,
    BuildContext? context,
  }) async {
    final response = await _apiManager.getAPICall(
      url: '/dashboard/products/new',
      queryParameters: {'limit': limit},
      context: context,
    );

    if (response != null && response['status'] == 1) {
      final List<dynamic> productsData = response['data'] ?? [];
      return productsData.map((json) => ProductModel.fromJson(json)).toList();
    }
    return [];
  }

  // Get Best Sellers
  static Future<List<ProductModel>> getBestSellers({
    int limit = 10,
    BuildContext? context,
  }) async {
    final response = await _apiManager.getAPICall(
      url: '/dashboard/products/bestsellers',
      queryParameters: {'limit': limit},
      context: context,
    );

    if (response != null && response['status'] == 1) {
      final List<dynamic> productsData = response['data'] ?? [];
      return productsData.map((json) => ProductModel.fromJson(json)).toList();
    }
    return [];
  }

  // Get Offers/Deals
  static Future<List<Map<String, dynamic>>> getOffers({
    BuildContext? context,
  }) async {
    final response = await _apiManager.getAPICall(
      url: '/offers',
      context: context,
    );

    if (response != null && response['status'] == 1) {
      final List<dynamic> offersData = response['data'] ?? [];
      return offersData.cast<Map<String, dynamic>>();
    }
    return [];
  }

  // Get Notifications
  static Future<List<Map<String, dynamic>>> getNotifications({
    int page = 1,
    int limit = 20,
    BuildContext? context,
  }) async {
    final response = await _apiManager.getAPICall(
      url: '/notifications',
      queryParameters: {'page': page, 'limit': limit},
      context: context,
    );

    if (response != null && response['status'] == 1) {
      final List<dynamic> notificationsData = response['data'] ?? [];
      return notificationsData.cast<Map<String, dynamic>>();
    }
    return [];
  }

  // Mark Notification as Read
  static Future<Map<String, dynamic>> markNotificationAsRead({
    required String notificationId,
    BuildContext? context,
  }) async {
    final response = await _apiManager.putAPICall(
      url: '/notifications/$notificationId/read',
      context: context,
    );
    return response;
  }

  // Get App Settings
  static Future<Map<String, dynamic>> getAppSettings({
    BuildContext? context,
  }) async {
    final response = await _apiManager.getAPICall(
      url: '/settings',
      context: context,
    );
    return response;
  }
}
