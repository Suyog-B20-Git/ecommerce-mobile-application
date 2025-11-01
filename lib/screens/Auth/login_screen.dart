import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../controller/auth_controller.dart';
import '../../controller/theme_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/text_styles.dart';
import '../../utils/theme_config.dart';
import '../../widgets/constant_widgets.dart';
import '../../widgets/textfields/custom_textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AuthController authController;
  late ThemeController themeController;

  @override
  void initState() {
    super.initState();
    authController = Get.find<AuthController>();
    themeController = Get.find<ThemeController>();
    // Initialize animations with this widget as TickerProvider
    authController.initializeAnimations(this);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              PremiumColors.gold.withAlpha((0.1 * 255).toInt()),
              PremiumColors.softBackground,
              PremiumColors.charcoal.withAlpha((0.05 * 255).toInt()),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  height(10.h),
                  // Logo and Welcome Section with enhanced design
                  FadeTransition(
                    opacity:
                        authController.fadeAnimation ??
                        const AlwaysStoppedAnimation(1.0),
                    child: Column(
                      children: [
                        // Enhanced Logo Container with shadow and gradient
                        Container(
                          width: 18.w,
                          height: 18.w,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                PremiumColors.gold,
                                PremiumColors.gold.withAlpha(
                                  (0.8 * 255).toInt(),
                                ),
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: PremiumColors.gold.withAlpha(
                                  (0.3 * 255).toInt(),
                                ),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.shopping_bag_outlined,
                            size: 9.w,
                            color: Colors.white,
                          ),
                        ),
                        height(1.5.h),
                        // Enhanced Welcome Text with better typography
                        Text(
                          'Welcome Back!',
                          style: TextHelper.size22(context).copyWith(
                            fontWeight: FontWeight.bold,
                            color: themeController.isDark
                                ? Colors.white
                                : PremiumColors.charcoal,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        height(1.h),
                        Text(
                          'Sign in to your E-Commerce account',
                          style: TextHelper.size16(context).copyWith(
                            color: themeController.isDark
                                ? Colors.white70
                                : PremiumColors.grey600,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  height(1.h),
                  // Enhanced Login Form with card design
                  Expanded(
                    child: SingleChildScrollView(
                      child: SlideTransition(
                        position:
                            authController.slideAnimation ??
                            const AlwaysStoppedAnimation(Offset.zero),
                        child: FadeTransition(
                          opacity:
                              authController.fadeAnimation ??
                              const AlwaysStoppedAnimation(1.0),
                          child: Container(
                            padding: EdgeInsets.all(6.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(
                                    (0.1 * 255).toInt(),
                                  ),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Email Field with enhanced styling
                                CustomTextField(
                                  controller: authController.emailController,
                                  labelText: 'Email Address',
                                  hintText: 'Enter your email address',
                                  keyboardType: TextInputType.emailAddress,
                                  prefixIcon: Container(
                                    padding: EdgeInsets.all(1.w),
                                    decoration: BoxDecoration(
                                      color: ColorsForApp.primaryColor
                                          .withAlpha((0.1 * 255).toInt()),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.email_outlined,
                                      color: ColorsForApp.primaryColor,
                                      size: 5.w,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter an email'.tr;
                                    }
                                    return null;
                                  },
                                ),
                                height(2.h),
                                // Password Field with enhanced styling
                                Obx(
                                  () => CustomTextField(
                                    controller:
                                        authController.passwordController,
                                    labelText: 'Password',
                                    hintText: 'Enter your password',
                                    obscureText:
                                        !authController.isPasswordVisible.value,
                                    maxLines: 1,
                                    prefixIcon: Container(
                                      padding: EdgeInsets.all(1.w),
                                      decoration: BoxDecoration(
                                        color: ColorsForApp.primaryColor
                                            .withAlpha((0.1 * 255).toInt()),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.lock_outline,
                                        color: ColorsForApp.primaryColor,
                                        size: 5.w,
                                      ),
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: authController
                                          .togglePasswordVisibility,
                                      icon: Obx(
                                        () => Icon(
                                          authController.isPasswordVisible.value
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: ColorsForApp.primaryColor,
                                          size: 5.w,
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Password is required.'.tr;
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                height(1.h),
                                // Enhanced Remember Me and Forgot Password
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    // Enhanced Forgot Password
                                    GestureDetector(
                                      onTap: () {
                                        authController.handleForgotPassword;
                                      },
                                      child: Text(
                                        'Forgot Password?',
                                        style: TextHelper.size14(context)
                                            .copyWith(
                                              color: ColorsForApp.primaryColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                height(2.h),
                                // Enhanced Login Button with gradient
                                Container(
                                  width: double.infinity,
                                  height: 6.h,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        ColorsForApp.primaryColor,
                                        ColorsForApp.primaryColor.withAlpha(
                                          (0.8 * 255).toInt(),
                                        ),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: ColorsForApp.primaryColor
                                            .withAlpha((0.3 * 255).toInt()),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Obx(
                                    () => Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(15),
                                        onTap: authController.isLoading.value
                                            ? null
                                            : () async {
                                                if (_formKey.currentState!
                                                    .validate()) {
                                                  await authController
                                                      .handleLogin(context);
                                                }
                                              },
                                        child: Center(
                                          child: authController.isLoading.value
                                              ? SizedBox(
                                                  width: 4.w,
                                                  height: 4.w,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(Colors.white),
                                                  ),
                                                )
                                              : Text(
                                                  authController.loadingText,
                                                  style:
                                                      TextHelper.size16(
                                                        context,
                                                      ).copyWith(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                height(2.h),
                                // Enhanced Divider
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 1,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.transparent,
                                              ColorsForApp.primaryLightColor,
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 4.w,
                                      ),
                                      child: Text(
                                        'OR',
                                        style: TextHelper.size14(context)
                                            .copyWith(
                                              color: ColorsForApp.subTitleColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: 1,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.transparent,
                                              ColorsForApp.primaryLightColor,
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                height(2.h),
                                // Enhanced Social Login Buttons
                                Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => authController
                                            .handleSocialLogin('Google'),
                                        child: Container(
                                          height: 5.h,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: ColorsForApp
                                                  .primaryLightColor,
                                              width: 1.5,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            color: Colors.white,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.g_mobiledata,
                                                color: Colors.red,
                                                size: 5.w,
                                              ),
                                              width(2.5.w),
                                              Text(
                                                'Google',
                                                style:
                                                    TextHelper.size14(
                                                      context,
                                                    ).copyWith(
                                                      color: ColorsForApp
                                                          .colorBlackShade,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    width(4.w),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => authController
                                            .handleSocialLogin('Apple'),
                                        child: Container(
                                          height: 5.h,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: ColorsForApp
                                                  .primaryLightColor,
                                              width: 1.5,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            color: Colors.white,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.apple,
                                                color: Colors.black,
                                                size: 5.w,
                                              ),
                                              width(2.5.w),
                                              Text(
                                                'Apple',
                                                style:
                                                    TextHelper.size14(
                                                      context,
                                                    ).copyWith(
                                                      color: ColorsForApp
                                                          .colorBlackShade,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                height(2.h),
                                // Enhanced Sign Up Link
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Don't have an account? ",
                                      style: TextHelper.size14(context)
                                          .copyWith(
                                            color: ColorsForApp.subTitleColor,
                                          ),
                                    ),
                                    GestureDetector(
                                      onTap: authController.handleSignUp,
                                      child: Text(
                                        'Sign Up',
                                        style: TextHelper.size14(context)
                                            .copyWith(
                                              color: ColorsForApp.primaryColor,
                                              fontWeight: FontWeight.w700,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  height(3.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void clearController() {
    authController.emailController.clear();
    authController.passwordController.clear();
  }
}
