import 'dart:async';
import 'package:ecommerce/utils/text_styles.dart';
import 'package:ecommerce/widgets/constant_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../controller/theme_controller.dart';
import '../../controller/auth_controller.dart';
import '../../controller/cart_controller.dart';
import '../../widgets/snackbar.dart' as CustomSnackBar;
import '../../controller/dashboard_controller.dart';
import '../../utils/theme_config.dart';
import '../../routes/routes.dart';
import '../../widgets/dashboard_widgets/banner_shimmer.dart';
import '../../widgets/dashboard_widgets/category_shimmer.dart';
import '../../widgets/dashboard_widgets/modern_section_header.dart';
import '../../widgets/dashboard_widgets/modern_carousel.dart';
import '../../widgets/dashboard_widgets/staggered_grid.dart';
import '../../widgets/dashboard_widgets/modern_product_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final authController = Get.find<AuthController>();
    final dashboardController = Get.find<DashboardController>();

    return CustomScaffold(
      backgroundColor: themeController.isDark
          ? PremiumColors.charcoal
          : PremiumColors.softBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Fixed App Bar with Search
            _buildFixedAppBar(context, themeController, authController),

            // Scrollable Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: () =>
                    dashboardController.refreshDashboard(context: context),
                child: CustomScrollView(
                  slivers: [
                    // Hero Banner/Carousel
                    _buildHeroBanner(
                      context,
                      themeController,
                      dashboardController,
                    ),

                    // Category Chips
                    _buildCategoryChips(
                      context,
                      themeController,
                      dashboardController,
                    ),

                    // Featured Products
                    _buildFeaturedProducts(
                      context,
                      themeController,
                      dashboardController,
                    ),

                    // Trending Products
                    _buildTrendingProducts(
                      context,
                      themeController,
                      dashboardController,
                    ),

                    // New Arrivals
                    _buildNewArrivals(
                      context,
                      themeController,
                      dashboardController,
                    ),

                    // Best Sellers
                    // _buildBestSellers(
                    //   context,
                    //   themeController,
                    //   dashboardController,
                    // ),

                    // Bottom Spacing
                    // SliverToBoxAdapter(child: SizedBox(height: 8.h)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFixedAppBar(
    BuildContext context,
    ThemeController themeController,
    AuthController authController,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: themeController.isDark ? PremiumColors.charcoal : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).toInt()),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Hamburger Menu
          IconButton(
            onPressed: () {
              // TODO: Open drawer
            },
            icon: Icon(
              Icons.menu,
              color: themeController.isDark
                  ? Colors.white
                  : PremiumColors.charcoal,
            ),
          ),

          // Search Bar
          Expanded(
            child: Container(
              height: 5.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: PremiumColors.gold.withAlpha((0.5 * 255).toInt()),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(color: PremiumColors.gold, width: 2),
              ),
              child: TextField(
                textAlignVertical: TextAlignVertical.center,
                style: TextStyle(
                  color: PremiumColors.charcoal,
                  fontSize: 14.sp,
                  height: 1.2,
                ),
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  filled: true,
                  fillColor: Colors.transparent,
                  hintStyle: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14.sp,
                    height: 1.2,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: PremiumColors.gold,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 1.5.h,
                  ),
                  isDense: true,
                ),
                readOnly: true,
                onTap: () {
                  Get.toNamed(Routes.SEARCH_SCREEN);
                },
              ),
            ),
          ),

          width(2.w),

          // Notifications
          Stack(
            children: [
              IconButton(
                onPressed: () {
                  // TODO: Navigate to notifications
                },
                icon: Icon(
                  Icons.notifications_outlined,
                  color: themeController.isDark
                      ? Colors.white
                      : PremiumColors.charcoal,
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 2.w,
                  height: 2.w,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),

          // Profile
          GestureDetector(
            onTap: () {
              // TODO: Navigate to profile
            },
            child: CircleAvatar(
              radius: 2.5.w,
              backgroundColor: PremiumColors.gold,
              child: Text(
                (authController.currentUser.value?.name.substring(0, 1) ?? 'U')
                    .toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner(
    BuildContext context,
    ThemeController themeController,
    DashboardController dashboardController,
  ) {
    // No hardcoded banners - only show API data

    return SliverToBoxAdapter(
      child: Container(
        height: 20.h,
        margin: EdgeInsets.all(4.w),
        child: Obx(() {
          // Show shimmer while loading
          if (dashboardController.isBannersLoading.value) {
            return const BannerShimmer();
          }

          // Show empty state if no banners
          if (dashboardController.banners.isEmpty) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    PremiumColors.gold.withOpacity(0.1),
                    PremiumColors.gold.withOpacity(0.05),
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image, size: 8.w, color: PremiumColors.gold),
                    SizedBox(height: 2.h),
                    Text(
                      'No banners available',
                      style: TextStyle(
                        color: themeController.isDark
                            ? Colors.white70
                            : Colors.grey[600],
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Show carousel with banners
          return _AutoScrollCarousel(banners: dashboardController.banners);
        }),
      ),
    );
  }
}

// Auto-scroll carousel widget
class _AutoScrollCarousel extends StatefulWidget {
  final List<Map<String, dynamic>> banners;

  const _AutoScrollCarousel({required this.banners});

  @override
  State<_AutoScrollCarousel> createState() => _AutoScrollCarouselState();
}

class _AutoScrollCarouselState extends State<_AutoScrollCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        _currentIndex = (_currentIndex + 1) % widget.banners.length;
        _pageController.animateToPage(
          _currentIndex,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: widget.banners.length,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemBuilder: (context, index) {
            final banner = widget.banners[index];
            return Container(
              margin: EdgeInsets.only(right: 2.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.1 * 255).toInt()),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    // Background Image
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: Image.network(
                        banner['image'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  banner['color'],
                                  banner['color'].withAlpha(
                                    (0.8 * 255).toInt(),
                                  ),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.image,
                                size: 8.w,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Gradient Overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withAlpha((0.7 * 255).toInt()),
                          ],
                        ),
                      ),
                    ),

                    // Content
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Padding(
                        padding: EdgeInsets.all(4.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              banner['title'],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            height(1.h),
                            Text(
                              banner['subtitle'],
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12.sp,
                              ),
                            ),
                            height(2.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 3.w,
                                vertical: 1.h,
                              ),
                              decoration: BoxDecoration(
                                color: PremiumColors.gold,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Shop Now',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        // Page Indicators
        Positioned(
          bottom: 2.h,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.banners.length,
              (index) => Container(
                margin: EdgeInsets.symmetric(horizontal: 1.w),
                width: _currentIndex == index ? 6.w : 2.w,
                height: 2.w,
                decoration: BoxDecoration(
                  color: _currentIndex == index
                      ? Colors.white
                      : Colors.white.withAlpha((0.5 * 255).toInt()),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Widget _buildCategoryChips(
  BuildContext context,
  ThemeController themeController,
  DashboardController dashboardController,
) {
  // No hardcoded categories - only show API data

  return SliverToBoxAdapter(
    child: SizedBox(
      height: 12.h,
      child: Obx(() {
        // Show shimmer while loading
        if (dashboardController.isLoading.value) {
          return const CategoryShimmer();
        }

        // Only show categories if API has data
        if (dashboardController.featuredCategories.isEmpty) {
          return SizedBox(
            height: 12.h,
            child: Center(
              child: Text(
                'No categories available',
                style: TextHelper.size14(context).copyWith(
                  color: themeController.isDark
                      ? Colors.white70
                      : Colors.grey[600],
                ),
              ),
            ),
          );
        }

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          itemCount: dashboardController.featuredCategories.length,
          itemBuilder: (context, index) {
            final category = dashboardController.featuredCategories[index];

            return Container(
              width: 20.w, // Reduced width to prevent overflow
              margin: EdgeInsets.only(right: 2.w), // Reduced margin
              child: GestureDetector(
                onTap: () {
                  // TODO: Navigate to category products
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment
                      .center, // Center align to prevent overflow
                  children: [
                    // Category Image with Premium Shadow - No white container
                    Container(
                      width: 16.w, // Reduced size
                      height: 16.w, // Reduced size
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          16,
                        ), // Adjusted radius
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha((0.15 * 255).toInt()),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                          BoxShadow(
                            color: Colors.black.withAlpha((0.08 * 255).toInt()),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          16,
                        ), // Adjusted radius
                        child:
                            category.image != null && category.image!.isNotEmpty
                            ? Image.network(
                                category.image!,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          PremiumColors.gold.withAlpha(
                                            (0.8 * 255).toInt(),
                                          ),
                                          PremiumColors.gold.withAlpha(
                                            (0.6 * 255).toInt(),
                                          ),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.category,
                                      color: Colors.white,
                                      size: 8.w, // Reduced icon size
                                    ),
                                  );
                                },
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      PremiumColors.gold.withAlpha(
                                        (0.8 * 255).toInt(),
                                      ),
                                      PremiumColors.gold.withAlpha(
                                        (0.6 * 255).toInt(),
                                      ),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Icon(
                                  Icons.category,
                                  color: Colors.white,
                                  size: 8.w, // Reduced icon size
                                ),
                              ),
                      ),
                    ),
                    height(1.h),
                    // Category Name with Premium Typography
                    Text(
                      category.name,
                      style: TextHelper.size14(context).copyWith(
                        // Reduced font size
                        color: themeController.isDark
                            ? Colors.white
                            : PremiumColors.charcoal,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                      textAlign: TextAlign.center, // Center align text
                      maxLines: 2, // Allow 2 lines for long names
                      overflow:
                          TextOverflow.ellipsis, // Handle overflow gracefully
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    ),
  );
}

Widget _buildFeaturedProducts(
  BuildContext context,
  ThemeController themeController,
  DashboardController dashboardController,
) {
  return SliverToBoxAdapter(
    child: Container(
      margin: EdgeInsets.symmetric(vertical: 1.5.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Modern Section Header
          FeaturedSectionHeader(
            onViewAll: () {
              // TODO: Navigate to all featured products
            },
          ),

          // Featured Products Grid (2-column with better spacing)
          SizedBox(
            height: 30.h,
            child: Obx(() {
              if (dashboardController.isLoading.value) {
                return _buildProductShimmer();
              }

              if (dashboardController.featuredProducts.isEmpty) {
                return _buildEmptyProductsState(
                  context,
                  themeController,
                  'No featured products available',
                  Icons.star_outline,
                );
              }

              return GridView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  childAspectRatio: 0.7, // Adjusted for new compact cards
                  mainAxisSpacing: 3.w, // Reduced spacing for compact design
                ),
                itemCount: dashboardController.featuredProducts.length,
                itemBuilder: (context, index) {
                  final product = dashboardController.featuredProducts[index];
                  return ModernProductCard(
                    product: product,
                    cardType: 'featured',
                    onTap: () {
                      Get.toNamed(
                        Routes.PRODUCT_DETAIL_SCREEN,
                        arguments: {
                          'productId': product.id,
                          'product': product,
                        },
                      );
                    },
                    onFavorite: () {
                      // TODO: Toggle favorite
                    },
                    onAddToCart: () {
                      _handleAddToCart(context, product);
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    ),
  );
}

Widget _buildTrendingProducts(
  BuildContext context,
  ThemeController themeController,
  DashboardController dashboardController,
) {
  return SliverToBoxAdapter(
    child: Container(
      margin: EdgeInsets.symmetric(vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Modern Section Header
          TrendingSectionHeader(
            onViewAll: () {
              // TODO: Navigate to all trending products
            },
          ),

          // Modern Carousel with 3D Effects
          SizedBox(
            height: 35.h,
            child: Obx(() {
              if (dashboardController.isLoading.value) {
                return _buildProductShimmer();
              }

              if (dashboardController.trendingProducts.isEmpty) {
                return _buildEmptyProductsState(
                  context,
                  themeController,
                  'No trending products available',
                  Icons.trending_up,
                );
              }

              return TrendingCarousel(
                products: dashboardController.trendingProducts,
                onItemTap: (product) {
                  Get.toNamed(
                    Routes.PRODUCT_DETAIL_SCREEN,
                    arguments: {'productId': product.id, 'product': product},
                  );
                },
                onFavorite: (product) {
                  // TODO: Toggle favorite
                },
                onAddToCart: (product) {
                  _handleAddToCart(context, product);
                },
              );
            }),
          ),
        ],
      ),
    ),
  );
}

Widget _buildNewArrivals(
  BuildContext context,
  ThemeController themeController,
  DashboardController dashboardController,
) {
  return SliverToBoxAdapter(
    child: Container(
      margin: EdgeInsets.symmetric(vertical: 1.5.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Modern Section Header
          NewArrivalsSectionHeader(
            onViewAll: () {
              // TODO: Navigate to all new arrivals
            },
          ),

          // Staggered Grid Layout (Pinterest-style)
          SizedBox(
            height: 45.h,
            child: Obx(() {
              if (dashboardController.isLoading.value) {
                return _buildProductShimmer();
              }

              if (dashboardController.newArrivals.isEmpty) {
                return _buildEmptyProductsState(
                  context,
                  themeController,
                  'No new arrivals available',
                  Icons.new_releases,
                );
              }

              return NewArrivalsGrid(
                products: dashboardController.newArrivals,
                onItemTap: (product) {
                  Get.toNamed(
                    Routes.PRODUCT_DETAIL_SCREEN,
                    arguments: {'productId': product.id, 'product': product},
                  );
                },
                onFavorite: (product) {
                  // TODO: Toggle favorite
                },
                onAddToCart: (product) {
                  _handleAddToCart(context, product);
                },
              );
            }),
          ),
        ],
      ),
    ),
  );
}

void _handleAddToCart(BuildContext context, dynamic product) async {
  try {
    final cartController = Get.find<CartController>();

    String productId = product.id ?? product['_id'] ?? '';
    String? variantId;
    Map<String, dynamic>? variantAttributes;

    // Prefer first in-stock variant if available
    if (product.variants != null && product.variants.isNotEmpty) {
      final v = (product.variants as List).firstWhere(
        (vv) => (vv.stock ?? vv['stock'] ?? 0) > 0,
        orElse: () => product.variants.first,
      );
      variantId = v.sku ?? v['sku'];
      final color = v.color ?? v['color'];
      final size = v.size ?? v['size'];
      variantAttributes = {
        if (color != null) 'color': color,
        if (size != null) 'size': size,
      };
    }

    // Debug log payload
    try {
      print(
        '[Home] AddToCart tapped => productId: ' +
            productId +
            ', variantId: ' +
            (variantId?.toString() ?? 'null') +
            ', attrs: ' +
            (variantAttributes?.toString() ?? 'null'),
      );
    } catch (_) {}

    final ok = await cartController.addToCart(
      productId: productId,
      quantity: 1,
      variantId: variantId,
      variantAttributes: variantAttributes,
      context: context,
    );

    if (!ok) {
      CustomSnackBar.SnackBar.error(
        title: 'Add to Cart',
        message: 'Failed to add item to cart',
      );
    }
  } catch (e) {
    CustomSnackBar.SnackBar.error(
      title: 'Add to Cart',
      message: 'Something went wrong',
    );
  }
}

Widget _buildBestSellers(
  BuildContext context,
  ThemeController themeController,
  DashboardController dashboardController,
) {
  return SliverToBoxAdapter(
    child: Container(
      margin: EdgeInsets.symmetric(vertical: 1.5.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Modern Section Header
          BestSellersSectionHeader(
            onViewAll: () {
              // TODO: Navigate to all best sellers
            },
          ),

          // Best Sellers Carousel with Ranking
          SizedBox(
            height: 32.h,
            child: Obx(() {
              if (dashboardController.isLoading.value) {
                return _buildProductShimmer();
              }

              if (dashboardController.bestSellers.isEmpty) {
                return _buildEmptyProductsState(
                  context,
                  themeController,
                  'No best sellers available',
                  Icons.emoji_events,
                );
              }

              return BestSellersCarousel(
                products: dashboardController.bestSellers,
                onItemTap: (product) {
                  // TODO: Navigate to product details
                },
                onFavorite: (product) {
                  // TODO: Toggle favorite
                },
                onAddToCart: (product) {
                  // TODO: Add to cart
                },
              );
            }),
          ),
        ],
      ),
    ),
  );
}

// Helper method for product shimmer loading
Widget _buildProductShimmer() {
  return ListView.builder(
    scrollDirection: Axis.horizontal,
    padding: EdgeInsets.symmetric(horizontal: 4.w),
    itemCount: 3, // Show 3 shimmer items
    itemBuilder: (context, index) {
      return Container(
        width: 42.w,
        margin: EdgeInsets.only(right: 3.w),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image shimmer
            Container(
              height: 20.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
            // Content shimmer
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(3.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 2.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Container(
                      height: 1.5.h,
                      width: 8.w,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Container(
                      height: 2.h,
                      width: 12.w,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

// Helper method for empty products state
Widget _buildEmptyProductsState(
  BuildContext context,
  ThemeController themeController,
  String message,
  IconData icon,
) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: PremiumColors.gold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, size: 12.w, color: PremiumColors.gold),
        ),
        SizedBox(height: 3.h),
        Text(
          message,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: themeController.isDark ? Colors.white70 : Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 1.h),
        Text(
          'Check back later for new products',
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
