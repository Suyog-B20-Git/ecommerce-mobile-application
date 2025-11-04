import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../controller/theme_controller.dart';
import '../../controller/auth_controller.dart';
import '../../utils/theme_config.dart';
import '../../utils/text_styles.dart';
import '../../routes/routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: themeController.isDark
          ? PremiumColors.charcoal
          : PremiumColors.softBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Header
              _buildProfileHeader(context, themeController, authController),

              // Profile Options
              _buildProfileOptions(context, themeController, authController),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    ThemeController themeController,
    AuthController authController,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PremiumColors.gold,
            PremiumColors.gold.withAlpha((0.8 * 255).toInt()),
          ],
        ),
      ),
      child: Column(
        children: [
          // Profile Picture
          CircleAvatar(
            radius: 8.w,
            backgroundColor: Colors.white,
            child: Text(
              (authController.currentUser.value?.name != null
                  ? authController.currentUser.value!.name
                        .substring(0, 1)
                        .toUpperCase()
                  : 'U'),
              style: TextHelper.size20(context).copyWith(
                color: PremiumColors.gold,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          SizedBox(height: 2.h),

          // User Name
          Obx(
            () => Text(
              authController.currentUser.value?.name ?? 'User',
              style: TextHelper.size18(
                context,
              ).copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),

          SizedBox(height: 1.h),

          // User Email
          Obx(
            () => Text(
              authController.currentUser.value?.email ?? 'user@example.com',
              style: TextHelper.size14(
                context,
              ).copyWith(color: Colors.white.withAlpha((0.9 * 255).toInt())),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOptions(
    BuildContext context,
    ThemeController themeController,
    AuthController authController,
  ) {
    return Container(
      margin: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: themeController.isDark ? PremiumColors.grey800 : Colors.white,
        // borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).toInt()),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildProfileOption(
            context: context,
            themeController: themeController,
            icon: Icons.person_outline,
            title: 'Edit Profile',
            subtitle: 'Update your personal information',
            onTap: () {
              Get.toNamed(Routes.EDIT_PROFILE_SCREEN);
            },
          ),
          _buildDivider(),
          _buildProfileOption(
            context: context,
            themeController: themeController,
            icon: Icons.location_on_outlined,
            title: 'Addresses',
            subtitle: 'Manage your delivery addresses',
            onTap: () {
              Get.toNamed(Routes.ADDRESS_SCREEN);
            },
          ),
          _buildDivider(),
          _buildProfileOption(
            context: context,
            themeController: themeController,
            icon: Icons.payment_outlined,
            title: 'Payment Methods',
            subtitle: 'Manage your payment options',
            onTap: () {
              // TODO: Navigate to payment methods
            },
          ),
          _buildDivider(),
          _buildProfileOption(
            context: context,
            themeController: themeController,
            icon: Icons.favorite_outline,
            title: 'Wishlist',
            subtitle: 'Your saved items',
            onTap: () {
              Get.toNamed(Routes.WISHLIST_SCREEN);
            },
          ),
          _buildDivider(),
          _buildProfileOption(
            context: context,
            themeController: themeController,
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Manage notification preferences',
            onTap: () {
              // TODO: Navigate to notifications
            },
          ),
          _buildDivider(),
          _buildProfileOption(
            context: context,
            themeController: themeController,
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Get help and contact support',
            onTap: () {
              // TODO: Navigate to help
            },
          ),
          _buildDivider(),
          _buildProfileOption(
            context: context,
            themeController: themeController,
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'App version and information',
            onTap: () {
              // TODO: Navigate to about
            },
          ),
          _buildDivider(),
          _buildProfileOption(
            context: context,
            themeController: themeController,
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'Sign out of your account',
            onTap: () {
              _showLogoutDialog(context, authController);
            },
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption({
    required BuildContext context,
    required ThemeController themeController,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: isDestructive
              ? Colors.red.withAlpha((0.1 * 255).toInt())
              : PremiumColors.gold.withAlpha((0.1 * 255).toInt()),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isDestructive ? Colors.red : PremiumColors.gold,
          size: 6.w,
        ),
      ),
      title: Text(
        title,
        style: TextHelper.size16(context).copyWith(
          fontWeight: FontWeight.w600,
          color: isDestructive
              ? Colors.red
              : (themeController.isDark
                    ? Colors.white
                    : PremiumColors.charcoal),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextHelper.size14(context).copyWith(color: Colors.grey[600]),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 4.w,
        color: Colors.grey[400],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 0.5, color: Colors.grey[200]);
  }

  void _showLogoutDialog(BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Logout',
            style: TextHelper.size18(
              context,
            ).copyWith(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextHelper.size14(context),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextHelper.size14(
                  context,
                ).copyWith(color: Colors.grey[600]),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                authController.handleLogout(context);
              },
              child: Text(
                'Logout',
                style: TextHelper.size14(
                  context,
                ).copyWith(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}
