import 'package:ecommerce/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../controller/wishlist_controller.dart';
import '../../controller/theme_controller.dart';
import '../../models/product_model.dart';
import '../../utils/text_styles.dart';
import '../../utils/theme_config.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final WishlistController wishlistController = Get.find<WishlistController>();

  @override
  void initState() {
    super.initState();
    // Refresh wishlist when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      wishlistController.loadWishlist(context: context, reset: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Scaffold(
      backgroundColor: themeController.isDark
          ? PremiumColors.grey900
          : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: themeController.isDark
            ? PremiumColors.grey800
            : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: themeController.isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'wishlist.title'.tr,
          style: TextHelper.size18(context).copyWith(
            color: themeController.isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Obx(() {
            if (wishlistController.wishlistItems.isEmpty) {
              return const SizedBox.shrink();
            }
            return IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: themeController.isDark ? Colors.white : Colors.black,
              ),
              onPressed: () => _showClearWishlistDialog(context),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (wishlistController.isLoading.value &&
            wishlistController.wishlistItems.isEmpty) {
          return _buildShimmerList();
        }

        if (wishlistController.wishlistItems.isEmpty) {
          return _buildEmptyState();
        }

        return NotificationListener<ScrollNotification>(
          onNotification: (sn) {
            if (sn.metrics.pixels >= sn.metrics.maxScrollExtent - 200) {
              wishlistController.loadMoreWishlist(context: context);
            }
            return false;
          },
          child: ListView.builder(
            padding: EdgeInsets.all(4.w),
            itemCount: wishlistController.wishlistItems.length +
                (wishlistController.isLoadingMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= wishlistController.wishlistItems.length) {
                return _buildLoadingMoreIndicator();
              }

              final product = wishlistController.wishlistItems[index];
              return _buildProductCard(context, product, themeController);
            },
          ),
        );
      }),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    ProductModel product,
    ThemeController themeController,
  ) {
    final image = product.images.isNotEmpty
        ? product.images.first
        : (product.variants.isNotEmpty &&
                product.variants.first.images.isNotEmpty
            ? product.variants.first.images.first
            : '');

    final originalPrice = (product.variants.isNotEmpty
        ? product.variants.first.price
        : product.price);
    final discount = (product.variants.isNotEmpty
        ? product.variants.first.discount
        : product.discount);
    final price = (originalPrice - (originalPrice * discount / 100))
        .clamp(0, double.infinity);
    final hasDiscount = (discount > 0);
    final previewAttrs = product.attributesPreview.isNotEmpty
        ? product.attributesPreview
        : product.attributes;

    return GestureDetector(
      onTap: () {
        Get.toNamed(
          Routes.PRODUCT_DETAIL_SCREEN,
          arguments: {'productId': product.id, 'product': product},
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 3.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              themeController.isDark ? PremiumColors.grey800 : Colors.white,
              themeController.isDark
                  ? PremiumColors.grey900
                  : Colors.grey.shade50,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.07 * 255).toInt()),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withAlpha((0.03 * 255).toInt()),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
          border: Border.all(
            color: Colors.grey.withAlpha((0.12 * 255).toInt()),
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(3.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Image left
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 28.w,
                      height: 28.w,
                      color: Colors.grey[200],
                      child: image.isNotEmpty
                          ? Image.network(
                              image,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stack) =>
                                  Container(color: Colors.grey[300]),
                            )
                          : Icon(
                              Icons.image,
                              color: Colors.grey[500],
                            ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  // Info right
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextHelper.size16(context).copyWith(
                            fontWeight: FontWeight.w700,
                            color: themeController.isDark
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        SizedBox(height: 0.8.h),
                        Row(
                          children: [
                            Text(
                              '₹${price.toStringAsFixed(0)}',
                              style: TextHelper.size16(context).copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0EA5E9),
                              ),
                            ),
                            if (hasDiscount) ...[
                              SizedBox(width: 2.w),
                              Text(
                                '₹${originalPrice.toStringAsFixed(0)}',
                                style: TextHelper.size14(context).copyWith(
                                  color: Colors.grey[600],
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 2.w,
                                  vertical: 0.3.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE11D48)
                                      .withAlpha((0.1 * 255).toInt()),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${discount.toInt()}% OFF',
                                  style: TextHelper.size12(context).copyWith(
                                    color: const Color(0xFFE11D48),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 0.6.h),
                        if (previewAttrs.isNotEmpty)
                          Wrap(
                            spacing: 2.w,
                            runSpacing: 0.8.h,
                            children: previewAttrs
                                .take(4)
                                .map(
                                  (attr) => Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 2.w,
                                      vertical: 0.4.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0EA5E9)
                                          .withAlpha((0.08 * 255).toInt()),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0xFF0EA5E9)
                                            .withAlpha((0.2 * 255).toInt()),
                                      ),
                                    ),
                                    child: Text(
                                      '${attr.name}: ${attr.value}',
                                      style: TextHelper.size12(context).copyWith(
                                        color: const Color(0xFF0EA5E9),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Top-right remove icon
            Positioned(
              top: 1.w,
              right: 1.w,
              child: GestureDetector(
                onTap: () {
                  wishlistController.removeFromWishlist(
                    productId: product.id,
                    context: context,
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha((0.1 * 255).toInt()),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 2.h),
          Text(
            'wishlist.empty'.tr,
            style: TextHelper.size18(context).copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'wishlist.emptyMessage'.tr,
            style: TextHelper.size14(context).copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: 6,
      itemBuilder: (_, __) => Container(
        margin: EdgeInsets.only(bottom: 3.w),
        height: 26.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return Container(
      padding: EdgeInsets.all(4.w),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    );
  }

  void _showClearWishlistDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'wishlist.clear'.tr,
            style: TextHelper.size18(context).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'wishlist.clearConfirm'.tr,
            style: TextHelper.size14(context),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'common.cancel'.tr,
                style: TextHelper.size14(context).copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                wishlistController.clearWishlist(context: context);
              },
              child: Text(
                'wishlist.clearButton'.tr,
                style: TextHelper.size14(context).copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

