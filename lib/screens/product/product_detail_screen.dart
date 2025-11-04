import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:shimmer/shimmer.dart';
import '../../controller/theme_controller.dart';
import '../../controller/wishlist_controller.dart';
import '../../controller/cart_controller.dart';
import '../../controller/product_detail_controller.dart';
import '../../models/product_model.dart';
import '../../utils/text_styles.dart';
import '../../utils/theme_config.dart';
import '../../widgets/snackbar.dart' as CustomSnackBar;

class ProductDetailScreen extends StatelessWidget {
  final String productId;
  final ProductModel? product;

  const ProductDetailScreen({Key? key, required this.productId, this.product})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    Get.put(ProductDetailController(productId: productId, product: product));

    return GetBuilder<ProductDetailController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: Get.find<ThemeController>().isDark
              ? PremiumColors.grey900
              : const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: Get.find<ThemeController>().isDark
                ? PremiumColors.grey800
                : Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: Get.find<ThemeController>().isDark
                    ? Colors.white
                    : Colors.black,
              ),
              onPressed: () => Get.back(),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.share,
                  color: Get.find<ThemeController>().isDark
                      ? Colors.white
                      : Colors.black,
                ),
                onPressed: () {
                  // TODO: Implement share functionality
                },
              ),
            ],
          ),
          body: Obx(() {
            if (controller.isLoading.value) {
              return _buildLoadingShimmer(context);
            }

            if (controller.productData.value == null) {
              return _buildErrorState(controller, context);
            }

            return _buildProductDetailContent(controller, context);
          }),
          bottomNavigationBar: Obx(() {
            if (controller.isLoading.value ||
                controller.productData.value == null) {
              return SizedBox.shrink();
            }
            return _buildBottomButtons(controller, context);
          }),
          floatingActionButton: Obx(() {
            if (controller.isLoading.value ||
                controller.productData.value == null) {
              return SizedBox.shrink();
            }
            return _buildWishlistFAB(controller, context);
          }),
        );
      },
    );
  }

  Widget _buildLoadingShimmer(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Image shimmer
          Container(
            height: 50.h,
            margin: EdgeInsets.all(4.w),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h),
          // Product info shimmer
          Container(
            margin: EdgeInsets.all(4.w),
            padding: EdgeInsets.all(4.w),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 2.h, width: 80.w, color: Colors.white),
                  SizedBox(height: 1.h),
                  Container(height: 1.5.h, width: 60.w, color: Colors.white),
                  SizedBox(height: 2.h),
                  Container(height: 2.h, width: 40.w, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    ProductDetailController controller,
    BuildContext context,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 15.w, color: Colors.red),
            SizedBox(height: 2.h),
            Text(
              'Failed to load product',
              style: TextHelper.size18(
                context,
              ).copyWith(fontWeight: FontWeight.w600, color: Colors.red),
            ),
            SizedBox(height: 1.h),
            Text(
              'Please check your internet connection and try again.',
              textAlign: TextAlign.center,
              style: TextHelper.size14(
                context,
              ).copyWith(color: Colors.grey[600]),
            ),
            SizedBox(height: 3.h),
            ElevatedButton.icon(
              onPressed: () {
                controller.loadProductDetails();
              },
              icon: Icon(Icons.refresh),
              label: Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0EA5E9),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductDetailContent(
    ProductDetailController controller,
    BuildContext context,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildImageCarousel(controller, context),
          _buildVariantSelection(controller, context),
          _buildProductInfo(controller, context),
          _buildProductSpecifications(controller, context),
          // SizedBox(height: 12.h), // Space for bottom buttons and FAB
        ],
      ),
    );
  }

  Widget _buildImageCarousel(
    ProductDetailController controller,
    BuildContext context,
  ) {
    return Obx(() {
      List<String> images = [];

      // Prefer images based on selected color (admin assigns images per color)
      if (controller.selectedVariant.value != null) {
        final selectedColor = controller.selectedVariant.value!.color;
        final currentVariantImages = controller.selectedVariant.value!.images;

        if (currentVariantImages.isNotEmpty) {
          images = currentVariantImages;
        } else if (selectedColor != null) {
          // Find any variant with the same color that has images
          final sameColorWithImages = controller.productData.value!.variants
              .firstWhere(
                (v) => v.color == selectedColor && v.images.isNotEmpty,
                orElse: () => controller.selectedVariant.value!,
              )
              .images;
          if (sameColorWithImages.isNotEmpty) {
            images = sameColorWithImages;
          }
        }
      }

      // Fallback to product images or placeholder
      if (images.isEmpty) {
        images = controller.productData.value!.images.isNotEmpty
            ? controller.productData.value!.images
            : ['https://via.placeholder.com/400x400?text=No+Image'];
      }

      return Container(
        height: 50.h,
        margin: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.1 * 255).toInt()),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              PageView.builder(
                key: ValueKey(images.join(',')),
                controller: PageController(initialPage: 0, keepPage: false),
                onPageChanged: (index) {
                  controller.changeImageIndex(index);
                },
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    images[index],
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(
                            color: const Color(0xFF0EA5E9),
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported,
                              size: 15.w,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'Failed to load image',
                              style: TextHelper.size14(
                                context,
                              ).copyWith(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              // Image indicators
              if (images.length > 1)
                Positioned(
                  bottom: 2.h,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      images.length,
                      (index) => Obx(
                        () => Container(
                          margin: EdgeInsets.symmetric(horizontal: 0.5.w),
                          width: controller.currentImageIndex.value == index
                              ? 3.w
                              : 2.w,
                          height: 2.w,
                          decoration: BoxDecoration(
                            color: controller.currentImageIndex.value == index
                                ? Colors.white
                                : Colors.white.withAlpha((0.5 * 255).toInt()),
                            borderRadius: BorderRadius.circular(1.w),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              // Discount badge
              if (controller.getDiscountPercentage() > 0)
                Positioned(
                  top: 2.h,
                  right: 2.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.w,
                      vertical: 1.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE11D48),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFFE11D48,
                          ).withAlpha((0.3 * 255).toInt()),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '${controller.getDiscountPercentage()}% OFF',
                      style: TextHelper.size14(context).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildProductInfo(
    ProductDetailController controller,
    BuildContext context,
  ) {
    final themeController = Get.find<ThemeController>();
    final priceInfo = controller.getCurrentPrice();
    final price = priceInfo['price'];
    final originalPrice = priceInfo['originalPrice'];

    return Container(
      margin: EdgeInsets.all(4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: themeController.isDark ? PremiumColors.grey800 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).toInt()),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product title
          Text(
            controller.productData.value!.title,
            style: TextHelper.size20(context).copyWith(
              fontWeight: FontWeight.bold,
              color: themeController.isDark ? Colors.white : Colors.black,
              height: 1.3,
            ),
          ),
          SizedBox(height: 1.h),

          // Rating and reviews
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: Colors.amber.withAlpha((0.1 * 255).toInt()),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 3.w),
                    SizedBox(width: 0.5.w),
                    Text(
                      controller.productData.value!.rating.toString(),
                      style: TextHelper.size14(context).copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.amber[800],
                      ),
                    ),
                  ],
                ),
              ),
              // SizedBox(width: 2.w),
              // Text(
              //   '(${controller.productData.value!.soldCount} sold)',
              //   style: TextHelper.size14(
              //     context,
              //   ).copyWith(color: Colors.grey[600]),
              // ),
            ],
          ),
          SizedBox(height: 2.h),

          // Price section
          Row(
            children: [
              Text(
                '₹${price.toStringAsFixed(0)}',
                style: TextHelper.size24(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0EA5E9),
                ),
              ),
              if (originalPrice > price) ...[
                SizedBox(width: 2.w),
                Text(
                  '₹${originalPrice.toStringAsFixed(0)}',
                  style: TextHelper.size18(context).copyWith(
                    color: Colors.grey[500],
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                SizedBox(width: 2.w),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 1.5.w,
                    vertical: 0.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFFE11D48,
                    ).withAlpha((0.1 * 255).toInt()),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Save ₹${(originalPrice - price).toStringAsFixed(0)}',
                    style: TextHelper.size14(context).copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFE11D48),
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 1.h),

          // Stock status
          Row(
            children: [
              Icon(
                controller.isVariantInStock ? Icons.check_circle : Icons.cancel,
                color: controller.isVariantInStock ? Colors.green : Colors.red,
                size: 4.w,
              ),
              SizedBox(width: 1.w),
              Text(
                controller.isVariantInStock
                    ? 'In Stock (${controller.currentStock} available)'
                    : 'Out of Stock',
                style: TextHelper.size14(context).copyWith(
                  color: controller.isVariantInStock
                      ? Colors.green
                      : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Product Description
          if (controller.productData.value!.description.isNotEmpty) ...[
            Text(
              'Description',
              style: TextHelper.size16(context).copyWith(
                fontWeight: FontWeight.bold,
                color: themeController.isDark ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              controller.productData.value!.description,
              style: TextHelper.size14(context).copyWith(
                color: themeController.isDark
                    ? Colors.grey[300]
                    : Colors.grey[700],
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVariantSelection(
    ProductDetailController controller,
    BuildContext context,
  ) {
    if (controller.productData.value!.variants.isEmpty)
      return SizedBox.shrink();

    // Get unique colors and sizes from variants
    final variants = controller.productData.value!.variants;
    final uniqueColors = <String, ProductVariant>{};
    final uniqueSizes = <String, ProductVariant>{};

    for (var variant in variants) {
      if (variant.color != null) {
        uniqueColors[variant.color!] = variant;
      }
      if (variant.size != null) {
        uniqueSizes[variant.size!] = variant;
      }
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: Get.find<ThemeController>().isDark
            ? PremiumColors.grey800
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).toInt()),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Color Selection
          if (uniqueColors.isNotEmpty) ...[
            Text(
              'Select Color',
              style: TextHelper.size18(context).copyWith(
                fontWeight: FontWeight.bold,
                color: Get.find<ThemeController>().isDark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
            SizedBox(height: 2.h),
            Obx(
              () => Wrap(
                spacing: 3.w,
                runSpacing: 1.5.h,
                children: uniqueColors.entries.map((entry) {
                  final color = entry.key;
                  final variant = entry.value;
                  final isSelected =
                      controller.selectedVariant.value?.color == color;

                  return GestureDetector(
                    onTap: () {
                      controller.selectVariant(variant);
                    },
                    child: Container(
                      width: 14.w,
                      height: 14.w,
                      decoration: BoxDecoration(
                        color: controller.getColorFromString(color),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF0EA5E9)
                              : Colors.grey.withAlpha((0.3 * 255).toInt()),
                          width: isSelected ? 3 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(
                                    0xFF0EA5E9,
                                  ).withAlpha((0.3 * 255).toInt()),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? Icon(Icons.check, color: Colors.white, size: 7.w)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 3.h),
          ],

          // Size Selection - Filtered by selected color
          if (uniqueSizes.isNotEmpty) ...[
            Text(
              'Select Size',
              style: TextHelper.size18(context).copyWith(
                fontWeight: FontWeight.bold,
                color: Get.find<ThemeController>().isDark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
            SizedBox(height: 2.h),
            Obx(() {
              // Get selected color
              final selectedColor = controller.selectedVariant.value?.color;

              // Filter sizes based on selected color
              final availableSizes = <String, ProductVariant>{};
              for (var variant in variants) {
                if (variant.size != null) {
                  // If no color is selected, show all sizes
                  // If color is selected, only show sizes for that color
                  if (selectedColor == null || variant.color == selectedColor) {
                    availableSizes[variant.size!] = variant;
                  }
                }
              }

              return Wrap(
                spacing: 2.w,
                runSpacing: 1.h,
                children: availableSizes.entries.map((entry) {
                  final size = entry.key;
                  final variant = entry.value;
                  final isSelected =
                      controller.selectedVariant.value?.size == size;

                  return GestureDetector(
                    onTap: () {
                      controller.selectVariant(variant);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 1.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF0EA5E9)
                            : Colors.grey.withAlpha((0.1 * 255).toInt()),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF0EA5E9)
                              : Colors.grey.withAlpha((0.3 * 255).toInt()),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        size,
                        style: TextHelper.size14(context).copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : Get.find<ThemeController>().isDark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildProductSpecifications(
    ProductDetailController controller,
    BuildContext context,
  ) {
    if (controller.productData.value!.attributes.isEmpty)
      return SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Get.find<ThemeController>().isDark
            ? PremiumColors.grey800
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).toInt()),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Specification',
            style: TextHelper.size18(context).copyWith(
              fontWeight: FontWeight.bold,
              color: Get.find<ThemeController>().isDark
                  ? Colors.white
                  : Colors.black,
            ),
          ),
          SizedBox(height: 1.h),
          ...controller.productData.value!.attributes.map((attr) {
            return Padding(
              padding: EdgeInsets.only(bottom: 1.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 1.w,
                    height: 1.w,
                    margin: EdgeInsets.only(top: 0.8.h),
                    decoration: BoxDecoration(
                      color: Get.find<ThemeController>().isDark
                          ? Colors.white
                          : Colors.black,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextHelper.size14(context).copyWith(
                          color: Get.find<ThemeController>().isDark
                              ? Colors.grey[300]
                              : Colors.grey[700],
                        ),
                        children: [
                          TextSpan(
                            text: '${attr.name}: ',
                            style: TextHelper.size14(context).copyWith(
                              fontWeight: FontWeight.w600,
                              color: Get.find<ThemeController>().isDark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                          TextSpan(text: attr.value.toString()),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(
    ProductDetailController controller,
    BuildContext context,
  ) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Get.find<ThemeController>().isDark
            ? PremiumColors.grey800
            : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).toInt()),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Add to cart button
            Expanded(
              child: GestureDetector(
                onTap: () => _addToCart(controller, context),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 3.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF0EA5E9),
                        const Color(0xFF0284C7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(
                          0xFF0EA5E9,
                        ).withAlpha((0.3 * 255).toInt()),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        color: Colors.white,
                        size: 4.w,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        'Add to Cart',
                        style: TextHelper.size16(context).copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 2.w),
            // Buy now button
            Expanded(
              child: GestureDetector(
                onTap: () => _buyNow(controller, context),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 3.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF10B981),
                        const Color(0xFF059669),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(
                          0xFF10B981,
                        ).withAlpha((0.3 * 255).toInt()),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.flash_on, color: Colors.white, size: 4.w),
                      SizedBox(width: 1.w),
                      Text(
                        'Buy Now',
                        style: TextHelper.size16(context).copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWishlistFAB(
    ProductDetailController controller,
    BuildContext context,
  ) {
    return Obx(() {
      final wishlistController = Get.find<WishlistController>();
      final isFavorite = wishlistController.wishlistItems.any(
        (item) => item.id == controller.productData.value!.id,
      );

      return FloatingActionButton(
        onPressed: () {
          wishlistController.toggleWishlist(
            product: controller.productData.value!,
            context: context,
          );
        },
        backgroundColor: isFavorite ? Colors.red : Colors.white,
        child: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? Colors.white : Colors.red,
        ),
      );
    });
  }

  void _addToCart(
    ProductDetailController controller,
    BuildContext context,
  ) async {
    if (controller.selectedVariant.value != null &&
        !controller.selectedVariant.value!.isInStock) {
      CustomSnackBar.SnackBar.error(
        message: 'Selected variant is out of stock',
      );
      return;
    }

    if (!controller.productData.value!.isInStock) {
      CustomSnackBar.SnackBar.error(message: 'Product is out of stock');
      return;
    }

    try {
      final product = controller.productData.value!;
      final variant = controller.selectedVariant.value;
      final quantity = controller.quantity.value;

      // Get cart controller
      final cartController = Get.find<CartController>();

      // Add to cart via cart controller
      final success = await cartController.addToCart(
        productId: product.id,
        quantity: quantity,
        variantId: variant?.sku,
        variantAttributes: variant != null
            ? {'color': variant.color, 'size': variant.size}
            : null,
        context: context,
      );

      if (success) {
        // Cart controller already shows success message
        print('Item added to cart successfully');
      }
    } catch (e) {
      print('Error adding to cart: $e');
      CustomSnackBar.SnackBar.error(
        title: 'Error',
        message: 'Failed to add item to cart',
      );
    }
  }

  void _buyNow(ProductDetailController controller, BuildContext context) async {
    if (controller.selectedVariant.value != null &&
        !controller.selectedVariant.value!.isInStock) {
      CustomSnackBar.SnackBar.error(
        message: 'Selected variant is out of stock',
      );
      return;
    }

    if (!controller.productData.value!.isInStock) {
      CustomSnackBar.SnackBar.error(message: 'Product is out of stock');
      return;
    }

    // First add to cart
    _addToCart(controller, context);

    // Then navigate to checkout/cart screen
    // You can implement navigation to checkout screen here
    // Get.toNamed(Routes.CHECKOUT);
  }
}
