import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';

import '../repository/auth_repository.dart';
import '../models/user_model.dart';
import '../routes/routes.dart';
import '../utils/app_enums.dart';
import '../utils/storage_config.dart';
import '../widgets/toastification.dart';
import 'app_controller.dart';

class AuthController extends GetxController {
  final AppController appController = Get.find();

  // Form Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final referralCodeController = TextEditingController();

  // Observable Variables
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final isLoading = false.obs;
  final rememberMe = false.obs;
  final currentUser = Rxn<UserModel>();
  final isInitialized = false.obs;

  // Animation Controllers - will be initialized when needed
  AnimationController? animationController;
  Animation<double>? fadeAnimation;
  Animation<Offset>? slideAnimation;

  @override
  void onInit() {
    super.onInit();
    // Initialize user state from storage
    _initializeUserState();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    confirmPasswordController.dispose();
    referralCodeController.dispose();
    animationController?.dispose();
    super.onClose();
  }

  Future<void> _initializeUserState() async {
    try {
      // Get stored values
      final token = await StorageConfig.fetchValue(StorageKey.userToken);
      final userId = await StorageConfig.fetchValue(StorageKey.userId);
      final userEmail = await StorageConfig.fetchValue(StorageKey.userEmail);
      final userName = await StorageConfig.fetchValue(StorageKey.userName);

      // Update app controller with stored token
      if (token != null && token.isNotEmpty) {
        appController.updateToken(token);
      }

      // Update current user with stored data
      if (userId != null && userEmail != null && userName != null) {
        currentUser.value = UserModel(
          id: userId,
          name: userName,
          email: userEmail,
          phone: '',
          preferences: UserPreferences(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
    } catch (e) {
      // Handle any errors silently
      print('Error initializing user state: $e');
    } finally {
      // Mark initialization as complete
      isInitialized.value = true;
    }
  }

  void initializeAnimations(TickerProvider vsync) {
    animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: vsync,
    );

    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController!,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: animationController!,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
          ),
        );

    animationController!.forward();
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // Toggle confirm password visibility
  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  // Toggle remember me
  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
  }

  // Handle forgot password
  void handleForgotPassword() {
    // TODO: Navigate to forgot password screen
    // _showSnackbar('Forgot Password', 'Forgot password functionality will be implemented soon.');
    // ToastHelper.showToast(context: context, message: 'Please fill in all fields', type: ToastificationType.error);
  }

  // Handle sign up
  void handleSignUp() {
    Get.toNamed(Routes.REGISTER_SCREEN);
  }

  // Handle social login
  void handleSocialLogin(String provider) {
    // TODO: Implement social login
    // _showSnackbar('Social Login', '$provider login will be implemented soon.');
  }

  Future<void> handleLogin(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ToastHelper.showToast(
        context: context,
        message: 'Please fill in all fields',
        type: ToastificationType.error,
      );
      return;
    }

    isLoading.value = true;

    try {
      final response = await AuthRepository.loginCustomer(
        email: email,
        password: password,
        context: context,
      );

      if (response != null &&
          response.isSuccess &&
          response.accessToken.isNotEmpty) {
        // Store user data and token using dot notation
        currentUser.value = response.user;
        appController.updateToken(response.accessToken);

        // Store tokens in new format
        await LocalStorage.storeValue(
          StorageKey.userToken,
          response.accessToken,
        );
        await LocalStorage.storeValue(
          StorageKey.accessToken,
          response.accessToken,
        );
        await LocalStorage.storeValue(
          StorageKey.refreshToken,
          response.refreshToken,
        );
        await LocalStorage.storeValue(StorageKey.userId, response.user.id);
        await LocalStorage.storeValue(
          StorageKey.userEmail,
          response.user.email,
        );
        await LocalStorage.storeValue(StorageKey.userName, response.user.name);

        // Navigate to dashboard
        Get.offAllNamed(Routes.DASHBOARD_SCREEN);

        // Clear form
        clearForm();
        ToastHelper.showToast(
          context: context,
          message: response.message,
          type: ToastificationType.success,
        );
      } else {
        ToastHelper.showToast(
          context: context,
          message: response?.message ?? 'Login failed',
          type: ToastificationType.error,
        );
      }
    } catch (e) {
      ToastHelper.showToast(
        context: context,
        message: 'Login failed. Please try again.',
        type: ToastificationType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> handleRegister(BuildContext context) async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final referralCode = referralCodeController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ToastHelper.showToast(
        context: context,
        message: 'Please fill in all required fields',
        type: ToastificationType.error,
      );
      return;
    }

    if (password != confirmPassword) {
      ToastHelper.showToast(
        context: context,
        message: 'Passwords do not match',
        type: ToastificationType.error,
      );
      return;
    }

    if (password.length < 8) {
      ToastHelper.showToast(
        context: context,
        message: 'Password must be at least 8 characters long',
        type: ToastificationType.error,
      );
      return;
    }

    isLoading.value = true;

    try {
      final response = await AuthRepository.registerCustomer(
        name: name,
        email: email,
        phone: phone,
        password: password,
        referralCode: referralCode.isNotEmpty ? referralCode : null,
        context: context,
      );

      if (response != null &&
          response.isSuccess &&
          response.accessToken.isNotEmpty) {
        // Store user data and token using dot notation
        currentUser.value = response.user;
        appController.updateToken(response.accessToken);

        // Store tokens in new format
        await LocalStorage.storeValue(
          StorageKey.userToken,
          response.accessToken,
        );
        await LocalStorage.storeValue(
          StorageKey.accessToken,
          response.accessToken,
        );
        await LocalStorage.storeValue(
          StorageKey.refreshToken,
          response.refreshToken,
        );
        await LocalStorage.storeValue(StorageKey.userId, response.user.id);
        await LocalStorage.storeValue(
          StorageKey.userEmail,
          response.user.email,
        );
        await LocalStorage.storeValue(StorageKey.userName, response.user.name);

        // Navigate to dashboard
        Get.offAllNamed(Routes.DASHBOARD_SCREEN);

        // Clear form
        clearForm();
        ToastHelper.showToast(
          context: context,
          message: response.message,
          type: ToastificationType.success,
        );
      } else {
        ToastHelper.showToast(
          context: context,
          message: response?.message ?? 'Registration failed',
          type: ToastificationType.error,
        );
      }
    } catch (e) {
      ToastHelper.showToast(
        context: context,
        message: 'Registration failed. Please try again.',
        type: ToastificationType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> handleLogout(BuildContext context) async {
    try {
      // Clear local storage
      await LocalStorage.removeValue(StorageKey.userToken);
      await LocalStorage.removeValue(StorageKey.accessToken);
      await LocalStorage.removeValue(StorageKey.refreshToken);
      await LocalStorage.removeValue(StorageKey.userId);
      await LocalStorage.removeValue(StorageKey.userEmail);
      await LocalStorage.removeValue(StorageKey.userName);

      // Clear app controller
      appController.removeToken();
      currentUser.value = null;

      // Navigate to login
      Get.offAllNamed(Routes.LOGIN_SCREEN);

      ToastHelper.showToast(
        context: context,
        message: 'Logged out successfully',
        type: ToastificationType.success,
      );
    } catch (e) {
      ToastHelper.showToast(
        context: context,
        message: 'Logout failed',
        type: ToastificationType.error,
      );
    }
  }

  // Clear form
  void clearForm() {
    emailController.clear();
    passwordController.clear();
    nameController.clear();
    phoneController.clear();
    confirmPasswordController.clear();
    referralCodeController.clear();
    isPasswordVisible.value = false;
    isConfirmPasswordVisible.value = false;
    rememberMe.value = false;
  }

  // Get loading text
  String get loadingText => isLoading.value ? 'Signing In...' : 'Sign In';

  // Helper method to check if user is authenticated
  bool get isAuthenticated {
    return currentUser.value != null &&
        appController.userToken != null &&
        appController.userToken!.isNotEmpty;
  }

  // Method to clear all app data (for testing)
  Future<void> clearAllData() async {
    try {
      await LocalStorage.removeValue(StorageKey.userToken);
      await LocalStorage.removeValue(StorageKey.userId);
      await LocalStorage.removeValue(StorageKey.userEmail);
      await LocalStorage.removeValue(StorageKey.userName);
      await LocalStorage.removeValue(StorageKey.onboardingCompleted);

      appController.removeToken();
      currentUser.value = null;
      isInitialized.value = false;

      print('All app data cleared');
    } catch (e) {
      print('Error clearing app data: $e');
    }
  }
}
