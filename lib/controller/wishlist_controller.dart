import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../repository/wishlist_repository.dart';
import '../models/product_model.dart';

class WishlistController extends GetxController {
  // Observable variables
  final isLoading = false.obs;
  final wishlistItems = <ProductModel>[].obs;
  final wishlistCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadWishlist();
  }

  // Load wishlist
  Future<void> loadWishlist({BuildContext? context}) async {
    try {
      isLoading.value = true;
      final products = await WishlistRepository.getWishlist(context: context);
      wishlistItems.value = products;
      wishlistCount.value = products.length;
    } catch (e) {
      if (context != null) {
        _showErrorMessage(context, 'Failed to load wishlist');
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Add to wishlist
  Future<void> addToWishlist({
    required ProductModel product,
    BuildContext? context,
  }) async {
    try {
      isLoading.value = true;

      final response = await WishlistRepository.addToWishlist(
        productId: product.id,
        context: context,
      );

      if (response['status'] == 1) {
        // Add product to local wishlist
        if (!wishlistItems.any((item) => item.id == product.id)) {
          wishlistItems.add(product);
          wishlistCount.value = wishlistItems.length;
        }

        if (context != null) {
          _showSuccessMessage(context, 'Added to wishlist');
        }
      } else {
        if (context != null) {
          _showErrorMessage(
            context,
            response['message'] ?? 'Failed to add to wishlist',
          );
        }
      }
    } catch (e) {
      if (context != null) {
        _showErrorMessage(context, 'Failed to add to wishlist');
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Remove from wishlist
  Future<void> removeFromWishlist({
    required String productId,
    BuildContext? context,
  }) async {
    try {
      isLoading.value = true;

      final response = await WishlistRepository.removeFromWishlist(
        productId: productId,
        context: context,
      );

      if (response['status'] == 1) {
        // Remove product from local wishlist
        wishlistItems.removeWhere((item) => item.id == productId);
        wishlistCount.value = wishlistItems.length;

        if (context != null) {
          _showSuccessMessage(context, 'Removed from wishlist');
        }
      } else {
        if (context != null) {
          _showErrorMessage(
            context,
            response['message'] ?? 'Failed to remove from wishlist',
          );
        }
      }
    } catch (e) {
      if (context != null) {
        _showErrorMessage(context, 'Failed to remove from wishlist');
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Clear wishlist
  Future<void> clearWishlist({BuildContext? context}) async {
    try {
      isLoading.value = true;

      final response = await WishlistRepository.clearWishlist(context: context);

      if (response['status'] == 1) {
        wishlistItems.clear();
        wishlistCount.value = 0;

        if (context != null) {
          _showSuccessMessage(context, 'Wishlist cleared');
        }
      } else {
        if (context != null) {
          _showErrorMessage(
            context,
            response['message'] ?? 'Failed to clear wishlist',
          );
        }
      }
    } catch (e) {
      if (context != null) {
        _showErrorMessage(context, 'Failed to clear wishlist');
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Check if product is in wishlist
  Future<bool> isInWishlist({
    required String productId,
    BuildContext? context,
  }) async {
    try {
      return await WishlistRepository.isInWishlist(
        productId: productId,
        context: context,
      );
    } catch (e) {
      return false;
    }
  }

  // Toggle wishlist item
  Future<void> toggleWishlist({
    required ProductModel product,
    BuildContext? context,
  }) async {
    final isInWishlist = wishlistItems.any((item) => item.id == product.id);

    if (isInWishlist) {
      await removeFromWishlist(productId: product.id, context: context);
    } else {
      await addToWishlist(product: product, context: context);
    }
  }

  // Get wishlist count
  Future<void> updateWishlistCount({BuildContext? context}) async {
    try {
      final count = await WishlistRepository.getWishlistCount(context: context);
      wishlistCount.value = count;
    } catch (e) {
      // Handle error silently for count updates
    }
  }

  // Helper method to show success messages
  void _showSuccessMessage(BuildContext context, String message) {
    // You can implement your preferred success handling here
    // For example, using SnackBar or Toast
    print('Wishlist Success: $message');
  }

  // Helper method to show error messages
  void _showErrorMessage(BuildContext context, String message) {
    // You can implement your preferred error handling here
    // For example, using SnackBar or Toast
    print('Wishlist Error: $message');
  }
}
