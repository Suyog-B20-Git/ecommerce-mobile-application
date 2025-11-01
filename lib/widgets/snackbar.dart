// Snack bar for showing error message
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import 'constant_widgets.dart';

class SnackBar {
  SnackBar._();

  // Snack bar for showing error message
  static SnackbarController? error({String title = 'Error', String? message}) {
    if (Get.isSnackbarOpen) {
      Get.back();
    }
    Get.log('\x1B[91m[$title] => $message\x1B[0m', isError: true);
    if (message != null && message.isNotEmpty) {
      return Get.showSnackbar(
        GetSnackBar(
          titleText: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.white,
              ),
              width(3.w),
              Text(
                title,
                textAlign: TextAlign.left,
                style: Theme.of(Get.context!).textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
              ),
            ],
          ),
          messageText: Text(
            message,
            textAlign: TextAlign.left,
            style: Theme.of(Get.context!).textTheme.labelLarge!.copyWith(color: Colors.white),
          ),
          isDismissible: true,
          backgroundColor: Colors.red[400]!,
          snackPosition: SnackPosition.TOP,
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          padding: EdgeInsets.only(left: 4.w, top: 1.h, right: 4.w, bottom: 1.5.h),
          borderRadius: 10,
          duration: const Duration(seconds: 4),
          animationDuration: const Duration(milliseconds: 500),
        ),
      );
    }
    return null;
  }
}
