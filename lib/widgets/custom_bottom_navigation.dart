import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../utils/theme_config.dart';

class CustomBottomNavigation extends StatelessWidget {
  final RxInt currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8.h,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).toInt()),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              context: context,
              index: 0,
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              label: 'Home',
            ),
            _buildNavItem(
              context: context,
              index: 1,
              icon: Icons.category_outlined,
              activeIcon: Icons.category,
              label: 'Categories',
            ),
            _buildCenterItem(context),
            _buildNavItem(
              context: context,
              index: 2,
              icon: Icons.shopping_bag_outlined,
              activeIcon: Icons.shopping_bag,
              label: 'Orders',
            ),
            _buildNavItem(
              context: context,
              index: 3,
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isActive = currentIndex.value == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? PremiumColors.gold : Colors.grey[600],
              size: 6.w,
            ),
            SizedBox(height: 0.5.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: isActive ? PremiumColors.gold : Colors.grey[600],
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterItem(BuildContext context) {
    final isActive = currentIndex.value == 4;

    return GestureDetector(
      onTap: () => onTap(4),
      child: Container(
        width: 12.w,
        height: 12.w,
        decoration: BoxDecoration(
          color: isActive ? PremiumColors.gold : Colors.grey[100],
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? PremiumColors.gold.withAlpha((0.3 * 255).toInt())
                  : Colors.grey.withAlpha((0.2 * 255).toInt()),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.shopping_cart,
          color: isActive ? Colors.white : Colors.grey[600],
          size: 6.w,
        ),
      ),
    );
  }
}
