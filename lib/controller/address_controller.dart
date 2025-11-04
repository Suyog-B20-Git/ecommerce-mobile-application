import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repository/address_repository.dart';
import '../models/user_model.dart';
import '../controller/auth_controller.dart';
import '../widgets/snackbar.dart' as CustomSnackBar;
import '../widgets/toastification.dart';

class AddressController extends GetxController {
  final AuthController authController = Get.find<AuthController>();

  // Observable state
  final RxList<UserAddress> addresses = <UserAddress>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
  }

  // Load addresses
  Future<void> loadAddresses({BuildContext? context}) async {
    try {
      isLoading.value = true;
      final addressesList = await AddressRepository.getAddresses(context: context);
      addresses.value = addressesList;
    } catch (e) {
      print('Error loading addresses: $e');
      if (context != null) {
        CustomSnackBar.SnackBar.error(
          title: 'Error',
          message: 'Failed to load addresses. Please try again.',
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Add new address
  Future<bool> addAddress({
    required Map<String, dynamic> addressData,
    BuildContext? context,
  }) async {
    try {
      isLoading.value = true;
      final response = await AddressRepository.addAddress(
        addressData: addressData,
        context: context,
      );

      if (response != null && response.isSuccess) {
        // Update local user data
        final userData = response.data?['user'];
        if (userData != null) {
          final updatedUser = UserModel.fromJson(userData);
          authController.currentUser.value = updatedUser;
        }

        // Reload addresses
        await loadAddresses(context: context);

        if (context != null) {
          ToastHelper.showSuccessToast('Address added successfully!');
        }
        return true;
      } else {
        if (context != null) {
          CustomSnackBar.SnackBar.error(
            title: 'Error',
            message: response?.message ?? 'Failed to add address. Please try again.',
          );
        }
        return false;
      }
    } catch (e) {
      print('Error adding address: $e');
      if (context != null) {
        CustomSnackBar.SnackBar.error(
          title: 'Error',
          message: 'Failed to add address. Please try again.',
        );
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Update address
  Future<bool> updateAddress({
    required int addressIndex,
    required Map<String, dynamic> addressData,
    BuildContext? context,
  }) async {
    try {
      isLoading.value = true;
      final response = await AddressRepository.updateAddress(
        addressIndex: addressIndex,
        addressData: addressData,
        context: context,
      );

      if (response != null && response.isSuccess) {
        // Update local user data
        final userData = response.data?['user'];
        if (userData != null) {
          final updatedUser = UserModel.fromJson(userData);
          authController.currentUser.value = updatedUser;
        }

        // Reload addresses
        await loadAddresses(context: context);

        if (context != null) {
          ToastHelper.showSuccessToast('Address updated successfully!');
        }
        return true;
      } else {
        if (context != null) {
          CustomSnackBar.SnackBar.error(
            title: 'Error',
            message: response?.message ?? 'Failed to update address. Please try again.',
          );
        }
        return false;
      }
    } catch (e) {
      print('Error updating address: $e');
      if (context != null) {
        CustomSnackBar.SnackBar.error(
          title: 'Error',
          message: 'Failed to update address. Please try again.',
        );
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Delete address
  Future<bool> deleteAddress({
    required int addressIndex,
    BuildContext? context,
  }) async {
    try {
      isLoading.value = true;
      final response = await AddressRepository.deleteAddress(
        addressIndex: addressIndex,
        context: context,
      );

      if (response != null && response.isSuccess) {
        // Update local user data
        final userData = response.data?['user'];
        if (userData != null) {
          final updatedUser = UserModel.fromJson(userData);
          authController.currentUser.value = updatedUser;
        }

        // Reload addresses
        await loadAddresses(context: context);

        if (context != null) {
          ToastHelper.showSuccessToast('Address deleted successfully!');
        }
        return true;
      } else {
        if (context != null) {
          CustomSnackBar.SnackBar.error(
            title: 'Error',
            message: response?.message ?? 'Failed to delete address. Please try again.',
          );
        }
        return false;
      }
    } catch (e) {
      print('Error deleting address: $e');
      if (context != null) {
        CustomSnackBar.SnackBar.error(
          title: 'Error',
          message: 'Failed to delete address. Please try again.',
        );
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Set default address
  Future<bool> setDefaultAddress({
    required int addressIndex,
    BuildContext? context,
  }) async {
    try {
      isLoading.value = true;
      final response = await AddressRepository.setDefaultAddress(
        addressIndex: addressIndex,
        context: context,
      );

      if (response != null && response.isSuccess) {
        // Update local user data
        final userData = response.data?['user'];
        if (userData != null) {
          final updatedUser = UserModel.fromJson(userData);
          authController.currentUser.value = updatedUser;
        }

        // Reload addresses
        await loadAddresses(context: context);

        if (context != null) {
          ToastHelper.showSuccessToast('Default address updated successfully!');
        }
        return true;
      } else {
        if (context != null) {
          CustomSnackBar.SnackBar.error(
            title: 'Error',
            message: response?.message ?? 'Failed to set default address. Please try again.',
          );
        }
        return false;
      }
    } catch (e) {
      print('Error setting default address: $e');
      if (context != null) {
        CustomSnackBar.SnackBar.error(
          title: 'Error',
          message: 'Failed to set default address. Please try again.',
        );
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}

