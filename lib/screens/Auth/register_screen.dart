import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../controller/auth_controller.dart';
import '../../controller/theme_controller.dart';
import '../../utils/theme_config.dart';
import '../../widgets/textfields/custom_textfield.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AuthController authController;
  late ThemeController themeController;

  @override
  void initState() {
    super.initState();
    authController = Get.find<AuthController>();
    themeController = Get.find<ThemeController>();
    authController.initializeAnimations(this);
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
              PremiumColors.gold.withOpacity(0.1),
              PremiumColors.softBackground,
              PremiumColors.charcoal.withOpacity(0.05),
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
                  SizedBox(height: 4.h),
                  // Header Section
                  FadeTransition(
                    opacity:
                        authController.fadeAnimation ??
                        const AlwaysStoppedAnimation(1.0),
                    child: Column(
                      children: [
                        // Logo Container
                        Container(
                          width: 18.w,
                          height: 18.w,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                PremiumColors.gold,
                                PremiumColors.gold.withOpacity(0.8),
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: PremiumColors.gold.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.person_add_outlined,
                            size: 9.w,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        // Welcome Text
                        Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                            color: themeController.isDark
                                ? Colors.white
                                : PremiumColors.charcoal,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'Join our premium shopping experience',
                          style: TextStyle(
                            fontSize: 16.sp,
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
                  SizedBox(height: 3.h),
                  // Registration Form
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
                              color: themeController.isDark
                                  ? PremiumColors.grey800
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Name Field
                                CustomTextField(
                                  controller: authController.nameController,
                                  labelText: 'Full Name',
                                  hintText: 'Enter your full name',
                                  prefixIcon: Container(
                                    padding: EdgeInsets.all(1.w),
                                    decoration: BoxDecoration(
                                      color: PremiumColors.gold.withOpacity(
                                        0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.person_outline,
                                      color: PremiumColors.gold,
                                      size: 5.w,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your name';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 2.h),
                                // Email Field
                                CustomTextField(
                                  controller: authController.emailController,
                                  labelText: 'Email Address',
                                  hintText: 'Enter your email address',
                                  keyboardType: TextInputType.emailAddress,
                                  prefixIcon: Container(
                                    padding: EdgeInsets.all(1.w),
                                    decoration: BoxDecoration(
                                      color: PremiumColors.gold.withOpacity(
                                        0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.email_outlined,
                                      color: PremiumColors.gold,
                                      size: 5.w,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter an email';
                                    }
                                    if (!GetUtils.isEmail(value)) {
                                      return 'Please enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 2.h),
                                // Phone Field
                                CustomTextField(
                                  controller: authController.phoneController,
                                  labelText: 'Phone Number',
                                  hintText: 'Enter your phone number',
                                  keyboardType: TextInputType.phone,
                                  prefixIcon: Container(
                                    padding: EdgeInsets.all(1.w),
                                    decoration: BoxDecoration(
                                      color: PremiumColors.gold.withOpacity(
                                        0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.phone_outlined,
                                      color: PremiumColors.gold,
                                      size: 5.w,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your phone number';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 2.h),
                                // Password Field
                                Obx(
                                  () => CustomTextField(
                                    controller:
                                        authController.passwordController,
                                    labelText: 'Password',
                                    hintText: 'Enter your password',
                                    obscureText:
                                        !authController.isPasswordVisible.value,
                                    prefixIcon: Container(
                                      padding: EdgeInsets.all(1.w),
                                      decoration: BoxDecoration(
                                        color: PremiumColors.gold.withOpacity(
                                          0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.lock_outline,
                                        color: PremiumColors.gold,
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
                                          color: PremiumColors.gold,
                                          size: 5.w,
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Password is required';
                                      }
                                      if (value.length < 8) {
                                        return 'Password must be at least 8 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                // Confirm Password Field
                                Obx(
                                  () => CustomTextField(
                                    controller: authController
                                        .confirmPasswordController,
                                    labelText: 'Confirm Password',
                                    hintText: 'Confirm your password',
                                    obscureText: !authController
                                        .isConfirmPasswordVisible
                                        .value,
                                    prefixIcon: Container(
                                      padding: EdgeInsets.all(1.w),
                                      decoration: BoxDecoration(
                                        color: PremiumColors.gold.withOpacity(
                                          0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.lock_outline,
                                        color: PremiumColors.gold,
                                        size: 5.w,
                                      ),
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: authController
                                          .toggleConfirmPasswordVisibility,
                                      icon: Obx(
                                        () => Icon(
                                          authController
                                                  .isConfirmPasswordVisible
                                                  .value
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: PremiumColors.gold,
                                          size: 5.w,
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please confirm your password';
                                      }
                                      if (value !=
                                          authController
                                              .passwordController
                                              .text) {
                                        return 'Passwords do not match';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                // Referral Code Field (Optional)
                                CustomTextField(
                                  controller:
                                      authController.referralCodeController,
                                  labelText: 'Referral Code (Optional)',
                                  hintText:
                                      'Enter referral code if you have one',
                                  prefixIcon: Container(
                                    padding: EdgeInsets.all(1.w),
                                    decoration: BoxDecoration(
                                      color: PremiumColors.gold.withOpacity(
                                        0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.card_giftcard_outlined,
                                      color: PremiumColors.gold,
                                      size: 5.w,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 3.h),
                                // Register Button
                                Container(
                                  width: double.infinity,
                                  height: 6.h,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        PremiumColors.gold,
                                        PremiumColors.gold.withOpacity(0.8),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: PremiumColors.gold.withOpacity(
                                          0.3,
                                        ),
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
                                                      .handleRegister(context);
                                                }
                                              },
                                        child: Center(
                                          child: authController.isLoading.value
                                              ? SizedBox(
                                                  width: 4.w,
                                                  height: 4.w,
                                                  child: const CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(Colors.white),
                                                  ),
                                                )
                                              : Text(
                                                  'Create Account',
                                                  style: TextStyle(
                                                    fontSize: 16.sp,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                // Login Link
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Already have an account? ",
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: themeController.isDark
                                            ? Colors.white70
                                            : PremiumColors.grey600,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => Get.back(),
                                      child: Text(
                                        'Sign In',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: PremiumColors.gold,
                                          fontWeight: FontWeight.w700,
                                          decoration: TextDecoration.underline,
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
                  SizedBox(height: 3.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
