import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../controller/theme_controller.dart';
import '../../controller/cart_controller.dart';
import '../../utils/theme_config.dart';
import '../../utils/text_styles.dart';
import '../../utils/color_helper.dart';
import '../../models/cart_model.dart';
import '../checkout/checkout_screen.dart';
import '../../repository/product_repository.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // GetX reactive variables
  final RxBool _isCheckoutLoading = false.obs;
  final Rx<DateTime?> _lastClickTime = Rx<DateTime?>(null);
  final Map<String, String> _imageCache = {};

  @override
  void initState() {
    super.initState();
    // Load cart when screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cartController = Get.find<CartController>();
      cartController.loadCart(context: context);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ensure cart is loaded when screen becomes visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cartController = Get.find<CartController>();
      if (cartController.needsRefresh) {
        cartController.loadCart(context: context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final cartController = Get.find<CartController>();

    return Scaffold(
      backgroundColor: themeController.isDark
          ? PremiumColors.charcoal
          : PremiumColors.softBackground,
      appBar: AppBar(
        title: Text(
          'cart.title'.tr,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: themeController.isDark
                ? Colors.white
                : PremiumColors.charcoal,
          ),
        ),
        backgroundColor: themeController.isDark
            ? PremiumColors.charcoal
            : Colors.white,
        elevation: 0,
        actions: [
          Obx(
            () => TextButton(
              onPressed: cartController.cartItems.isEmpty
                  ? null
                  : () {
                      cartController.clearCart(context: context);
                    },
              child: Text(
                'cart.clear'.tr,
                style: TextHelper.size14(context).copyWith(
                  color: cartController.cartItems.isEmpty
                      ? Colors.grey
                      : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (cartController.isLoading.value) {
          return _buildLoadingState(context, themeController);
        }

        if (cartController.cartItems.isEmpty) {
          return _buildEmptyState(context, themeController);
        }

        return Column(
          children: [
            // Cart Items
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => cartController.refreshCart(context: context),
                child: ListView.builder(
                  padding: EdgeInsets.all(4.w),
                  itemCount: cartController.cartItems.length,
                  itemBuilder: (context, index) {
                    final cartItem = cartController.cartItems[index];
                    return _buildCartItem(
                      context,
                      themeController,
                      cartItem,
                      cartController,
                    );
                  },
                ),
              ),
            ),

            // Cart Summary
            _buildCartSummary(context, themeController, cartController),
          ],
        );
      }),
    );
  }

  Widget _buildLoadingState(
    BuildContext context,
    ThemeController themeController,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: PremiumColors.gold),
          SizedBox(height: 2.h),
          Text(
            'common.loading'.tr,
            style: TextHelper.size16(context).copyWith(
              color: themeController.isDark
                  ? Colors.white
                  : PremiumColors.charcoal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ThemeController themeController,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 20.w,
            color: Colors.grey[400],
          ),
          SizedBox(height: 4.h),
          Text(
            'cart.empty'.tr,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: themeController.isDark
                  ? Colors.white
                  : PremiumColors.charcoal,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'cart.addItems'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          ),
          SizedBox(height: 4.h),
          ElevatedButton(
            onPressed: () {
              // TODO: Navigate to products
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: PremiumColors.gold,
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
              child: Text(
                'common.shop'.tr,
                style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    ThemeController themeController,
    CartItem cartItem,
    CartController cartController,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: themeController.isDark
              ? [PremiumColors.grey800, PremiumColors.grey900]
              : [Colors.white, Colors.grey.shade50],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: themeController.isDark
                ? Colors.black.withAlpha((0.3 * 255).toInt())
                : Colors.grey.withAlpha((0.15 * 255).toInt()),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: themeController.isDark
                ? Colors.black.withAlpha((0.1 * 255).toInt())
                : Colors.white.withAlpha((0.8 * 255).toInt()),
            blurRadius: 1,
            offset: const Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: themeController.isDark
              ? PremiumColors.grey600.withAlpha((0.2 * 255).toInt())
              : Colors.grey.withAlpha((0.1 * 255).toInt()),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                // Product Image
                Container(
                  width: 24.w,
                  height: 24.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.grey.shade100, Colors.grey.shade200],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((0.1 * 255).toInt()),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: _buildCartItemImage(cartItem),
                ),

                SizedBox(width: 4.w),

                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cartItem.productName,
                        style: TextHelper.size15(context).copyWith(
                          fontWeight: FontWeight.w700,
                          color: themeController.isDark
                              ? Colors.white
                              : PremiumColors.charcoal,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 1.h),

                      // Price with discount
                      Row(
                        children: [
                          Text(
                            '\$${cartItem.finalPrice.toStringAsFixed(2)}',
                            style: TextHelper.size16(context).copyWith(
                              fontWeight: FontWeight.w800,
                              color: PremiumColors.gold,
                            ),
                          ),
                          if (cartItem.discount > 0) ...[
                            SizedBox(width: 2.w),
                            Text(
                              '\$${cartItem.price.toStringAsFixed(2)}',
                              style: TextHelper.size14(context).copyWith(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 1.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 2.w,
                                vertical: 0.5.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.withAlpha(
                                  (0.15 * 255).toInt(),
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '-${cartItem.discount.toInt()}%',
                                style: TextHelper.size14(context).copyWith(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),

                      // Variant attributes
                      if (cartItem.variantAttributes.isNotEmpty) ...[
                        SizedBox(height: 1.h),
                        Wrap(
                          spacing: 1.5.w,
                          runSpacing: 0.5.h,
                          children: cartItem.variantAttributes.entries.map((
                            entry,
                          ) {
                            String displayValue = entry.value.toString();

                            // Convert color hex to readable name
                            if (entry.key.toLowerCase() == 'color' &&
                                displayValue.startsWith('#')) {
                              displayValue = ColorHelper.getColorName(
                                displayValue,
                              );
                            }

                            return Text(
                              '${entry.key.toUpperCase()}: $displayValue',
                              style: TextHelper.size14(context).copyWith(
                                color: PremiumColors.gold,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          }).toList(),
                        ),
                      ],

                      SizedBox(height: 1.h),

                      // Quantity Controls
                      Row(
                        children: [
                          Obx(() {
                            final isLoading =
                                cartController.itemLoadingStates[cartItem.id] ??
                                false;
                            return GestureDetector(
                              onTap: isLoading
                                  ? null
                                  : () {
                                      cartController.decreaseQuantity(
                                        cartItem.id,
                                        context: context,
                                      );
                                    },
                              child: Container(
                                width: 7.w,
                                height: 7.w,
                                decoration: BoxDecoration(
                                  color: PremiumColors.gold.withAlpha(
                                    (0.15 * 255).toInt(),
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: PremiumColors.gold.withAlpha(
                                      (0.3 * 255).toInt(),
                                    ),
                                    width: 1,
                                  ),
                                ),
                                child: isLoading
                                    ? SizedBox(
                                        width: 3.w,
                                        height: 3.w,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: PremiumColors.gold,
                                        ),
                                      )
                                    : Icon(
                                        Icons.remove,
                                        size: 3.5.w,
                                        color: PremiumColors.gold,
                                      ),
                              ),
                            );
                          }),
                          SizedBox(width: 3.w),
                          Text(
                            '${cartItem.quantity}',
                            style: TextHelper.size14(context).copyWith(
                              fontWeight: FontWeight.w600,
                              color: themeController.isDark
                                  ? Colors.white
                                  : PremiumColors.charcoal,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Obx(() {
                            final isLoading =
                                cartController.itemLoadingStates[cartItem.id] ??
                                false;
                            return GestureDetector(
                              onTap: isLoading
                                  ? null
                                  : () {
                                      cartController.increaseQuantity(
                                        cartItem.id,
                                        context: context,
                                      );
                                    },
                              child: Container(
                                width: 7.w,
                                height: 7.w,
                                decoration: BoxDecoration(
                                  color: PremiumColors.gold.withAlpha(
                                    (0.15 * 255).toInt(),
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: PremiumColors.gold.withAlpha(
                                      (0.3 * 255).toInt(),
                                    ),
                                    width: 1,
                                  ),
                                ),
                                child: isLoading
                                    ? SizedBox(
                                        width: 3.w,
                                        height: 3.w,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: PremiumColors.gold,
                                        ),
                                      )
                                    : Icon(
                                        Icons.add,
                                        size: 3.5.w,
                                        color: PremiumColors.gold,
                                      ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Remove Button - Top Right Corner
          Positioned(
            top: 2.w,
            right: 2.w,
            child: GestureDetector(
              onTap: () {
                cartController.removeFromCart(
                  itemId: cartItem.id,
                  context: context,
                );
              },
              child: Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha((0.15 * 255).toInt()),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.red.withAlpha((0.3 * 255).toInt()),
                    width: 1,
                  ),
                ),
                child: Icon(Icons.delete_outline, color: Colors.red, size: 4.w),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartSummary(
    BuildContext context,
    ThemeController themeController,
    CartController cartController,
  ) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: themeController.isDark ? PremiumColors.grey800 : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Summary Details
          Obx(() {
            final cartModel = cartController.cartModel.value;
            if (cartModel == null) return SizedBox.shrink();

            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'cart.subtotal'.tr,
                      style: TextHelper.size14(
                        context,
                      ).copyWith(color: Colors.grey[600]),
                    ),
                    Text(
                      '\$${cartModel.totalAmount.toStringAsFixed(2)}',
                      style: TextHelper.size14(context).copyWith(
                        fontWeight: FontWeight.w600,
                        color: themeController.isDark
                            ? Colors.white
                            : PremiumColors.charcoal,
                      ),
                    ),
                  ],
                ),
                if (cartModel.discountAmount > 0) ...[
                  SizedBox(height: 1.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'cart.discount'.tr,
                        style: TextHelper.size14(
                          context,
                        ).copyWith(color: Colors.grey[600]),
                      ),
                      Text(
                        '-\$${cartModel.discountAmount.toStringAsFixed(2)}',
                        style: TextHelper.size14(context).copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
                SizedBox(height: 1.h),
                Divider(height: 1.h, thickness: 2, color: Colors.grey[300]),
                SizedBox(height: 0.5.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'cart.total'.tr,
                      style: TextHelper.size16(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: themeController.isDark
                            ? Colors.white
                            : PremiumColors.charcoal,
                      ),
                    ),
                    Text(
                      '\$${cartModel.finalAmount.toStringAsFixed(2)}',
                      style: TextHelper.size18(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: PremiumColors.gold,
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
          SizedBox(height: 3.h),

          // Checkout Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isCheckoutLoading.value
                  ? null
                  : () async {
                      // Debouncing: Prevent clicks within 1 second
                      final now = DateTime.now();
                      if (_lastClickTime.value != null &&
                          now.difference(_lastClickTime.value!).inMilliseconds <
                              1000) {
                        return;
                      }
                      _lastClickTime.value = now;

                      if (_isCheckoutLoading.value)
                        return; // Prevent multiple clicks

                      _isCheckoutLoading.value = true;

                      try {
                        // Save all quantities to backend before checkout (without reloading cart)
                        final cartController = Get.find<CartController>();
                        final success = await cartController
                            .saveQuantitiesForCheckout(context: context);

                        if (success) {
                          // Navigate to checkout by replacing Cart to avoid returning to it
                          Get.to(() => const CheckoutScreen());
                        }
                      } catch (e) {
                        print('Error during checkout: $e');
                        // Show error message if needed
                      } finally {
                        _isCheckoutLoading.value = false;
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: PremiumColors.gold,
                padding: EdgeInsets.symmetric(vertical: 2.5.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
              ),
              child: Obx(
                () => _isCheckoutLoading.value
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 4.w,
                            height: 4.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'common.loading'.tr,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        'cart.checkout'.tr,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemImage(CartItem cartItem) {
    // Prefer cached/fetched image if original is empty
    final effectiveUrl = cartItem.productImage.isNotEmpty
        ? cartItem.productImage
        : _imageCache[cartItem.productId];

    if (effectiveUrl != null && effectiveUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          effectiveUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _cartImagePlaceholder(),
        ),
      );
    }

    // If no URL, try to lazily fetch product and cache its first image
    return FutureBuilder<String?>(
      future: _fetchAndCacheProductImage(cartItem.productId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data != null &&
            snapshot.data!.isNotEmpty) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              snapshot.data!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _cartImagePlaceholder(),
            ),
          );
        }
        return _cartImagePlaceholder();
      },
    );
  }

  Widget _cartImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade300, Colors.grey.shade400],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(Icons.image, color: Colors.grey.shade600, size: 8.w),
    );
  }

  Future<String?> _fetchAndCacheProductImage(String productId) async {
    try {
      // Avoid duplicate fetches
      if (_imageCache.containsKey(productId)) return _imageCache[productId];
      final product = await ProductRepository.getProduct(
        productId: productId,
        context: context,
      );
      final url =
          (product?.variants.isNotEmpty == true &&
              product!.variants.first.images.isNotEmpty)
          ? product.variants.first.images.first
          : (product?.images.isNotEmpty == true ? product!.images.first : null);
      if (url != null && url.isNotEmpty) {
        _imageCache[productId] = url;
        return url;
      }
    } catch (e) {
      // ignore
    }
    return null;
  }
}
