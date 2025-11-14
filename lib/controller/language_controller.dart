import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LanguageController extends GetxController {
  final _storage = GetStorage();
  final _languageKey = 'language';
  
  final RxString _currentLanguage = 'en'.obs;
  
  String get currentLanguage => _currentLanguage.value;
  bool get isArabic => _currentLanguage.value == 'ar';
  bool get isRTL => _currentLanguage.value == 'ar';
  
  @override
  void onInit() {
    super.onInit();
    _loadSavedLanguage();
  }
  
  void _loadSavedLanguage() {
    final savedLanguage = _storage.read(_languageKey) ?? 'en';
    _currentLanguage.value = savedLanguage;
    _updateLocale(savedLanguage);
  }
  
  void changeLanguage(String languageCode) {
    if (_currentLanguage.value != languageCode) {
      _currentLanguage.value = languageCode;
      _storage.write(_languageKey, languageCode);
      _updateLocale(languageCode);
    }
  }
  
  void toggleLanguage() {
    final newLanguage = _currentLanguage.value == 'en' ? 'ar' : 'en';
    changeLanguage(newLanguage);
  }
  
  void _updateLocale(String languageCode) {
    final locale = languageCode == 'ar' 
        ? const Locale('ar', 'SA') 
        : const Locale('en', 'US');
    Get.updateLocale(locale);
  }
}

