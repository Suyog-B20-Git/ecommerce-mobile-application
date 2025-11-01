import 'package:get/get.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/product/product_detail_screen.dart';
import '../screens/splash/splash_screen.dart';
import 'routes.dart';

class AppPages {
  AppPages._();

  static const Transition transition = Transition.native;
  static String INITIAL_ROUTE = Routes.SPLASH_SCREEN;

  static final route = [
    /// Splash & Onboarding
    GetPage(
      name: Routes.SPLASH_SCREEN,
      page: () => const SplashScreen(),
      transition: transition,
    ),
    GetPage(
      name: Routes.ONBOARDING_SCREEN,
      page: () => const OnboardingScreen(),
      transition: transition,
    ),

    /// Auth
    GetPage(
      name: Routes.LOGIN_SCREEN,
      page: () => const LoginScreen(),
      transition: transition,
    ),
    GetPage(
      name: Routes.REGISTER_SCREEN,
      page: () => const RegisterScreen(),
      transition: transition,
    ),

    /// Dashboard
    GetPage(
      name: Routes.DASHBOARD_SCREEN,
      page: () => const DashboardScreen(),
      transition: transition,
    ),

    /// Product Screens
    GetPage(
      name: Routes.PRODUCT_DETAIL_SCREEN,
      page: () => ProductDetailScreen(
        productId: Get.arguments['productId'] ?? '',
        product: Get.arguments['product'],
      ),
      transition: transition,
    ),
  ];
}
