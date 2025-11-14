import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../controller/language_controller.dart';
import '../controller/theme_controller.dart';
import '../utils/theme_config.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  void _showLanguagePopup(BuildContext context) {
    final languageController = Get.find<LanguageController>();
    final themeController = Get.find<ThemeController>();

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height + 5,
        offset.dx + size.width,
        offset.dy + size.height + 5,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: themeController.isDark
          ? PremiumColors.charcoal
          : Colors.white,
      elevation: 8,
      items: [
        PopupMenuItem(
          value: 'en',
          child: Obx(() => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🇬🇧', style: TextStyle(fontSize: 20)),
              SizedBox(width: 2.w),
              Text(
                'language.english'.tr,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: languageController.currentLanguage == 'en'
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: languageController.currentLanguage == 'en'
                      ? PremiumColors.gold
                      : themeController.isDark
                          ? Colors.white
                          : PremiumColors.charcoal,
                ),
              ),
              SizedBox(width: 2.w),
              if (languageController.currentLanguage == 'en')
                Icon(
                  Icons.check,
                  color: PremiumColors.gold,
                  size: 5.w,
                ),
            ],
          )),
        ),
        PopupMenuItem(
          value: 'ar',
          child: Obx(() => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🇸🇦', style: TextStyle(fontSize: 20)),
              SizedBox(width: 2.w),
              Text(
                'language.arabic'.tr,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: languageController.currentLanguage == 'ar'
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: languageController.currentLanguage == 'ar'
                      ? PremiumColors.gold
                      : themeController.isDark
                          ? Colors.white
                          : PremiumColors.charcoal,
                ),
              ),
              SizedBox(width: 2.w),
              if (languageController.currentLanguage == 'ar')
                Icon(
                  Icons.check,
                  color: PremiumColors.gold,
                  size: 5.w,
                ),
            ],
          )),
        ),
      ],
    ).then((value) {
      if (value != null) {
        languageController.changeLanguage(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();
    final themeController = Get.find<ThemeController>();

    return Obx(() => GestureDetector(
      onTap: () => _showLanguagePopup(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: themeController.isDark
              ? PremiumColors.grey800
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: themeController.isDark
                ? PremiumColors.gold.withOpacity(0.3)
                : PremiumColors.gold.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.language,
              size: 4.w,
              color: themeController.isDark
                  ? PremiumColors.gold
                  : PremiumColors.charcoal,
            ),
            SizedBox(width: 1.5.w),
            Text(
              languageController.isArabic ? 'العربية' : 'English',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: themeController.isDark
                    ? PremiumColors.gold
                    : PremiumColors.charcoal,
              ),
            ),
          ],
        ),
      ),
    ));
  }
}

