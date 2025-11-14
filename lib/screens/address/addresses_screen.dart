import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../../controller/theme_controller.dart';
import '../../controller/address_controller.dart';
import '../../controller/auth_controller.dart';
import '../../utils/theme_config.dart';
import '../../utils/text_styles.dart';
import '../../models/user_model.dart';
import 'add_edit_address_screen.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  late AddressController addressController;
  late ThemeController themeController;
  late AuthController authController;

  @override
  void initState() {
    super.initState();
    addressController = Get.put(AddressController());
    themeController = Get.find<ThemeController>();
    authController = Get.find<AuthController>();
    addressController.loadAddresses(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeController.isDark
          ? PremiumColors.charcoal
          : PremiumColors.softBackground,
      appBar: AppBar(
        title: Text(
          'addresses.title'.tr,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: themeController.isDark
                ? Colors.white
                : PremiumColors.charcoal,
          ),
        ),
        backgroundColor: themeController.isDark
            ? PremiumColors.charcoal
            : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: themeController.isDark
                ? Colors.white
                : PremiumColors.charcoal,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (addressController.isLoading.value &&
            addressController.addresses.isEmpty) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(PremiumColors.gold),
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: addressController.addresses.isEmpty
                  ? _buildEmptyState()
                  : _buildAddressesList(),
            ),
            _buildAddAddressButton(),
          ],
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off_outlined,
            size: 20.w,
            color: Colors.grey[400],
          ),
          SizedBox(height: 3.h),
          Text(
            'addresses.empty'.tr,
            style: TextHelper.size18(context).copyWith(
              fontWeight: FontWeight.bold,
              color: themeController.isDark ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'addresses.emptyMessage'.tr,
            style: TextHelper.size14(context).copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressesList() {
    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: addressController.addresses.length,
      itemBuilder: (context, index) {
        final address = addressController.addresses[index];
        return _buildAddressCard(address, index);
      },
    );
  }

  Widget _buildAddressCard(UserAddress address, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 3.h),
      decoration: BoxDecoration(
        color: address.isDefault
            ? PremiumColors.gold.withAlpha((0.1 * 255).toInt())
            : (themeController.isDark ? PremiumColors.grey800 : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: address.isDefault
              ? PremiumColors.gold
              : Colors.grey.withAlpha((0.3 * 255).toInt()),
          width: address.isDefault ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).toInt()),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: PremiumColors.gold.withAlpha((0.2 * 255).toInt()),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    address.type.toUpperCase(),
                    style: TextHelper.size12(context).copyWith(
                      color: PremiumColors.gold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                if (address.isDefault)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 1.h,
                    ),
                    decoration: BoxDecoration(
                      color: PremiumColors.gold,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'addresses.default'.tr,
                      style: TextHelper.size12(context).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const Spacer(),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: themeController.isDark ? Colors.white : Colors.black,
                    size: 6.w,
                  ),
                  iconSize: 6.w,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  constraints: BoxConstraints(minWidth: 40.w, maxWidth: 50.w),
                  onSelected: (value) {
                    if (value == 'edit') {
                      Get.to(
                        () => AddEditAddressScreen(
                          address: address,
                          addressIndex: index,
                        ),
                      )?.then((_) {
                        addressController.loadAddresses(context: context);
                      });
                    } else if (value == 'delete') {
                      _showDeleteDialog(address, index);
                    } else if (value == 'set_default') {
                      addressController.setDefaultAddress(
                        addressIndex: index,
                        context: context,
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      height: 2.h,
                      value: 'set_default',
                      enabled: !address.isDefault,
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 0.5.h,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.star, size: 5.w),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              'addresses.setDefault'.tr,
                              style: TextHelper.size15(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      height: 2.h,
                      value: 'edit',
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 0.5.h,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 5.w),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              'common.edit'.tr,
                              style: TextHelper.size15(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      height: 2.h,
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 0.5.h,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red, size: 5.w),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              'addresses.delete'.tr,
                              style: TextHelper.size15(
                                context,
                              ).copyWith(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              address.name,
              style: TextHelper.size16(context).copyWith(
                fontWeight: FontWeight.bold,
                color: themeController.isDark ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              address.phone,
              style: TextHelper.size14(
                context,
              ).copyWith(color: Colors.grey[600]),
            ),
            SizedBox(height: 1.h),
            Text(
              address.address,
              style: TextHelper.size14(context).copyWith(
                color: themeController.isDark ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              '${address.city}, ${address.state} - ${address.pincode}',
              style: TextHelper.size14(
                context,
              ).copyWith(color: Colors.grey[600]),
            ),
            if (address.country.isNotEmpty) ...[
              SizedBox(height: 0.5.h),
              Text(
                address.country,
                style: TextHelper.size14(
                  context,
                ).copyWith(color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAddAddressButton() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: themeController.isDark ? PremiumColors.grey800 : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).toInt()),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Get.to(() => const AddEditAddressScreen())?.then((_) {
                addressController.loadAddresses(context: context);
              });
            },
            icon: Icon(Icons.add, color: Colors.white),
            label: Text(
              'addresses.addAddress'.tr,
              style: TextHelper.size16(
                context,
              ).copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: PremiumColors.gold,
              padding: EdgeInsets.symmetric(vertical: 2.5.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(UserAddress address, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'addresses.delete'.tr,
            style: TextHelper.size18(
              context,
            ).copyWith(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'addresses.deleteConfirm'.tr,
            style: TextHelper.size14(context),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'common.cancel'.tr,
                style: TextHelper.size14(
                  context,
                ).copyWith(color: Colors.grey[600]),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await addressController.deleteAddress(
                  addressIndex: index,
                  context: context,
                );
              },
              child: Text(
                'addresses.delete'.tr,
                style: TextHelper.size14(
                  context,
                ).copyWith(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}
