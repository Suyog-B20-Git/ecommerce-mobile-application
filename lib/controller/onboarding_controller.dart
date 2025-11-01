import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../routes/routes.dart';
import '../utils/storage_config.dart';
import '../utils/app_enums.dart';

class OnboardingController extends GetxController {
  // Page Controller
  late PageController pageController;
  AnimationController? animationController;

  // Observable Variables
  final currentPage = 0.obs;

  // Onboarding Items
  final List<OnboardingPage> onboardingPages = [
    OnboardingPage(
      icon: Icons.shopping_bag_outlined,
      title: "Welcome to Premium Shopping",
      description:
          "Discover luxury products from top brands worldwide. Experience shopping like never before with our curated collection.",
      gradient: [Color(0xFFD97706), Color(0xFFF59E0B)],
      illustration: "🛍️",
    ),
    OnboardingPage(
      icon: Icons.search,
      title: "Smart Discovery",
      description:
          "Find your perfect match with AI-powered recommendations and intelligent search that learns your preferences.",
      gradient: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
      illustration: "🔍",
    ),
    OnboardingPage(
      icon: Icons.security,
      title: "Bank-Level Security",
      description:
          "Shop with complete confidence. Your data and payments are protected with military-grade encryption.",
      gradient: [Color(0xFF10B981), Color(0xFF059669)],
      illustration: "🔒",
    ),
    OnboardingPage(
      icon: Icons.local_shipping,
      title: "Lightning Fast Delivery",
      description:
          "Get your orders in record time with our premium shipping network and real-time tracking.",
      gradient: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
      illustration: "⚡",
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    initializeControllers();
  }

  @override
  void onClose() {
    pageController.dispose();
    animationController?.dispose();
    super.onClose();
  }

  void initializeControllers() {
    pageController = PageController();
  }

  void initializeAnimations(TickerProvider vsync) {
    animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: vsync,
    );
    // Start the animation immediately for the first page
    animationController?.forward();
  }

  // Handle page change
  void onPageChanged(int index) {
    currentPage.value = index;
    animationController?.reset();
    animationController?.forward();
  }

  // Navigate to next page
  void nextPage() {
    if (currentPage.value < onboardingPages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      completeOnboarding();
    }
  }

  // Navigate to previous page
  void previousPage() {
    if (currentPage.value > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Skip onboarding
  void skipOnboarding() {
    completeOnboarding();
  }

  // Complete onboarding and navigate to login
  void completeOnboarding() async {
    // Store onboarding completion status using LocalStorage
    await LocalStorage.storeValue(StorageKey.onboardingCompleted, true);
    Get.offNamed(Routes.LOGIN_SCREEN);
  }

  // Check if it's the last page
  bool get isLastPage => currentPage.value == onboardingPages.length - 1;

  // Check if it's the first page
  bool get isFirstPage => currentPage.value == 0;

  // Get button text
  String get buttonText => isLastPage ? 'Get Started' : 'Next';

  // Get total pages
  int get totalPages => onboardingPages.length;

  // Get current Onboarding item
  OnboardingPage get currentItem => onboardingPages[currentPage.value];
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradient;
  final String illustration;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.illustration,
  });
}
