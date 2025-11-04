import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../repository/wishlist_repository.dart';
import '../models/product_model.dart';
import '../widgets/snackbar.dart' as CustomSnackBar;

class WishlistController extends GetxController {
  // Observable variables
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final wishlistItems = <ProductModel>[].obs;
  final wishlistCount = 0.obs;
  final currentPage = 1.obs;
  final int limit = 10;
  final hasMore = true.obs;
  final totalPages = 1.obs;

  @override
  void onInit() {
    super.onInit();
    // Don't load wishlist automatically - let screens load it when needed
    // This prevents unnecessary API calls on app startup
  }

  // Load wishlist with pagination
  Future<void> loadWishlist({BuildContext? context, bool reset = false}) async {
    try {
      if (reset) {
        currentPage.value = 1;
        wishlistItems.clear();
        hasMore.value = true;
      }

      if (!hasMore.value && !reset) return;

      isLoading.value = true;
      final result = await WishlistRepository.getWishlist(
        page: currentPage.value,
        limit: limit,
        context: context,
      );

      final products = result['products'] as List<ProductModel>;
      final pagination = result['pagination'] as Map<String, dynamic>;

      if (reset) {
        wishlistItems.value = products;
      } else {
        wishlistItems.addAll(products);
      }

      wishlistCount.value = pagination['total'] ?? 0;
      totalPages.value = pagination['pages'] ?? 1;
      hasMore.value = currentPage.value < totalPages.value;

      if (context != null && reset && products.isEmpty) {
        _showInfoMessage(context, 'Your wishlist is empty');
      }
    } catch (e) {
      if (context != null) {
        _showErrorMessage(context, 'Failed to load wishlist');
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Load more wishlist items
  Future<void> loadMoreWishlist({BuildContext? context}) async {
    if (isLoadingMore.value || !hasMore.value) return;

    try {
      isLoadingMore.value = true;
      currentPage.value++;
      await loadWishlist(context: context, reset: false);
    } catch (e) {
      currentPage.value--; // Rollback on error
      if (context != null) {
        _showErrorMessage(context, 'Failed to load more items');
      }
    } finally {
      isLoadingMore.value = false;
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
        // Refresh wishlist count
        await updateWishlistCount(context: context);
        // Reload first page if needed
        if (wishlistItems.isEmpty) {
          await loadWishlist(context: context, reset: true);
        } else {
          // Add product to local wishlist if not already present
          if (!wishlistItems.any((item) => item.id == product.id)) {
            wishlistItems.insert(0, product);
            wishlistCount.value++;
          }
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
        wishlistCount.value = wishlistCount.value > 0 ? wishlistCount.value - 1 : 0;
        // Update pagination if needed
        if (wishlistItems.length < limit && currentPage.value < totalPages.value) {
          // Load more if we have space and more pages
          await loadMoreWishlist(context: context);
        }

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
    // Success feedback is shown through UI updates (icon changes, etc.)
    // Optionally show a toast or snackbar if needed
  }

  // Helper method to show error messages
  void _showErrorMessage(BuildContext context, String message) {
    CustomSnackBar.SnackBar.error(message: message);
  }

  // Helper method to show info messages
  void _showInfoMessage(BuildContext context, String message) {
    // Info messages can be shown via snackbar with error method or skipped
    // since empty state will be visible
  }
}
