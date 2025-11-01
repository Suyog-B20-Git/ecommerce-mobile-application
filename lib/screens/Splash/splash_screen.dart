import 'package:ecommerce/utils/text_styles.dart';
import 'package:ecommerce/widgets/constant_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../controller/splash_controller.dart';
import '../../controller/theme_controller.dart';
import '../../controller/auth_controller.dart';
import '../../utils/theme_config.dart';
import '../../utils/storage_config.dart';
import '../../utils/app_enums.dart';
import '../../routes/routes.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = '/Splash';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late SplashController splashController;
  late ThemeController themeController;
  late AuthController authController;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    splashController = Get.find<SplashController>();
    themeController = Get.find<ThemeController>();
    authController = Get.find<AuthController>();

    // Initialize animations with this widget as TickerProvider
    splashController.initializeAnimations(this);

    // Start navigation after 2-3 seconds
    _startNavigation();
  }

  void _startNavigation() async {
    // Prevent multiple navigation calls
    if (_hasNavigated) return;

    // Wait for 2.5 seconds
    await Future.delayed(const Duration(milliseconds: 2500));

    // Wait for auth controller to complete initialization
    await _waitForAuthInitialization();

    // Prevent multiple navigation calls
    if (_hasNavigated) return;
    _hasNavigated = true;

    // Check authentication state
    if (authController.isAuthenticated) {
      // User is logged in, navigate to dashboard
      Get.offAllNamed(Routes.DASHBOARD_SCREEN);
    } else {
      // User is not logged in, check if onboarding is completed
      final onboardingCompleted = await StorageConfig.getValue(
        StorageKey.onboardingCompleted,
      );

      if (onboardingCompleted == true) {
        // Onboarding completed, go to login
        Get.offAllNamed(Routes.LOGIN_SCREEN);
      } else {
        // First time user, show onboarding
        Get.offAllNamed(Routes.ONBOARDING_SCREEN);
      }
    }
  }

  Future<void> _waitForAuthInitialization() async {
    // Wait for auth controller to complete its initialization
    int attempts = 0;
    const maxAttempts = 30; // 3 seconds max wait

    while (attempts < maxAttempts) {
      // Check if auth controller has completed initialization
      if (authController.isInitialized.value) {
        // Auth controller is fully initialized, break the loop
        break;
      }

      // Wait 100ms before next check
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }
  }

  @override
  void dispose() {
    // Stop the animation controller before disposing the widget
    splashController.animationController?.stop();
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
          child: Center(
            child: AnimatedBuilder(
              animation:
                  splashController.animationController ??
                  const AlwaysStoppedAnimation(1.0),
              builder: (context, child) {
                return FadeTransition(
                  opacity:
                      splashController.fadeAnimation ??
                      const AlwaysStoppedAnimation(1.0),
                  child: ScaleTransition(
                    scale:
                        splashController.scaleAnimation ??
                        const AlwaysStoppedAnimation(1.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Premium Logo Container
                        Container(
                          width: 50.w,
                          height: 50.w,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                PremiumColors.gold,
                                PremiumColors.gold.withAlpha((0.8 * 255).toInt()),
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: PremiumColors.gold.withAlpha((0.3 * 255).toInt()),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.shopping_bag_outlined,
                            size: 25.w,
                            color: Colors.white,
                          ),
                        ),
                        height(3.h),
                        // App Name with premium typography
                        Text(
                          'E-Commerce',
                          style: TextHelper.size22(context).copyWith(   
                            fontWeight: FontWeight.bold,
                            color: themeController.isDark
                                ? Colors.white
                                : PremiumColors.charcoal,
                            letterSpacing: 1.2,
                            shadows: [
                              Shadow(
                                color: Colors.black.withAlpha((0.1 * 255).toInt()),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        height(1.h),
                        // App Description
                        Text(
                          'Premium Shopping Experience',
                          style: TextHelper.size16(context).copyWith(
                            color: themeController.isDark
                                ? Colors.white70
                                : PremiumColors.grey600,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                        ),
                        height(4.h),
                        // Premium loading indicator
                        Container(
                          width: 15.w,
                          height: 15.w,
                          decoration: BoxDecoration(
                            color: PremiumColors.gold.withAlpha((0.1 * 255).toInt()),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: PremiumColors.gold.withAlpha((0.3 * 255).toInt()),
                              width: 1,
                            ),
                          ),
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              PremiumColors.gold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
