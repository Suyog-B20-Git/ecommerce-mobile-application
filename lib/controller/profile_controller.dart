import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../repository/auth_repository.dart';
import '../models/user_model.dart';
import '../controller/auth_controller.dart';
import '../widgets/snackbar.dart' as CustomSnackBar;
import '../widgets/toastification.dart';
import '../controller/theme_controller.dart';
import '../utils/theme_config.dart';

class ProfileController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final ThemeController themeController = Get.find<ThemeController>();

  // Form Controllers
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final dateOfBirthController = TextEditingController();

  // Reactive State
  final isLoading = false.obs;
  final selectedGender = 'other'.obs;
  final userProfile = Rxn<UserModel>();

  // Reactive profile initial for display
  final RxString profileInitial = 'U'.obs;

  @override
  void onInit() {
    super.onInit();
    // Listen to name controller changes
    nameController.addListener(() {
      updateProfileInitial();
    });
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    dateOfBirthController.dispose();
    super.onClose();
  }

  // Load user profile from API
  Future<void> loadUserProfile({BuildContext? context}) async {
    try {
      isLoading.value = true;
      update(); // Update GetBuilder
      final user = await AuthRepository.getProfile(context: context);
      if (user != null) {
        userProfile.value = user;
        nameController.text = user.name;
        phoneController.text = user.phone;
        selectedGender.value = user.gender;
        if (user.dateOfBirth != null) {
          dateOfBirthController.text = DateFormat(
            'yyyy-MM-dd',
          ).format(user.dateOfBirth!);
        } else {
          dateOfBirthController.clear();
        }
        updateProfileInitial();
      }
    } catch (e) {
      print('Error loading profile: $e');
      if (context != null) {
        CustomSnackBar.SnackBar.error(
          title: 'Error',
          message: 'Failed to load profile. Please try again.',
        );
      }
    } finally {
      isLoading.value = false;
      update(); // Update GetBuilder
    }
  }

  // Select date of birth - using same approach as CustomTextField
  Future<void> selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          userProfile.value?.dateOfBirth ??
          DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: PremiumColors.gold,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
              surfaceContainerHighest: Colors.grey[100],
              secondaryContainer: Colors.grey[50],
            ),
            scaffoldBackgroundColor: Colors.white,
            dialogBackgroundColor: Colors.white,
            cardColor: Colors.white,
            textTheme: Theme.of(context).textTheme.copyWith(
              bodyLarge: TextStyle(color: Colors.black),
              bodyMedium: TextStyle(color: Colors.black),
              labelLarge: TextStyle(color: Colors.black),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      dateOfBirthController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  // Update selected gender
  void setGender(String gender) {
    selectedGender.value = gender;
  }

  // Save profile updates
  Future<bool> saveProfile({
    BuildContext? context,
    required GlobalKey<FormState> formKey,
  }) async {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    isLoading.value = true;
    update(); // Update GetBuilder

    try {
      final profileData = {
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        if (dateOfBirthController.text.isNotEmpty)
          'dateOfBirth': dateOfBirthController.text,
        'gender': selectedGender.value,
      };

      final response = await AuthRepository.updateProfile(
        profileData: profileData,
        context: context,
      );

      if (response != null && response.isSuccess) {
        // Update local user data
        final userData = response.data?['user'];
        if (userData != null) {
          final updatedUser = UserModel.fromJson(userData);
          authController.currentUser.value = updatedUser;
          userProfile.value = updatedUser;
        }

        if (context != null) {
          ToastHelper.showSuccessToast('Profile updated successfully!');
        }
        return true;
      } else {
        if (context != null) {
          CustomSnackBar.SnackBar.error(
            title: 'Error',
            message:
                response?.message ??
                'Failed to update profile. Please try again.',
          );
        }
        return false;
      }
    } catch (e) {
      print('Error updating profile: $e');
      if (context != null) {
        CustomSnackBar.SnackBar.error(
          title: 'Error',
          message: 'Failed to update profile. Please try again.',
        );
      }
      return false;
    } finally {
      isLoading.value = false;
      update(); // Update GetBuilder
    }
  }

  // Update profile initial when name changes
  void updateProfileInitial() {
    if (nameController.text.isNotEmpty) {
      profileInitial.value = nameController.text.substring(0, 1).toUpperCase();
    } else if (userProfile.value?.name.isNotEmpty == true) {
      profileInitial.value = userProfile.value!.name
          .substring(0, 1)
          .toUpperCase();
    } else {
      profileInitial.value = 'U';
    }
  }

  // Get profile initial for display (non-reactive fallback)
  String getProfileInitial() {
    if (nameController.text.isNotEmpty) {
      return nameController.text.substring(0, 1).toUpperCase();
    }
    if (userProfile.value?.name.isNotEmpty == true) {
      return userProfile.value!.name.substring(0, 1).toUpperCase();
    }
    return 'U';
  }
}
