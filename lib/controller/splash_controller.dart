import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  // Animation Controllers
  AnimationController? animationController;
  Animation<double>? fadeAnimation;
  Animation<double>? scaleAnimation;

  @override
  void onInit() {
    super.onInit();
    // Navigation is now handled by the splash screen itself
  }

  @override
  void onClose() {
    animationController?.stop();
    animationController?.dispose();
    super.onClose();
  }

  void initializeAnimations(TickerProvider vsync) {
    animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: vsync,
    );

    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController!,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController!,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    animationController!.forward();
  }

  // Navigation is now handled by the splash screen itself
  // This method is kept for backward compatibility but not used
  void startNavigationTimer() async {
    // Navigation is now handled by the splash screen itself
  }

  // Get app name
  String get appName => 'E-Commerce';

  // Get app description
  String get appDescription => 'E-Commerce System';

  // Get logo size
  double get logoSize => 25.0; // 25.w equivalent

  // Get icon size
  double get iconSize => 12.0; // 12.w equivalent

  // Get loading indicator size
  double get loadingSize => 6.0; // 6.w equivalent
}
