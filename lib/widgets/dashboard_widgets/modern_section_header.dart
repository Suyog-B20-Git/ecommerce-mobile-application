import 'package:ecommerce/utils/text_styles.dart';
import 'package:ecommerce/widgets/constant_widgets.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:get/get.dart';
import '../../utils/theme_config.dart';
import '../../controller/theme_controller.dart';

class ModernSectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onViewAll;
  final String? viewAllText;
  final bool showGradient;

  const ModernSectionHeader({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.iconColor,
    this.onViewAll,
    this.viewAllText,
    this.showGradient = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTitleSection(context, themeController),
          if (onViewAll != null) _buildViewAllButton(context, themeController),
        ],
      ),
    );
  }

  Widget _buildTitleSection(
    BuildContext context,
    ThemeController themeController,
  ) {
    return Row(
      children: [
        _buildIconContainer(themeController),
        width(3.w),
        _buildTextSection(context, themeController),
      ],
    );
  }

  Widget _buildIconContainer(ThemeController themeController) {
    return Container(
      padding: EdgeInsets.all(1.5.w),
      decoration: BoxDecoration(
        gradient: showGradient
            ? LinearGradient(
                colors: [
                  (iconColor ?? PremiumColors.gold).withAlpha(
                    (0.2 * 255).toInt(),
                  ),
                  (iconColor ?? PremiumColors.gold).withAlpha(
                    (0.1 * 255).toInt(),
                  ),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: showGradient
            ? null
            : (iconColor ?? PremiumColors.gold).withAlpha((0.1 * 255).toInt()),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (iconColor ?? PremiumColors.gold).withAlpha(
              (0.2 * 255).toInt(),
            ),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: iconColor ?? PremiumColors.gold, size: 6.w),
    );
  }

  Widget _buildTextSection(
    BuildContext context,
    ThemeController themeController,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextHelper.size18(context).copyWith(
            fontWeight: FontWeight.bold,
            color: themeController.isDark
                ? Colors.white
                : PremiumColors.charcoal,
            letterSpacing: 0.5,
          ),
        ),
        height(0.5.h),
        Text(
          subtitle,
          style: TextHelper.size14(context).copyWith(
            color: themeController.isDark ? Colors.grey[600] : Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildViewAllButton(
    BuildContext context,
    ThemeController themeController,
  ) {
    return GestureDetector(
      onTap: onViewAll,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              PremiumColors.gold.withAlpha((0.1 * 255).toInt()),
              PremiumColors.gold.withAlpha((0.05 * 255).toInt()),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: PremiumColors.gold.withAlpha((0.3 * 255).toInt()),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: PremiumColors.gold.withAlpha((0.1 * 255).toInt()),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              viewAllText ?? 'home.viewAll'.tr,
              style: TextHelper.size14(context).copyWith(
                color: PremiumColors.gold,
                fontWeight: FontWeight.w600,
              ),
            ),
            width(1.w),
            Icon(Icons.arrow_forward_ios, color: PremiumColors.gold, size: 3.w),
          ],
        ),
      ),
    );
  }
}

// Specialized section headers for different types
class TrendingSectionHeader extends StatelessWidget {
  final VoidCallback? onViewAll;

  const TrendingSectionHeader({Key? key, this.onViewAll}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModernSectionHeader(
      title: '🔥 ${'home.trending'.tr}',
      subtitle: 'home.trendingSubtitle'.tr,
      icon: Icons.trending_up,
      iconColor: Colors.orange,
      onViewAll: onViewAll,
      showGradient: true,
    );
  }
}

class NewArrivalsSectionHeader extends StatelessWidget {
  final VoidCallback? onViewAll;

  const NewArrivalsSectionHeader({Key? key, this.onViewAll}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModernSectionHeader(
      title: '✨ ${'home.newArrivals'.tr}',
      subtitle: 'home.newArrivalsSubtitle'.tr,
      icon: Icons.new_releases,
      iconColor: Colors.green,
      onViewAll: onViewAll,
      showGradient: true,
    );
  }
}

class BestSellersSectionHeader extends StatelessWidget {
  final VoidCallback? onViewAll;

  const BestSellersSectionHeader({Key? key, this.onViewAll}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModernSectionHeader(
      title: '🏆 ${'home.bestSellers'.tr}',
      subtitle: 'home.bestSellersSubtitle'.tr,
      icon: Icons.emoji_events,
      iconColor: Colors.amber,
      onViewAll: onViewAll,
      showGradient: true,
    );
  }
}

class FeaturedSectionHeader extends StatelessWidget {
  final VoidCallback? onViewAll;

  const FeaturedSectionHeader({Key? key, this.onViewAll}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModernSectionHeader(
      title: '⭐ ${'home.featured'.tr}',
      subtitle: 'home.featuredSubtitle'.tr,
      icon: Icons.star,
      iconColor: PremiumColors.gold,
      onViewAll: onViewAll,
      showGradient: true,
    );
  }
}
