import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/theme_controller.dart';
import '../../controller/auth_controller.dart';
import '../../controller/dashboard_controller.dart';
import '../../widgets/custom_bottom_navigation.dart';
import 'home_screen.dart';
import 'categories_screen.dart';
import 'orders_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late ThemeController themeController;
  late AuthController authController;
  late DashboardController dashboardController;
  final RxInt currentIndex = 0.obs;

  @override
  void initState() {
    super.initState();
    themeController = Get.find<ThemeController>();
    authController = Get.find<AuthController>();
    dashboardController = Get.find<DashboardController>();

    // Load dashboard data after build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      dashboardController.loadDashboardData(context: context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: currentIndex.value,
          children: const [
            HomeScreen(),
            CategoriesScreen(),
            OrdersScreen(),
            ProfileScreen(),
            CartScreen(),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: currentIndex,
        onTap: (index) {
          currentIndex.value = index;
        },
      ),
    );
  }
}
