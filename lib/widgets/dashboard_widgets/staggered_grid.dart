import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:get/get.dart';
import '../../utils/theme_config.dart';
import '../../controller/theme_controller.dart';
import '../dashboard_widgets/modern_product_card.dart';

class StaggeredGrid extends StatelessWidget {
  final List<dynamic> items;
  final Function(dynamic)? onItemTap;
  final Function(dynamic)? onFavorite;
  final Function(dynamic)? onAddToCart;
  final int crossAxisCount;
  final double childAspectRatio;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  const StaggeredGrid({
    Key? key,
    required this.items,
    this.onItemTap,
    this.onFavorite,
    this.onAddToCart,
    this.crossAxisCount = 2,
    this.childAspectRatio = 0.75, // Better default aspect ratio
    this.mainAxisSpacing = 1.5, // Reduced default spacing
    this.crossAxisSpacing = 1.5, // Reduced default spacing
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    if (items.isEmpty) {
      return _buildEmptyState(themeController);
    }

    return Container(
      padding: EdgeInsets.only(
        left: 2.w,
        right: 2.w,
      ), // Only horizontal padding, no bottom padding
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero, // Remove any default padding
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspectRatio,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
        ),
        itemCount: items.length > 4 ? 4 : items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildStaggeredItem(item, themeController, index);
        },
      ),
    );
  }

  Widget _buildStaggeredItem(
    dynamic item,
    ThemeController themeController,
    int index,
  ) {
    // Create staggered heights for Pinterest-like effect with proper overflow handling
    final isTall = index % 3 == 0;
    final isShort = index % 5 == 0;

    return Container(
      height: isTall
          ? 24.h
          : (isShort ? 18.h : 21.h), // Reduced heights to prevent overflow
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ModernProductCard(
          product: item,
          cardType: 'new',
          onTap: () => onItemTap?.call(item),
          onFavorite: () => onFavorite?.call(item),
          onAddToCart: () => onAddToCart?.call(item),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeController themeController) {
    return Container(
      height: 30.h, // Reduced height to prevent overflow
      margin: EdgeInsets.symmetric(horizontal: 2.w), // Reduced margin
      decoration: BoxDecoration(
        color: themeController.isDark ? PremiumColors.grey800 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.08 * 255).toInt()),
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
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.new_releases, size: 12.w, color: Colors.green),
            ),
            SizedBox(height: 3.h),
            Text(
              'No new arrivals',
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
              'Check back later for fresh products',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}

// Specialized staggered grid for new arrivals
class NewArrivalsGrid extends StatelessWidget {
  final List<dynamic> products;
  final Function(dynamic)? onItemTap;
  final Function(dynamic)? onFavorite;
  final Function(dynamic)? onAddToCart;

  const NewArrivalsGrid({
    Key? key,
    required this.products,
    this.onItemTap,
    this.onFavorite,
    this.onAddToCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 4.w,
        right: 4.w,
        top: 2.h,
      ), // Equal padding from left and right, top padding, no bottom padding
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withAlpha((0.05 * 255).toInt()),
            Colors.green.withAlpha((0.02 * 255).toInt()),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: StaggeredGrid(
        items: products,
        crossAxisCount: 2,
        childAspectRatio: 1.1, // Increased aspect ratio for better fit
        mainAxisSpacing: 6.w, // Increased vertical spacing between rows
        crossAxisSpacing: 4.w, // Increased horizontal spacing between columns
        onItemTap: onItemTap,
        onFavorite: onFavorite,
        onAddToCart: onAddToCart,
      ),
    );
  }
}

// Masonry layout for mixed content
class MasonryGrid extends StatelessWidget {
  final List<dynamic> items;
  final Function(dynamic)? onItemTap;
  final Function(dynamic)? onFavorite;
  final Function(dynamic)? onAddToCart;

  const MasonryGrid({
    Key? key,
    required this.items,
    this.onItemTap,
    this.onFavorite,
    this.onAddToCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    if (items.isEmpty) {
      return _buildEmptyState(themeController);
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(children: _buildMasonryColumns(items, themeController)),
    );
  }

  List<Widget> _buildMasonryColumns(
    List<dynamic> items,
    ThemeController themeController,
  ) {
    final columns = <List<Widget>>[[], []];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final columnIndex = i % 2;

      columns[columnIndex].add(
        Container(
          margin: EdgeInsets.only(bottom: 2.h),
          child: ModernProductCard(
            product: item,
            cardType: 'new',
            onTap: () => onItemTap?.call(item),
            onFavorite: () => onFavorite?.call(item),
            onAddToCart: () => onAddToCart?.call(item),
          ),
        ),
      );
    }

    return [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Column(children: columns[0])),
          SizedBox(width: 2.w),
          Expanded(child: Column(children: columns[1])),
        ],
      ),
    ];
  }

  Widget _buildEmptyState(ThemeController themeController) {
    return Container(
      height: 40.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
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
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.grid_view, size: 12.w, color: Colors.green),
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
