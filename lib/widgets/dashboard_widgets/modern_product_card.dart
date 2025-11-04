import 'package:ecommerce/utils/text_styles.dart';
import 'package:ecommerce/widgets/constant_widgets.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:get/get.dart';
import '../../utils/theme_config.dart';
import '../../controller/theme_controller.dart';
import '../../controller/wishlist_controller.dart';
import '../../routes/routes.dart';

class ModernProductCard extends StatefulWidget {
  final dynamic product;
  final String cardType; // 'featured', 'trending', 'new', 'bestseller'
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final VoidCallback? onAddToCart;

  const ModernProductCard({
    Key? key,
    required this.product,
    this.cardType = 'featured',
    this.onTap,
    this.onFavorite,
    this.onAddToCart,
  }) : super(key: key);

  @override
  State<ModernProductCard> createState() => _ModernProductCardState();
}

class _ModernProductCardState extends State<ModernProductCard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) => _scaleController.reverse(),
      onTapCancel: () => _scaleController.reverse(),
      onTap:
          widget.onTap ??
          () {
            if (widget.product?.id != null) {
              Get.toNamed(
                Routes.PRODUCT_DETAIL_SCREEN,
                arguments: {
                  'productId': widget.product.id,
                  'product': widget.product,
                },
              );
            }
          },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: _buildCardContent(themeController),
          );
        },
      ),
    );
  }

  Widget _buildCardContent(ThemeController themeController) {
    // Special design for featured products
    if (widget.cardType == 'featured') {
      return _buildFeaturedCardDesign(themeController);
    }

    // Special design for trending products
    if (widget.cardType == 'trending') {
      return _buildTrendingCardDesign(themeController);
    }

    // Standard design for other card types
    return Container(
      width: widget.cardType == 'new'
          ? 45.w
          : 28.w, // Wider for new cards in grid
      height: widget.cardType == 'new'
          ? null
          : 50.h, // Flexible height for new cards
      decoration: _getCardDecoration(themeController),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageSection(themeController),
          _buildContentSection(themeController),
        ],
      ),
    );
  }

  BoxDecoration _getCardDecoration(ThemeController themeController) {
    switch (widget.cardType) {
      case 'featured':
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: themeController.isDark
                ? [PremiumColors.grey800, PremiumColors.grey900]
                : [Colors.white, const Color(0xFFF8FAFC)],
          ),
          borderRadius: BorderRadius.circular(20), // More rounded for featured
          border: Border.all(
            color: themeController.isDark
                ? PremiumColors.gold.withAlpha((0.3 * 255).toInt())
                : const Color(0xFF0EA5E9).withAlpha((0.2 * 255).toInt()),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: themeController.isDark
                  ? PremiumColors.gold.withAlpha((0.1 * 255).toInt())
                  : const Color(0xFF0EA5E9).withAlpha((0.15 * 255).toInt()),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withAlpha((0.08 * 255).toInt()),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withAlpha((0.04 * 255).toInt()),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        );
      case 'trending':
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: themeController.isDark
                ? [PremiumColors.grey800, PremiumColors.grey900]
                : [
                    Colors.white,
                    const Color(0xFFF8FAFC).withAlpha((0.95 * 255).toInt()),
                  ],
          ),
          borderRadius: BorderRadius.circular(
            16,
          ), // Standard rounded for trending
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.08 * 255).toInt()),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withAlpha((0.04 * 255).toInt()),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        );
      default:
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: themeController.isDark
                ? [PremiumColors.grey800, PremiumColors.grey900]
                : [Colors.white, const Color(0xFFF8FAFC)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.08 * 255).toInt()),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withAlpha((0.04 * 255).toInt()),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        );
    }
  }

  Widget _buildImageSection(ThemeController themeController) {
    return Container(
      height: widget.cardType == 'new'
          ? 16.h
          : 32.h, // Better height for new cards visibility
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(widget.cardType == 'featured' ? 20 : 16),
        ),
        gradient: LinearGradient(
          colors: [Colors.grey[50]!, Colors.grey[100]!, Colors.grey[200]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          _buildProductImage(),
          // _buildRatingBadge(), // Rating on bottom-left of image
          _buildDiscountBadge(), // Discount on top-right of image
          _buildNewBadge(),
          _buildTrendingBadge(),
          _buildActionButtons(themeController),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    if (widget.product?.images != null && widget.product.images.isNotEmpty) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.1 * 255).toInt()),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(widget.cardType == 'featured' ? 20 : 16),
          ),
          child: Stack(
            children: [
              Image.network(
                widget.product.images.first,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholderImage();
                },
              ),
              // Add a subtle overlay for better text readability
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withAlpha((0.1 * 255).toInt()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return _buildPlaceholderImage();
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PremiumColors.gold.withAlpha((0.1 * 255).toInt()),
            PremiumColors.gold.withAlpha((0.05 * 255).toInt()),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        Icons.shopping_bag_outlined,
        size: 8.w,
        color: PremiumColors.gold,
      ),
    );
  }

  Widget _buildRatingBadge() {
    final rating = widget.product?.rating ?? 4.5;
    return Positioned(
      bottom: 1.h,
      left: 1.w,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.5.h),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha((0.6 * 255).toInt()),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.2 * 255).toInt()),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, color: Colors.amber, size: 3.w),
            SizedBox(width: 0.5.w),
            Text(
              rating.toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 9.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscountBadge() {
    final priceInfo = _getProductPrice();
    final discountPercentage = priceInfo['discountPercentage'];

    if (discountPercentage > 0) {
      return Positioned(
        top: 1.h,
        right: 1.w,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.5.h),
          decoration: BoxDecoration(
            color: const Color(0xFFE11D48), // Premium pink/red
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE11D48).withAlpha((0.3 * 255).toInt()),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            '$discountPercentage%',
            style: TextHelper.size14(
              context,
            ).copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
    return SizedBox.shrink();
  }

  Widget _buildNewBadge() {
    if (widget.product?.isNew == true || widget.product?.newBadge == 'NEW') {
      return Positioned(
        top: 1.h,
        left: 1.w,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.8.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green[500]!, Colors.green[600]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withAlpha((0.3 * 255).toInt()),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.new_releases, color: Colors.white, size: 3.w),
              SizedBox(width: 1.w),
              Text(
                'NEW',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return SizedBox.shrink();
  }

  Widget _buildTrendingBadge() {
    if (widget.product?.isTrending == true ||
        widget.product?.trendingScore != null) {
      return Positioned(
        top: 1.h,
        left: widget.product?.isNew == true ? 20.w : 1.w,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.8.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange[500]!, Colors.orange[600]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withAlpha((0.3 * 255).toInt()),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.trending_up, color: Colors.white, size: 3.w),
              SizedBox(width: 1.w),
              Text(
                'TRENDING',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return SizedBox.shrink();
  }

  Widget _buildActionButtons(ThemeController themeController) {
    return Positioned(
      bottom: 1.h,
      right: 1.w,
      child: Column(
        children: [
          // Obx(() {
          //   final wishlistController = Get.find<WishlistController>();
          //   final isFavorite = wishlistController.wishlistItems.any(
          //     (item) => item.id == widget.product?.id,
          //   );

          //   return _buildFloatingButton(
          //     icon: isFavorite ? Icons.favorite : Icons.favorite_border,
          //     color: isFavorite ? Colors.red : Colors.grey[600]!,
          //     backgroundColor: Colors.white,
          //     onTap: () {
          //       if (widget.product != null) {
          //         wishlistController.toggleWishlist(
          //           product: widget.product,
          //           context: context,
          //         );
          //       }
          //       widget.onFavorite?.call();
          //     },
          //   );
          // }),
          // SizedBox(height: 0.8.h),
          // _buildFloatingButton(
          //   icon: Icons.shopping_cart_outlined,
          //   color: Colors.white,
          //   backgroundColor: const Color(0xFF0EA5E9), // Sky Blue
          //   onTap: widget.onAddToCart,
          // ),
        ],
      ),
    );
  }

  // Widget _buildFloatingButton({
  //   required IconData icon,
  //   required Color color,
  //   Color? backgroundColor,
  //   required VoidCallback? onTap,
  // }) {
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: Container(
  //       width: 9.w,
  //       height: 9.w,
  //       decoration: BoxDecoration(
  //         color: backgroundColor ?? Colors.white,
  //         shape: BoxShape.circle,
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.black.withAlpha((0.15 * 255).toInt()),
  //             blurRadius: 8,
  //             offset: const Offset(0, 2),
  //           ),
  //           BoxShadow(
  //             color: (backgroundColor ?? Colors.white).withAlpha(
  //               (0.3 * 255).toInt(),
  //             ),
  //             blurRadius: 4,
  //             offset: const Offset(0, 1),
  //           ),
  //         ],
  //       ),
  //       child: Icon(icon, color: color, size: 4.5.w),
  //     ),
  //   );
  // }

  Widget _buildContentSection(ThemeController themeController) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(
          widget.cardType == 'new' ? 1.w : 2.w,
        ), // Reduced padding for new cards
        decoration: BoxDecoration(
          color: themeController.isDark
              ? PremiumColors.grey800.withAlpha((0.5 * 255).toInt())
              : Colors.white.withAlpha((0.9 * 255).toInt()),
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(widget.cardType == 'featured' ? 20 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: widget.cardType == 'new'
              ? MainAxisAlignment.start
              : MainAxisAlignment.spaceBetween,
          children: [
            _buildProductInfo(themeController),
            SizedBox(
              height: widget.cardType == 'new' ? 0.3.h : 0.5.h,
            ), // Better spacing for readability
            _buildPriceSection(themeController),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfo(ThemeController themeController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getProductName(),
          style: widget.cardType == 'new'
              ? TextHelper.size15(context).copyWith(
                  fontWeight: FontWeight.w600,
                  color: themeController.isDark
                      ? Colors.white
                      : const Color(0xFF111827),
                  height: 1.2,
                )
              : TextHelper.size15(context).copyWith(
                  fontWeight: FontWeight.w600,
                  color: themeController.isDark
                      ? Colors.white
                      : const Color(0xFF111827),
                  height: 1.1,
                ),
          maxLines: widget.cardType == 'new' ? 1 : 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (widget.cardType != 'new')
          SizedBox(height: 0.2.h), // No spacing for new cards
        if (widget.cardType != 'new')
          _buildProductDescription(
            themeController,
          ), // No description for new cards
      ],
    );
  }

  Widget _buildProductDescription(ThemeController themeController) {
    final description = widget.product?.description;
    if (description == null || description.isEmpty) {
      return SizedBox.shrink();
    }

    return Text(
      description,
      style: TextHelper.size9(context).copyWith(
        color: themeController.isDark
            ? Colors.grey[300]
            : const Color(0xFF6B7280),
        height: 1.1,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildPriceSection(ThemeController themeController) {
    final priceInfo = _getProductPrice();
    final price = priceInfo['price'];
    final originalPrice = priceInfo['originalPrice'];
    final discountPercentage = priceInfo['discountPercentage'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '₹${price.toStringAsFixed(0)}',
              style: widget.cardType == 'new'
                  ? TextHelper.size14(context).copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0EA5E9),
                    )
                  : TextHelper.size13(context).copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0EA5E9),
                    ),
            ),
            if (originalPrice > price) ...[
              SizedBox(
                width: widget.cardType == 'new' ? 1.w : 1.5.w,
              ), // Reduced spacing for new cards
              Text(
                '₹${originalPrice.toStringAsFixed(0)}',
                style: widget.cardType == 'new'
                    ? TextHelper.size13(context).copyWith(
                        color: const Color(0xFF6B7280),
                        decoration: TextDecoration.lineThrough,
                      )
                    : TextHelper.size10(context).copyWith(
                        color: const Color(0xFF6B7280),
                        decoration: TextDecoration.lineThrough,
                      ),
              ),
              SizedBox(
                width: widget.cardType == 'new' ? 0.5.w : 1.w,
              ), // Reduced spacing for new cards
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: widget.cardType == 'new' ? 0.8.w : 1.w,
                  vertical: widget.cardType == 'new' ? 0.1.h : 0.2.h,
                ), // More compact for new cards
                decoration: BoxDecoration(
                  color: const Color(0xFFE11D48).withAlpha((0.1 * 255).toInt()),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$discountPercentage% OFF',
                  style: widget.cardType == 'new'
                      ? TextHelper.size13(context).copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFE11D48),
                        )
                      : TextHelper.size10(context).copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFE11D48),
                        ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  String _getProductName() {
    // Try to get name from various possible fields (prioritize title)
    String name = 'Product Name';

    // Check for title first (primary field)
    if (widget.product?.title != null && widget.product!.title.isNotEmpty) {
      name = widget.product!.title;
    }
    // Check for name second (alias for title)
    else if (widget.product?.name != null && widget.product!.name.isNotEmpty) {
      name = widget.product!.name;
    }
    // Check for description as last resort
    else if (widget.product?.description != null &&
        widget.product!.description.isNotEmpty) {
      name = widget.product!.description;
    }
    // If all fields are empty, try to extract from product ID or use a generic name
    else {
      name = 'Product ${widget.product?.id ?? 'Unknown'}';
    }

    // If using description, truncate it
    if (name.length > 50) {
      name = name.substring(0, 47) + '...';
    }

    return name;
  }

  Map<String, dynamic> _getProductPrice() {
    final product = widget.product;
    if (product == null)
      return {'price': 0.0, 'originalPrice': 0.0, 'discountPercentage': 0};

    // If product has variants, use the first variant's price
    if (product.variants != null && product.variants.isNotEmpty) {
      final variant = product.variants.first;
      final variantPrice = variant.price ?? 0.0;
      final variantDiscount = variant.discount ?? 0.0;

      // The variantPrice is the original price, discount is the discount percentage
      // Calculate selling price: original_price - (original_price * discount/100)
      final originalPrice = variantPrice;
      final price = variantDiscount > 0
          ? variantPrice - (variantPrice * variantDiscount / 100)
          : variantPrice;

      // The discount field is already a percentage
      final discountPercentage = variantDiscount.round().clamp(0, 100);

      return {
        'price': price,
        'originalPrice': originalPrice,
        'discountPercentage': discountPercentage,
      };
    }

    // Use main product price when no variants
    // The price is the original price, discount is the discount percentage
    final originalPrice = product.price ?? 0.0;
    final discount = product.discount ?? 0.0;

    // Calculate selling price: original_price - (original_price * discount/100)
    final price = discount > 0
        ? originalPrice - (originalPrice * discount / 100)
        : originalPrice;

    // The discount field is already a percentage
    final discountPercentage = discount.round().clamp(0, 100);

    return {
      'price': price,
      'originalPrice': originalPrice,
      'discountPercentage': discountPercentage,
    };
  }

  Widget _buildFeaturedCardDesign(ThemeController themeController) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: SizedBox(
            width: 20.w, // More compact width for featured cards
            height: 28.h, // Reduced height for more compact design
            // decoration: BoxDecoration(
            //   borderRadius: BorderRadius.circular(16),
            //   boxShadow: [
            //     BoxShadow(
            //       color: Colors.black.withAlpha((0.1 * 255).toInt()),
            //       blurRadius: 20,
            //       offset: const Offset(0, 8),
            //     ),
            //     BoxShadow(
            //       color: Colors.black.withAlpha((0.05 * 255).toInt()),
            //       blurRadius: 8,
            //       offset: const Offset(0, 2),
            //     ),
            //   ],
            // ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Product image as background
                  _buildFeaturedProductImage(),

                  // Gradient overlay for smooth text transition
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 8.h, // Adjusted for new card height
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withAlpha((0.2 * 255).toInt()),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Curved white overlay at bottom
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildFeaturedInfoOverlay(themeController),
                  ),

                  // Rating badge at top-left
                  _buildFeaturedRatingBadge(),

                  // Discount badge at top-right
                  _buildFeaturedDiscountBadge(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeaturedProductImage() {
    if (widget.product?.images != null && widget.product.images.isNotEmpty) {
      return Image.network(
        widget.product.images.first,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildFeaturedPlaceholderImage();
        },
      );
    }
    return _buildFeaturedPlaceholderImage();
  }

  Widget _buildFeaturedPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PremiumColors.gold.withAlpha((0.1 * 255).toInt()),
            PremiumColors.gold.withAlpha((0.05 * 255).toInt()),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        Icons.shopping_bag_outlined,
        size: 8.w,
        color: PremiumColors.gold,
      ),
    );
  }

  Widget _buildFeaturedInfoOverlay(ThemeController themeController) {
    final priceInfo = _getProductPrice();
    final price = priceInfo['price'];
    final originalPrice = priceInfo['originalPrice'];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.95 * 255).toInt()),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).toInt()),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Product name
          Text(
            _getProductName(),
            style: TextHelper.size15(context).copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111827),
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          height(0.5.h),

          // Price and discount row
          Row(
            children: [
              Text(
                '₹${price.toStringAsFixed(0)}',
                style: TextHelper.size14(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E3A8A), // Deep Blue
                ),
              ),
              if (originalPrice > price) ...[
                width(1.w),
                Text(
                  '₹${originalPrice.toStringAsFixed(0)}',
                  style: TextHelper.size14(context).copyWith(
                    color: const Color(0xFF6B7280),
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedRatingBadge() {
    final rating = widget.product?.rating ?? 4.5;
    return Positioned(
      top: 1.h,
      left: 1.w,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.8.h),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha((0.6 * 255).toInt()),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.2 * 255).toInt()),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, color: Colors.amber, size: 3.w),
            SizedBox(width: 0.5.w),
            Text(
              rating.toString(),
              style: TextHelper.size14(
                context,
              ).copyWith(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedDiscountBadge() {
    final priceInfo = _getProductPrice();
    final discountPercentage = priceInfo['discountPercentage'];
    final discountAmount = priceInfo['originalPrice'] - priceInfo['price'];

    // Debug discount badge logic (remove in production)
    // print('=== DISCOUNT BADGE DEBUG ===');
    // print('Discount Percentage: $discountPercentage%');
    // print('Will show badge: ${discountAmount > 0}');

    // Show badge if there's any discount amount, even if percentage is 0
    if (discountAmount > 0) {
      return Positioned(
        top: 1.h,
        right: 1.w,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.8.h),
          decoration: BoxDecoration(
            color: const Color(0xFFE11D48),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE11D48).withAlpha((0.3 * 255).toInt()),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            discountPercentage > 0
                ? '$discountPercentage%'
                : '₹${discountAmount.toInt()} OFF',
            style: TextHelper.size14(
              context,
            ).copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
    return SizedBox.shrink();
  }

  Widget _buildTrendingCardDesign(ThemeController themeController) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 32.w, // Wider for trending cards
            height: 45.h, // Taller for more content
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: themeController.isDark
                    ? [PremiumColors.grey800, PremiumColors.grey900]
                    : [Colors.white, const Color(0xFFF8FAFC)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.1 * 255).toInt()),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withAlpha((0.05 * 255).toInt()),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                children: [
                  // Image section
                  _buildTrendingImageSection(themeController),
                  // Info section with all details and buttons
                  _buildTrendingInfoSection(themeController),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrendingImageSection(ThemeController themeController) {
    return Container(
      height: 20.h, // 45% of card height
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        gradient: LinearGradient(
          colors: [Colors.grey[50]!, Colors.grey[100]!, Colors.grey[200]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          _buildProductImage(),
          _buildTrendingRatingBadge(),
          _buildTrendingDiscountBadge(),
          _buildTrendingBadge(),
        ],
      ),
    );
  }

  Widget _buildTrendingInfoSection(ThemeController themeController) {
    final priceInfo = _getProductPrice();
    final price = priceInfo['price'];
    final originalPrice = priceInfo['originalPrice'];
    final discountPercentage = priceInfo['discountPercentage'];

    return Expanded(
      child: Container(
        padding: EdgeInsets.all(2.5.w),
        decoration: BoxDecoration(
          color: themeController.isDark ? PremiumColors.grey800 : Colors.white,
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.05 * 255).toInt()),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product name
            Text(
              _getProductName(),
              style: TextHelper.size14(context).copyWith(
                fontWeight: FontWeight.w600,
                color: themeController.isDark
                    ? Colors.white
                    : const Color(0xFF111827),
                height: 1.3,
                letterSpacing: 0.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 1.h),

            // Price section
            _buildTrendingPriceSection(
              themeController,
              price,
              originalPrice,
              discountPercentage,
            ),
            SizedBox(height: 1.h),

            // Action buttons
            _buildTrendingActionButtons(themeController),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingPriceSection(
    ThemeController themeController,
    double price,
    double originalPrice,
    int discountPercentage,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Current price
        Text(
          '₹${price.toStringAsFixed(0)}',
          style: TextHelper.size16(context).copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0EA5E9), // Sky Blue
          ),
        ),

        if (originalPrice > price) ...[
          width(1.w),
          Row(
            children: [
              Text(
                '₹${originalPrice.toStringAsFixed(0)}',
                style: TextHelper.size15(context).copyWith(
                  color: const Color(0xFF6B7280),
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              SizedBox(width: 1.w),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 1.5.w,
                  vertical: 0.3.h,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE11D48).withAlpha((0.1 * 255).toInt()),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$discountPercentage% OFF',
                  style: TextHelper.size14(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFE11D48),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildTrendingActionButtons(ThemeController themeController) {
    return Container(
      margin: EdgeInsets.only(top: 1.h),
      child: Row(
        children: [
          // Like/Favorite button
          Expanded(
            child: Obx(() {
              final wishlistController = Get.find<WishlistController>();
              final isFavorite = wishlistController.wishlistItems.any(
                (item) => item.id == widget.product?.id,
              );

              return GestureDetector(
                onTap: () {
                  if (widget.product != null) {
                    wishlistController.toggleWishlist(
                      product: widget.product,
                      context: context,
                    );
                  }
                  widget.onFavorite?.call();
                },
                child: Container(
                  height: 3.5.h,
                  decoration: BoxDecoration(
                    color: isFavorite
                        ? Colors.red.withAlpha((0.1 * 255).toInt())
                        : Colors.grey.withAlpha((0.1 * 255).toInt()),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isFavorite ? Colors.red : Colors.grey,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey,
                        size: 3.5.w,
                      ),
                      SizedBox(width: 0.8.w),
                      Text(
                        'Like',
                        style: TextHelper.size14(context).copyWith(
                          color: isFavorite ? Colors.red : Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          //   SizedBox(width: 1.5.w),
          //   // Add to cart button
          //   Expanded(
          //     child: GestureDetector(
          //       onTap: widget.onAddToCart,
          //       child: Container(
          //         height: 3.5.h,
          //         decoration: BoxDecoration(
          //           gradient: LinearGradient(
          //             colors: [const Color(0xFF0EA5E9), const Color(0xFF0284C7)],
          //             begin: Alignment.topLeft,
          //             end: Alignment.bottomRight,
          //           ),
          //           borderRadius: BorderRadius.circular(8),
          //           boxShadow: [
          //             BoxShadow(
          //               color: const Color(
          //                 0xFF0EA5E9,
          //               ).withAlpha((0.3 * 255).toInt()),
          //               blurRadius: 8,
          //               offset: const Offset(0, 2),
          //             ),
          //           ],
          //         ),
          //         child: Row(
          //           mainAxisAlignment: MainAxisAlignment.center,
          //           children: [
          //             Icon(
          //               Icons.shopping_cart_outlined,
          //               color: Colors.white,
          //               size: 3.5.w,
          //             ),
          //             SizedBox(width: 0.8.w),
          //             Text(
          //               'Add to Cart',
          //               style: TextHelper.size14(context).copyWith(
          //                 color: Colors.white,
          //                 fontWeight: FontWeight.w600,
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ),
          //   ),
        ],
      ),
    );
  }

  Widget _buildTrendingRatingBadge() {
    final rating = widget.product?.rating ?? 4.5;
    return Positioned(
      bottom: 1.h,
      left: 1.w,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.5.h),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha((0.6 * 255).toInt()),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.2 * 255).toInt()),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, color: Colors.amber, size: 3.w),
            width(0.5.w),
            Text(
              rating.toString(),
              style: TextHelper.size14(
                context,
              ).copyWith(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingDiscountBadge() {
    final priceInfo = _getProductPrice();
    final discountPercentage = priceInfo['discountPercentage'];
    final discountAmount = priceInfo['originalPrice'] - priceInfo['price'];

    if (discountAmount > 0) {
      return Positioned(
        top: 1.h,
        right: 1.w,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.8.h),
          decoration: BoxDecoration(
            color: const Color(0xFFE11D48),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE11D48).withAlpha((0.3 * 255).toInt()),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            discountPercentage > 0
                ? '$discountPercentage%'
                : '₹${discountAmount.toInt()} OFF',
            style: TextHelper.size14(
              context,
            ).copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
    return SizedBox.shrink();
  }
}
