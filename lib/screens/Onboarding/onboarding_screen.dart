import 'package:ecommerce/utils/text_styles.dart';
import 'package:ecommerce/widgets/constant_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../controller/onboarding_controller.dart';
import '../../controller/theme_controller.dart';
import '../../utils/theme_config.dart';

class OnboardingScreen extends StatefulWidget {
  static const String routeName = '/Onboarding';

  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late OnboardingController onboardingController;
  late ThemeController themeController;
  late PageController pageController;
  late AnimationController _animationController;
  late AnimationController _fadeController;
  late AnimationController _slideController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    onboardingController = Get.find<OnboardingController>();
    themeController = Get.find<ThemeController>();
    pageController = PageController();

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    onboardingController.initializeAnimations(this);
    _startAnimations();
  }

  void _startAnimations() {
    _animationController.forward();
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    pageController.dispose();
    _animationController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              themeController.isDark
                  ? PremiumColors.charcoal.withAlpha((0.9 * 255).toInt())
                  : Colors.white,
              themeController.isDark
                  ? PremiumColors.charcoal
                  : PremiumColors.softBackground,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Premium Skip button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Logo/Brand
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 1.h,
                      ),
                      decoration: BoxDecoration(
                        color: PremiumColors.gold.withAlpha(
                          (0.1 * 255).toInt(),
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: PremiumColors.gold.withAlpha(
                            (0.3 * 255).toInt(),
                          ),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            color: PremiumColors.gold,
                            size: 18.sp,
                          ),
                          width(1.w),
                          Text(
                            'E-Commerce',
                            style: TextHelper.size16(context).copyWith(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: PremiumColors.gold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Skip button
                    TextButton(
                      onPressed: () => onboardingController.skipOnboarding(),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 1.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'Skip',
                        style: TextHelper.size16(context).copyWith(
                          fontSize: 16.sp,
                          color: themeController.isDark
                              ? Colors.white70
                              : PremiumColors.grey600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Main content
              Expanded(
                child: PageView.builder(
                  controller: pageController,
                  onPageChanged: (index) {
                    onboardingController.currentPage.value = index;
                    _resetAndStartAnimations();
                  },
                  itemCount: onboardingController.onboardingPages.length,
                  itemBuilder: (context, index) {
                    return _buildOnboardingPage(
                      onboardingController.onboardingPages[index],
                      index,
                    );
                  },
                ),
              ),

              // Bottom section with premium design
              _buildBottomSection(),
            ],
          ),
        ),
      ),
    );
  }

  void _resetAndStartAnimations() {
    _animationController.reset();
    _fadeController.reset();
    _slideController.reset();
    _startAnimations();
  }

  Widget _buildOnboardingPage(OnboardingPage page, int index) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Premium illustration container
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 70.w,
                      height: 35.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: page.gradient,
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: page.gradient.first.withAlpha(
                              (0.3 * 255).toInt(),
                            ),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Background pattern
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withAlpha((0.1 * 255).toInt()),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Main content
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Smaller emoji illustration
                                Text(
                                  page.illustration,
                                  style: TextStyle(fontSize: 50.sp, height: 1),
                                ),
                                height(1.5.h),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  height(4.h),

                  // Title with premium typography
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      page.title,
                      style: TextHelper.size22(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: themeController.isDark
                            ? Colors.white
                            : PremiumColors.charcoal,
                        letterSpacing: 0.5,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  height(2.h),

                  // Description with premium styling
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      page.description,
                      style: TextHelper.size15(context).copyWith(
                        color: themeController.isDark
                            ? Colors.white70
                            : PremiumColors.grey600,
                        height: 1.5,
                        letterSpacing: 0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: themeController.isDark
            ? PremiumColors.charcoal.withAlpha((0.8 * 255).toInt())
            : Colors.white.withAlpha((0.9 * 255).toInt()),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).toInt()),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Premium page indicators
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                onboardingController.onboardingPages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 1.5.w),
                  width: onboardingController.currentPage.value == index
                      ? 32.w
                      : 8.w,
                  height: 1.2.h,
                  decoration: BoxDecoration(
                    gradient: onboardingController.currentPage.value == index
                        ? LinearGradient(
                            colors: onboardingController
                                .onboardingPages[index]
                                .gradient,
                          )
                        : null,
                    color: onboardingController.currentPage.value == index
                        ? null
                        : PremiumColors.grey300,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: onboardingController.currentPage.value == index
                        ? [
                            BoxShadow(
                              color: onboardingController
                                  .onboardingPages[index]
                                  .gradient
                                  .first
                                  .withAlpha((0.3 * 255).toInt()),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            ),
          ),

          height(3.h),

          // Premium navigation buttons
          Obx(
            () => Row(
              children: [
                // Previous button
                if (onboardingController.currentPage.value > 0)
                  Expanded(
                    child: Container(
                      height: 6.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: PremiumColors.gold.withAlpha(
                            (0.3 * 255).toInt(),
                          ),
                          width: 1.5,
                        ),
                      ),
                      child: TextButton(
                        onPressed: () {
                          pageController.previousPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOutCubic,
                          );
                        },
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.arrow_back_ios,
                              size: 16.sp,
                              color: PremiumColors.gold,
                            ),
                            width(1.w),
                            Text(
                              'Previous',
                              style: TextHelper.size14(context).copyWith(
                                color: PremiumColors.gold,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                if (onboardingController.currentPage.value > 0) width(4.w),

                // Next/Get Started button
                Expanded(
                  flex: onboardingController.currentPage.value > 0 ? 1 : 1,
                  child: Container(
                    height: 6.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors:
                            onboardingController.currentPage.value <
                                onboardingController.onboardingPages.length - 1
                            ? onboardingController
                                  .onboardingPages[onboardingController
                                      .currentPage
                                      .value]
                                  .gradient
                            : [
                                PremiumColors.gold,
                                PremiumColors.gold.withAlpha(
                                  (0.8 * 255).toInt(),
                                ),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color:
                              (onboardingController.currentPage.value <
                                          onboardingController
                                                  .onboardingPages
                                                  .length -
                                              1
                                      ? onboardingController
                                            .onboardingPages[onboardingController
                                                .currentPage
                                                .value]
                                            .gradient
                                            .first
                                      : PremiumColors.gold)
                                  .withAlpha((0.3 * 255).toInt()),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        if (onboardingController.currentPage.value <
                            onboardingController.onboardingPages.length - 1) {
                          pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOutCubic,
                          );
                        } else {
                          onboardingController.completeOnboarding();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            onboardingController.currentPage.value <
                                    onboardingController
                                            .onboardingPages
                                            .length -
                                        1
                                ? 'Next'
                                : 'Get Started',
                            style: TextHelper.size16(context).copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          width(2.w),
                          Icon(
                            onboardingController.currentPage.value <
                                    onboardingController
                                            .onboardingPages
                                            .length -
                                        1
                                ? Icons.arrow_forward_ios
                                : Icons.rocket_launch,
                            size: 16.sp,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
