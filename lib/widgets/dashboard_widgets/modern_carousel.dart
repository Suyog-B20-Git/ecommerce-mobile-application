import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:get/get.dart';
import '../../utils/theme_config.dart';
import '../../controller/theme_controller.dart';
import '../../controller/carousel_controller.dart';
import '../dashboard_widgets/modern_product_card.dart';

class ModernCarousel extends StatefulWidget {
  final List<dynamic> items;
  final String cardType;
  final double? height;
  final bool autoScroll;
  final Duration autoScrollDuration;
  final Function(dynamic)? onItemTap;
  final Function(dynamic)? onFavorite;
  final Function(dynamic)? onAddToCart;

  const ModernCarousel({
    Key? key,
    required this.items,
    this.cardType = 'featured',
    this.height,
    this.autoScroll = true,
    this.autoScrollDuration = const Duration(seconds: 3),
    this.onItemTap,
    this.onFavorite,
    this.onAddToCart,
  }) : super(key: key);

  @override
  State<ModernCarousel> createState() => _ModernCarouselState();
}

class _ModernCarouselState extends State<ModernCarousel>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Timer? _autoScrollTimer;

  // GetX controller for reactive state
  late ModernCarouselController _controller;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Initialize GetX controller
    final String tag = 'carousel_${widget.cardType}_${widget.items.length}';
    _controller = Get.put(ModernCarouselController(), tag: tag);
    _controller.initializeCarousel(
      carouselItems: widget.items,
      type: widget.cardType,
      enableAutoScroll: widget.autoScroll,
      scrollDuration: widget.autoScrollDuration,
    );

    if (widget.autoScroll && widget.items.length > 1) {
      _startAutoScroll();
    }
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(widget.autoScrollDuration, (timer) {
      if (_pageController.hasClients && widget.items.length > 1) {
        _controller.currentIndex.value =
            (_controller.currentIndex.value + 1) % widget.items.length;
        _pageController.animateToPage(
          _controller.currentIndex.value,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    if (widget.items.isEmpty) {
      return _buildEmptyState(themeController);
    }

    return SizedBox(
      height: widget.height ?? _getCarouselHeight(),
      child: Stack(
        children: [
          _buildCarousel(themeController),
          _buildPageIndicators(themeController),
        ],
      ),
    );
  }

  double _getCarouselHeight() {
    switch (widget.cardType) {
      case 'trending':
        return 35.h;
      case 'bestseller':
        return 32.h;
      case 'new':
        return 30.h;
      default:
        return 28.h;
    }
  }

  Widget _buildCarousel(ThemeController themeController) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              _controller.currentIndex.value = index;
            },
            itemCount: widget.items.length,
            itemBuilder: (context, index) {
              final item = widget.items[index];
              return _buildCarouselItem(item, themeController, index);
            },
          ),
        );
      },
    );
  }

  Widget _buildCarouselItem(
    dynamic item,
    ThemeController themeController,
    int index,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.w),
      child: ModernProductCard(
        product: item,
        cardType: widget.cardType,
        onTap: () => widget.onItemTap?.call(item),
        onFavorite: () => widget.onFavorite?.call(item),
        onAddToCart: () => widget.onAddToCart?.call(item),
      ),
    );
  }

  Widget _buildPageIndicators(ThemeController themeController) {
    return Obx(() {
      if (widget.items.length <= 1) return const SizedBox();

      return Positioned(
        bottom: 2.h,
        left: 0,
        right: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.items.length,
            (index) => Container(
              margin: EdgeInsets.symmetric(horizontal: 1.w),
              width: _controller.currentIndex.value == index ? 6.w : 2.w,
              height: 2.w,
              decoration: BoxDecoration(
                color: _controller.currentIndex.value == index
                    ? PremiumColors.gold
                    : Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildEmptyState(ThemeController themeController) {
    return Container(
      height: widget.height ?? _getCarouselHeight(),
      decoration: BoxDecoration(
        color: themeController.isDark ? PremiumColors.grey800 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: PremiumColors.gold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 12.w,
                color: PremiumColors.gold,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'No items available',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: themeController.isDark
                    ? Colors.white70
                    : Colors.grey[600],
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Check back later for new items',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}

// Specialized carousel for trending products with 3D effects
class TrendingCarousel extends StatelessWidget {
  final List<dynamic> products;
  final Function(dynamic)? onItemTap;
  final Function(dynamic)? onFavorite;
  final Function(dynamic)? onAddToCart;

  const TrendingCarousel({
    Key? key,
    required this.products,
    this.onItemTap,
    this.onFavorite,
    this.onAddToCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // decoration: BoxDecoration(
      //   gradient: LinearGradient(
      //     colors: [
      //       Colors.orange.withAlpha((0.05 * 255).toInt()),
      //       Colors.orange.withAlpha((0.02 * 255).toInt()),
      //     ],
      //     begin: Alignment.topLeft,
      //     end: Alignment.bottomRight,
      //   ),
      //   borderRadius: BorderRadius.circular(20),
      // ),
      child: ModernCarousel(
        items: products,
        cardType: 'trending',
        height: 35.h,
        autoScroll: true,
        autoScrollDuration: const Duration(seconds: 4),
        onItemTap: onItemTap,
        onFavorite: onFavorite,
        onAddToCart: onAddToCart,
      ),
    );
  }
}

// Specialized carousel for best sellers with ranking
class BestSellersCarousel extends StatelessWidget {
  final List<dynamic> products;
  final Function(dynamic)? onItemTap;
  final Function(dynamic)? onFavorite;
  final Function(dynamic)? onAddToCart;

  const BestSellersCarousel({
    Key? key,
    required this.products,
    this.onItemTap,
    this.onFavorite,
    this.onAddToCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.withAlpha((0.05 * 255).toInt()),
            Colors.amber.withAlpha((0.02 * 255).toInt()),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ModernCarousel(
        items: products,
        cardType: 'bestseller',
        height: 32.h,
        autoScroll: true,
        autoScrollDuration: const Duration(seconds: 5),
        onItemTap: onItemTap,
        onFavorite: onFavorite,
        onAddToCart: onAddToCart,
      ),
    );
  }
}
