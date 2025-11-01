import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../utils/theme_config.dart';

class ThemeController extends GetxController {
  static const String _themeKey = 'theme_mode';

  final GetStorage _storage = GetStorage();

  // Observable variables
  final isDarkMode = false.obs;
  final themeMode = ThemeMode.system.obs;

  @override
  void onInit() {
    super.onInit();
    _loadThemeMode();
  }

  // Load theme mode from storage
  void _loadThemeMode() {
    final savedTheme = _storage.read(_themeKey);
    if (savedTheme != null) {
      switch (savedTheme) {
        case 'light':
          themeMode.value = ThemeMode.light;
          isDarkMode.value = false;
          break;
        case 'dark':
          themeMode.value = ThemeMode.dark;
          isDarkMode.value = true;
          break;
        case 'system':
        default:
          themeMode.value = ThemeMode.system;
          isDarkMode.value = Get.isDarkMode;
          break;
      }
    } else {
      // Default to system theme
      themeMode.value = ThemeMode.system;
      isDarkMode.value = Get.isDarkMode;
    }
  }

  // Toggle between light and dark mode
  void toggleTheme() {
    if (themeMode.value == ThemeMode.light) {
      setThemeMode(ThemeMode.dark);
    } else {
      setThemeMode(ThemeMode.light);
    }
  }

  // Set specific theme mode
  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;

    switch (mode) {
      case ThemeMode.light:
        isDarkMode.value = false;
        _storage.write(_themeKey, 'light');
        break;
      case ThemeMode.dark:
        isDarkMode.value = true;
        _storage.write(_themeKey, 'dark');
        break;
      case ThemeMode.system:
        isDarkMode.value = Get.isDarkMode;
        _storage.write(_themeKey, 'system');
        break;
    }

    // Update GetX theme
    Get.changeThemeMode(mode);
  }

  // Get current theme data
  ThemeData get currentTheme {
    switch (themeMode.value) {
      case ThemeMode.light:
        return ThemeConfig.lightTheme();
      case ThemeMode.dark:
        return ThemeConfig.darkTheme();
      case ThemeMode.system:
        return Get.isDarkMode
            ? ThemeConfig.darkTheme()
            : ThemeConfig.lightTheme();
    }
  }

  // Check if current theme is dark
  bool get isDark => isDarkMode.value;

  // Check if current theme is light
  bool get isLight => !isDarkMode.value;

  // Get theme mode string
  String get themeModeString {
    switch (themeMode.value) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  // Get theme icon
  IconData get themeIcon {
    switch (themeMode.value) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  // Reset to system theme
  void resetToSystem() {
    setThemeMode(ThemeMode.system);
  }
}
