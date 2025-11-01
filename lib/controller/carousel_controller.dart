import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ModernCarouselController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late PageController pageController;
  late AnimationController animationController;
  late Animation<double> fadeAnimation;

  final RxInt currentIndex = 0.obs;
  Timer? autoScrollTimer;

  final RxList<dynamic> items = <dynamic>[].obs;
  final RxString cardType = 'featured'.obs;
  final RxBool autoScroll = true.obs;
  final Rx<Duration> autoScrollDuration = const Duration(seconds: 3).obs;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(viewportFraction: 0.85);
    animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
    );

    animationController.forward();
  }

  @override
  void onClose() {
    pageController.dispose();
    animationController.dispose();
    autoScrollTimer?.cancel();
    super.onClose();
  }

  void initializeCarousel({
    required List<dynamic> carouselItems,
    String type = 'featured',
    bool enableAutoScroll = true,
    Duration scrollDuration = const Duration(seconds: 3),
  }) {
    items.value = carouselItems;
    cardType.value = type;
    autoScroll.value = enableAutoScroll;
    autoScrollDuration.value = scrollDuration;

    if (enableAutoScroll && carouselItems.length > 1) {
      startAutoScroll();
    }
  }

  void startAutoScroll() {
    autoScrollTimer?.cancel();
    autoScrollTimer = Timer.periodic(autoScrollDuration.value, (timer) {
      if (pageController.hasClients && items.length > 1) {
        currentIndex.value = (currentIndex.value + 1) % items.length;
        pageController.animateToPage(
          currentIndex.value,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void stopAutoScroll() {
    autoScrollTimer?.cancel();
  }

  void onPageChanged(int index) {
    currentIndex.value = index;
  }

  void goToPage(int index) {
    if (pageController.hasClients) {
      pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  double getCarouselHeight() {
    switch (cardType.value) {
      case 'trending':
        return 35.0; // Will be converted to .h in widget
      case 'bestseller':
        return 32.0;
      case 'new':
        return 30.0;
      default:
        return 28.0;
    }
  }
}
