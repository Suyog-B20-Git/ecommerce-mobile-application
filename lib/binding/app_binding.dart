import 'package:get/get.dart';

import '../controller/app_controller.dart';
import '../controller/auth_controller.dart';
import '../controller/cart_controller.dart';
import '../controller/onboarding_controller.dart';
import '../controller/order_controller.dart';
import '../controller/product_controller.dart';
import '../controller/splash_controller.dart';
import '../controller/theme_controller.dart';
import '../controller/dashboard_controller.dart';
import '../controller/wishlist_controller.dart';
import '../controller/language_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<LanguageController>(LanguageController());
    Get.put<AppController>(AppController());
    Get.put<ThemeController>(ThemeController());
    Get.put<AuthController>(AuthController());
    Get.put<OnboardingController>(OnboardingController());
    Get.put<SplashController>(SplashController());
    Get.put<ProductController>(ProductController());
    Get.put<CartController>(CartController());
    Get.put<OrderController>(OrderController());
    Get.put<DashboardController>(DashboardController());
    Get.put<WishlistController>(WishlistController());
  }
}
