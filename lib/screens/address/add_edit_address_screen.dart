import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../../controller/theme_controller.dart';
import '../../controller/address_controller.dart';
import '../../utils/theme_config.dart';
import '../../utils/text_styles.dart';
import '../../widgets/textfields/custom_textfield.dart';
import '../../models/user_model.dart';

class AddEditAddressScreen extends StatefulWidget {
  final UserAddress? address;
  final int? addressIndex;

  const AddEditAddressScreen({super.key, this.address, this.addressIndex});

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _countryController = TextEditingController();

  final RxString _selectedType = 'home'.obs;
  final RxBool _isDefault = false.obs;

  late AddressController addressController;
  late ThemeController themeController;

  @override
  void initState() {
    super.initState();
    addressController = Get.find<AddressController>();
    themeController = Get.find<ThemeController>();

    if (widget.address != null) {
      _nameController.text = widget.address!.name;
      _phoneController.text = widget.address!.phone;
      _addressController.text = widget.address!.address;
      _cityController.text = widget.address!.city;
      _stateController.text = widget.address!.state;
      _pincodeController.text = widget.address!.pincode;
      _countryController.text = widget.address!.country;
      _selectedType.value = widget.address!.type;
      _isDefault.value = widget.address!.isDefault;
    }
    // Country field is not shown in UI, will be set by backend or remain empty
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final addressData = {
      'type': _selectedType.value,
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
      'city': _cityController.text.trim(),
      'state': _stateController.text.trim(),
      'pincode': _pincodeController.text.trim(),
      'country': _countryController.text.trim(),
      'isDefault': _isDefault.value,
    };

    bool success;
    if (widget.address != null && widget.addressIndex != null) {
      success = await addressController.updateAddress(
        addressIndex: widget.addressIndex!,
        addressData: addressData,
        context: context,
      );
    } else {
      success = await addressController.addAddress(
        addressData: addressData,
        context: context,
      );
    }

    if (success) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeController.isDark
          ? PremiumColors.charcoal
          : PremiumColors.softBackground,
      appBar: AppBar(
        title: Text(
          widget.address != null ? 'addresses.editAddress'.tr : 'addresses.addAddress'.tr,
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Address Type Selection
              Text(
                'checkout.address'.tr,
                style: TextHelper.size14(context).copyWith(
                  fontWeight: FontWeight.w600,
                  color: themeController.isDark ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(height: 1.5.h),
              Row(
                children: [
                  Expanded(child: _buildTypeOption('home', 'addresses.home'.tr)),
                  SizedBox(width: 2.w),
                  Expanded(child: _buildTypeOption('work', 'addresses.work'.tr)),
                  SizedBox(width: 2.w),
                  Expanded(child: _buildTypeOption('other', 'addresses.other'.tr)),
                ],
              ),
              SizedBox(height: 2.h),

              // Name Field
              CustomTextField(
                controller: _nameController,
                labelText: 'checkout.fullName'.tr,
                prefixIcon: Icon(Icons.person),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'addresses.nameRequired'.tr;
                  }
                  return null;
                },
              ),
              SizedBox(height: 2.h),

              // Phone Field
              CustomTextField(
                controller: _phoneController,
                labelText: 'checkout.phone'.tr,
                prefixIcon: Icon(Icons.phone),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'addresses.phoneRequired'.tr;
                  }
                  if (value.length < 10) {
                    return 'profileEdit.phoneInvalid'.tr;
                  }
                  return null;
                },
              ),
              SizedBox(height: 2.h),

              // Address Field
              CustomTextField(
                controller: _addressController,
                labelText: 'checkout.address'.tr,
                prefixIcon: Icon(Icons.home),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'addresses.addressRequired'.tr;
                  }
                  return null;
                },
              ),
              SizedBox(height: 2.h),

              // City and State Row
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _cityController,
                      labelText: 'checkout.city'.tr,
                      prefixIcon: Icon(Icons.location_city),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'addresses.cityRequired'.tr;
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: CustomTextField(
                      controller: _stateController,
                      labelText: 'checkout.state'.tr,
                      prefixIcon: Icon(Icons.map),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'addresses.stateRequired'.tr;
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),

              // Pincode Field
              CustomTextField(
                controller: _pincodeController,
                labelText: 'checkout.pincode'.tr,
                prefixIcon: Icon(Icons.pin_drop),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'addresses.pincodeRequired'.tr;
                  }
                  if (value.length != 6) {
                    return 'addresses.pincodeRequired'.tr;
                  }
                  return null;
                },
              ),
              SizedBox(height: 2.h),

              // Country Field
              CustomTextField(
                controller: _countryController,
                labelText: 'checkout.country'.tr,
                prefixIcon: Icon(Icons.public),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'addresses.countryRequired'.tr;
                  }
                  return null;
                },
              ),
              SizedBox(height: 2.h),

              // Set as Default Checkbox
              Obx(
                () => Container(
                  decoration: BoxDecoration(
                    color: themeController.isDark
                        ? PremiumColors.grey800
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                  child: Row(
                    children: [
                      // Checkbox only (clickable)
                      GestureDetector(
                        onTap: () {
                          _isDefault.value = !_isDefault.value;
                        },
                        child: Container(
                          width: 15.w,
                          height: 15.w,
                          decoration: BoxDecoration(shape: BoxShape.circle),
                          child: Checkbox(
                            value: _isDefault.value,
                            onChanged: (value) {
                              _isDefault.value = value ?? false;
                            },
                            activeColor: PremiumColors.gold,
                            checkColor: Colors.white,
                            fillColor: WidgetStateProperty.resolveWith<Color>((
                              Set<WidgetState> states,
                            ) {
                              if (states.contains(WidgetState.selected)) {
                                return PremiumColors.gold;
                              }
                              return Colors.transparent;
                            }),
                            side: BorderSide(
                              color: _isDefault.value
                                  ? PremiumColors.gold
                                  : (themeController.isDark
                                        ? Colors.grey[600]!
                                        : Colors.grey[400]!),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      // Text content (not clickable)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'addresses.setDefault'.tr,
                              style: TextHelper.size14(context).copyWith(
                                fontWeight: FontWeight.w600,
                                color: themeController.isDark
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            SizedBox(height: 0.3.h),
                            Text(
                              'addresses.setDefaultDescription'.tr,
                              style: TextHelper.size12(context).copyWith(
                                color: themeController.isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 5.h),

              // Save Button
              Obx(
                () => ElevatedButton(
                  onPressed: addressController.isLoading.value
                      ? null
                      : _saveAddress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PremiumColors.gold,
                    padding: EdgeInsets.symmetric(vertical: 2.5.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: addressController.isLoading.value
                      ? SizedBox(
                          height: 4.w,
                          width: 4.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          widget.address != null
                              ? 'addresses.updateAddress'.tr
                              : 'addresses.saveAddress'.tr,
                          style: TextHelper.size16(context).copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeOption(String value, String label) {
    return Obx(
      () => GestureDetector(
        onTap: () => _selectedType.value = value,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 2.h),
          decoration: BoxDecoration(
            color: _selectedType.value == value
                ? PremiumColors.gold.withAlpha((0.2 * 255).toInt())
                : (themeController.isDark
                      ? PremiumColors.grey800
                      : Colors.grey[100]),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _selectedType.value == value
                  ? PremiumColors.gold
                  : Colors.grey.withAlpha((0.3 * 255).toInt()),
              width: _selectedType.value == value ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextHelper.size14(context).copyWith(
                fontWeight: _selectedType.value == value
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: _selectedType.value == value
                    ? PremiumColors.gold
                    : (themeController.isDark ? Colors.white : Colors.black),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
