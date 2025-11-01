import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/cart_model.dart';
import '../repository/cart_repository.dart';
import '../widgets/snackbar.dart' as CustomSnackBar;
import '../widgets/toastification.dart';

class CartController extends GetxController {
  // Observable cart items
  final RxList<CartItem> cartItems = <CartItem>[].obs;

  // Local loading states for individual items
  final RxMap<String, bool> itemLoadingStates = <String, bool>{}.obs;

  // Observable cart model
  final Rx<CartModel?> cartModel = Rx<CartModel?>(null);

  // Observable subtotal
  final RxDouble subtotal = 0.0.obs;

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isAddingToCart = false.obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxBool hasMoreItems = true.obs;
  final RxBool isLoadingMore = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Don't load cart automatically to avoid build-time reactive updates
    // Cart will be loaded when the cart screen is opened
  }

  // Load cart from API
  Future<void> loadCart({BuildContext? context}) async {
    try {
      // Add a small delay to ensure we're not in the build phase
      await Future.delayed(Duration(milliseconds: 100));
      isLoading.value = true;
      final cart = await CartRepository.getCart(context: context);
      if (cart != null) {
        cartModel.value = cart;
        cartItems.value = cart.items;
        subtotal.value = cart.finalAmount;
        currentPage.value = 1;
        totalPages.value = 1; // Backend should return pagination info
        hasMoreItems.value = false; // For now, assume no pagination needed
      }
    } catch (e) {
      print('Error loading cart: $e');
      if (context != null) {
        CustomSnackBar.SnackBar.error(
          title: 'Error',
          message: 'Failed to load cart items',
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Add item to cart via API
  Future<bool> addToCart({
    required String productId,
    required int quantity,
    String? variantId,
    Map<String, dynamic>? variantAttributes,
    BuildContext? context,
  }) async {
    try {
      isAddingToCart.value = true;
      final response = await CartRepository.addToCart(
        productId: productId,
        quantity: quantity,
        variantId: variantId,
        variantAttributes: variantAttributes,
        context: context,
      );

      if (response['status'] == 1) {
        // Reload cart to get updated data (with delay to avoid build-time updates)
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await loadCart(context: context);
        });

        if (context != null) {
          ToastHelper.showSuccessToast(
            response['message'] ?? 'Item added to cart',
          );
        }
        return true;
      } else {
        if (context != null) {
          CustomSnackBar.SnackBar.error(
            title: 'Error',
            message: response['message'] ?? 'Failed to add item to cart',
          );
        }
        return false;
      }
    } catch (e) {
      print('Error adding to cart: $e');
      if (context != null) {
        CustomSnackBar.SnackBar.error(
          title: 'Error',
          message: 'Failed to add item to cart',
        );
      }
      return false;
    } finally {
      isAddingToCart.value = false;
    }
  }

  // Update cart item quantity via API
  Future<bool> updateQuantity({
    required String itemId,
    required int quantity,
    BuildContext? context,
    bool reloadCart = true,
  }) async {
    try {
      final response = await CartRepository.updateCartItem(
        itemId: itemId,
        quantity: quantity,
        context: context,
      );

      if (response['status'] == 1) {
        // Only reload cart if requested (default behavior)
        if (reloadCart) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await loadCart(context: context);
          });
        }
        return true;
      } else {
        if (context != null) {
          CustomSnackBar.SnackBar.error(
            title: 'Error',
            message: response['message'] ?? 'Failed to update quantity',
          );
        }
        return false;
      }
    } catch (e) {
      print('Error updating quantity: $e');
      if (context != null) {
        CustomSnackBar.SnackBar.error(
          title: 'Error',
          message: 'Failed to update quantity',
        );
      }
      return false;
    }
  }

  // Remove item from cart via API
  Future<bool> removeFromCart({
    required String itemId,
    BuildContext? context,
  }) async {
    try {
      final response = await CartRepository.removeFromCart(
        itemId: itemId,
        context: context,
      );

      if (response['status'] == 1) {
        // Reload cart to get updated data (with delay to avoid build-time updates)
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await loadCart(context: context);
        });

        if (context != null) {
          ToastHelper.showSuccessToast(
            response['message'] ?? 'Item removed from cart',
          );
        }
        return true;
      } else {
        if (context != null) {
          CustomSnackBar.SnackBar.error(
            title: 'Error',
            message: response['message'] ?? 'Failed to remove item',
          );
        }
        return false;
      }
    } catch (e) {
      print('Error removing from cart: $e');
      if (context != null) {
        CustomSnackBar.SnackBar.error(
          title: 'Error',
          message: 'Failed to remove item from cart',
        );
      }
      return false;
    }
  }

  // Clear entire cart via API
  Future<bool> clearCart({BuildContext? context, bool showToast = true}) async {
    try {
      final response = await CartRepository.clearCart(context: context);

      if (response['status'] == 1) {
        cartModel.value = null;
        cartItems.clear();
        subtotal.value = 0.0;

        if (context != null && showToast) {
          ToastHelper.showSuccessToast(response['message'] ?? 'Cart cleared');
        }
        return true;
      } else {
        if (context != null) {
          CustomSnackBar.SnackBar.error(
            title: 'Error',
            message: response['message'] ?? 'Failed to clear cart',
          );
        }
        return false;
      }
    } catch (e) {
      print('Error clearing cart: $e');
      if (context != null) {
        CustomSnackBar.SnackBar.error(
          title: 'Error',
          message: 'Failed to clear cart',
        );
      }
      return false;
    }
  }

  // Increase quantity (temporary - not saved to backend)
  void increaseQuantity(String itemId, {BuildContext? context}) {
    final itemIndex = cartItems.indexWhere((item) => item.id == itemId);
    if (itemIndex != -1) {
      // Set loading state for this item
      itemLoadingStates[itemId] = true;

      // Update quantity locally
      final updatedItem = cartItems[itemIndex].copyWith(
        quantity: cartItems[itemIndex].quantity + 1,
        totalPrice:
            cartItems[itemIndex].finalPrice *
            (cartItems[itemIndex].quantity + 1),
      );
      cartItems[itemIndex] = updatedItem;

      // Update cart totals locally
      _updateLocalTotals();

      // Clear loading state after a short delay
      Future.delayed(Duration(milliseconds: 300), () {
        itemLoadingStates[itemId] = false;
      });
    }
  }

  // Decrease quantity (temporary - not saved to backend)
  void decreaseQuantity(String itemId, {BuildContext? context}) {
    final itemIndex = cartItems.indexWhere((item) => item.id == itemId);
    if (itemIndex != -1) {
      final currentQuantity = cartItems[itemIndex].quantity;

      if (currentQuantity > 1) {
        // Set loading state for this item
        itemLoadingStates[itemId] = true;

        // Update quantity locally
        final updatedItem = cartItems[itemIndex].copyWith(
          quantity: currentQuantity - 1,
          totalPrice: cartItems[itemIndex].finalPrice * (currentQuantity - 1),
        );
        cartItems[itemIndex] = updatedItem;

        // Update cart totals locally
        _updateLocalTotals();

        // Clear loading state after a short delay
        Future.delayed(Duration(milliseconds: 300), () {
          itemLoadingStates[itemId] = false;
        });
      }
      // Don't remove item when quantity is 1 - just keep it at 1
    }
  }

  // Update local cart totals without backend call
  void _updateLocalTotals() {
    double totalAmount = 0;
    double discountAmount = 0;

    for (var item in cartItems) {
      totalAmount += item.price * item.quantity;
      discountAmount += (item.price * item.discount / 100) * item.quantity;
    }

    final finalAmount = totalAmount - discountAmount;

    // Update cart model locally
    if (cartModel.value != null) {
      cartModel.value = cartModel.value!.copyWith(
        totalAmount: totalAmount,
        discountAmount: discountAmount,
        finalAmount: finalAmount,
      );
    }
  }

  // Save all quantities to backend (for checkout)
  Future<bool> saveQuantitiesToBackend({BuildContext? context}) async {
    try {
      isLoading.value = true;

      // Update each item's quantity in backend without reloading cart
      for (var item in cartItems) {
        await updateQuantity(
          itemId: item.id,
          quantity: item.quantity,
          context: context,
          reloadCart: false, // Don't reload cart for each item
        );
      }

      // Only reload cart once at the end to get updated totals
      await loadCart(context: context);

      isLoading.value = false;
      return true;
    } catch (e) {
      print('Error saving quantities to backend: $e');
      isLoading.value = false;
      if (context != null) {
        CustomSnackBar.SnackBar.error(
          title: 'Error',
          message: 'Failed to update cart quantities',
        );
      }
      return false;
    }
  }

  // Save quantities without reloading cart (for direct checkout)
  Future<bool> saveQuantitiesForCheckout({BuildContext? context}) async {
    try {
      // Update each item's quantity in backend without any reloads
      for (var item in cartItems) {
        await updateQuantity(
          itemId: item.id,
          quantity: item.quantity,
          context: context,
          reloadCart: false, // Don't reload cart
        );
      }
      return true;
    } catch (e) {
      print('Error saving quantities for checkout: $e');
      if (context != null) {
        CustomSnackBar.SnackBar.error(
          title: 'Error',
          message: 'Failed to update cart quantities',
        );
      }
      return false;
    }
  }

  // Get cart count
  Future<int> getCartCount({BuildContext? context}) async {
    try {
      return await CartRepository.getCartCount(context: context);
    } catch (e) {
      print('Error getting cart count: $e');
      return 0;
    }
  }

  // Check if cart needs to be refreshed
  bool get needsRefresh => cartItems.isEmpty && !isLoading.value;

  // Refresh cart (alias for loadCart with context)
  Future<void> refreshCart({BuildContext? context}) async {
    await loadCart(context: context);
  }
}
