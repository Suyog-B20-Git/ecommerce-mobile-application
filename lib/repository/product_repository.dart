import 'package:flutter/material.dart';
import '../api/api_manager.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

class ProductRepository {
  static final APIManager _apiManager = APIManager();

  // Get Categories
  static Future<List<CategoryModel>> getCategories({
    BuildContext? context,
  }) async {
    final response = await _apiManager.getAPICall(
      url: '/categories',
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

  // Get Category Products
  static Future<List<ProductModel>> getCategoryProducts({
    required String categoryId,
    int page = 1,
    int limit = 20,
    BuildContext? context,
  }) async {
    final response = await _apiManager.getAPICall(
      url: '/categories/$categoryId/products',
      queryParameters: {'page': page, 'limit': limit},
      context: context,
    );

    if (response != null && response['status'] == 1) {
      final List<dynamic> productsData = response['data'] ?? [];
      return productsData.map((json) => ProductModel.fromJson(json)).toList();
    }
    return [];
  }

  // Get Products
  static Future<List<ProductModel>> getProducts({
    int page = 1,
    int limit = 20,
    String? search,
    String? category,
    String? sortBy,
    String? sortOrder,
    BuildContext? context,
  }) async {
    final queryParams = <String, dynamic>{'page': page, 'limit': limit};

    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (category != null && category.isNotEmpty)
      queryParams['category'] = category;
    if (sortBy != null && sortBy.isNotEmpty) queryParams['sortBy'] = sortBy;
    if (sortOrder != null && sortOrder.isNotEmpty)
      queryParams['sortOrder'] = sortOrder;

    final response = await _apiManager.getAPICall(
      url: '/products',
      queryParameters: queryParams,
      context: context,
    );

    if (response != null && response['status'] == 1) {
      final List<dynamic> productsData = response['data'] ?? [];
      return productsData.map((json) => ProductModel.fromJson(json)).toList();
    }
    return [];
  }

  // Get Product Details
  static Future<ProductModel?> getProduct({
    required String productId,
    BuildContext? context,
  }) async {
    try {
      print('Fetching product with ID: $productId');
      final response = await _apiManager.getAPICall(
        url: '/products/$productId',
        context: context,
      );

      if (response != null && response['status'] == 1) {
        print('Product found successfully');
        return ProductModel.fromJson(response['data']);
      } else {
        print(
          'Product not found or API error: ${response?['message'] ?? 'Unknown error'}',
        );
        return null;
      }
    } catch (e) {
      print('Error fetching product: $e');
      return null;
    }
  }

  // Search Products
  static Future<List<ProductModel>> searchProducts({
    required String query,
    int page = 1,
    int limit = 20,
    String? category,
    String? sortBy,
    String? sortOrder,
    BuildContext? context,
  }) async {
    final queryParams = <String, dynamic>{
      'q': query,
      'page': page,
      'limit': limit,
    };

    if (category != null && category.isNotEmpty)
      queryParams['category'] = category;
    if (sortBy != null && sortBy.isNotEmpty) queryParams['sortBy'] = sortBy;
    if (sortOrder != null && sortOrder.isNotEmpty)
      queryParams['sortOrder'] = sortOrder;

    final response = await _apiManager.getAPICall(
      url: '/products/search',
      queryParameters: queryParams,
      context: context,
    );

    if (response != null && response['status'] == 1) {
      final List<dynamic> productsData = response['data'] ?? [];
      return productsData.map((json) => ProductModel.fromJson(json)).toList();
    }
    return [];
  }

  // Get Featured Products
  static Future<List<ProductModel>> getFeaturedProducts({
    int limit = 10,
    BuildContext? context,
  }) async {
    final response = await _apiManager.getAPICall(
      url: '/products/featured',
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
      url: '/products/trending',
      queryParameters: {'limit': limit},
      context: context,
    );

    if (response != null && response['status'] == 1) {
      final List<dynamic> productsData = response['data'] ?? [];
      return productsData.map((json) => ProductModel.fromJson(json)).toList();
    }
    return [];
  }

  // Get Related Products (using same category)
  static Future<List<ProductModel>> getRelatedProducts({
    required String productId,
    int limit = 5,
    BuildContext? context,
  }) async {
    // First get the product to find its category
    final product = await getProduct(productId: productId, context: context);
    if (product == null) return [];

    // Get products from the same category, excluding the current product
    final response = await _apiManager.getAPICall(
      url: '/products',
      queryParameters: {
        'category': product.categoryId,
        'limit': limit + 1, // Get one extra to exclude current product
        'page': 1,
      },
      context: context,
    );

    if (response != null && response['status'] == 1) {
      final List<dynamic> productsData = response['data'] ?? [];
      final products = productsData
          .map((json) => ProductModel.fromJson(json))
          .toList();

      // Filter out the current product and limit results
      final relatedProducts = products
          .where((p) => p.id != productId)
          .take(limit)
          .toList();

      return relatedProducts;
    }
    return [];
  }
}
