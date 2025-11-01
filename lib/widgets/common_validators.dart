import 'package:get/get.dart';

class FormValidators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validatemobile(String? value) {
    if (value == null || value.isEmpty) {
      return "Mobile Number is required".tr;
    }
    if (!RegExp(r"^[0-9]{10}$").hasMatch(value)) {
      return "Enter a valid 10-digit mobile number";
    }
    return null;
  }

}
