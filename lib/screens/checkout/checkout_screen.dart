import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../controller/theme_controller.dart';
import '../../controller/cart_controller.dart';
import '../../controller/order_controller.dart';
import '../../utils/theme_config.dart';
import '../../utils/text_styles.dart';
import '../../utils/color_helper.dart';
import '../../models/order_model.dart';
import '../../models/user_model.dart';
import '../../repository/auth_repository.dart';
import '../../widgets/textfields/custom_textfield.dart';
import '../../widgets/snackbar.dart' as CustomSnackBar;
import '../../routes/routes.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();

  // GetX reactive variables
  final RxString _selectedPaymentMethod = 'cash_on_delivery'.obs;
  final RxBool _isProcessing = false.obs;
  final RxInt _currentStep = 0.obs;
  final Rx<UserModel?> _userProfile = Rx<UserModel?>(null);
  final RxBool _isLoadingProfile = false.obs;

  // Debouncing mechanism to prevent rapid clicks
  final Rx<DateTime?> _lastClickTime = Rx<DateTime?>(null);

  @override
  void initState() {
    super.initState();
    // Load user profile from backend
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    _isLoadingProfile.value = true;
    try {
      final userProfile = await AuthRepository.getProfile(context: context);
      if (userProfile != null) {
        print('User profile loaded successfully: ${userProfile.name}');
        print('User addresses count: ${userProfile.addresses.length}');
        _userProfile.value = userProfile;
        _populateAddressFields(userProfile);
      } else {
        print('User profile is null');
      }
    } catch (e) {
      print('Error loading user profile: $e');
      // Show error message to user
      CustomSnackBar.SnackBar.error(
        title: 'Profile Error',
        message:
            'Unable to load your profile. Please fill in your address manually.',
      );
      // Continue without pre-filling data
    } finally {
      _isLoadingProfile.value = false;
    }
  }

  void _populateAddressFields(UserModel userProfile) {
    print('Populating address fields for user: ${userProfile.name}');
    print('Addresses available: ${userProfile.addresses.length}');

    // Use default address if available, otherwise use profile data
    if (userProfile.addresses.isNotEmpty) {
      final defaultAddress = userProfile.addresses.firstWhere(
        (address) => address.isDefault,
        orElse: () => userProfile.addresses.first,
      );

      print('Using address: ${defaultAddress.name}');
      _nameController.text = defaultAddress.name;
      _phoneController.text = defaultAddress.phone;
      _addressController.text = defaultAddress.address;
      _cityController.text = defaultAddress.city;
      _stateController.text = defaultAddress.state;
      _pincodeController.text = defaultAddress.pincode;
    } else {
      // Fallback to basic profile data
      print('No saved addresses, using basic profile info');
      _nameController.text = userProfile.name;
      _phoneController.text = userProfile.phone;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final cartController = Get.find<CartController>();

    return Scaffold(
      backgroundColor: themeController.isDark
          ? PremiumColors.grey900
          : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Checkout',
          style: TextHelper.size18(context).copyWith(
            fontWeight: FontWeight.bold,
            color: themeController.isDark ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: themeController.isDark
            ? PremiumColors.grey800
            : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: themeController.isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (cartController.cartItems.isEmpty) {
          return _buildEmptyCartState(context, themeController);
        }

        return Column(
          children: [
            // Progress Indicator
            _buildProgressIndicator(context, themeController),

            // Step Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (_currentStep.value == 0) ...[
                        _buildStep1Address(context, themeController),
                      ] else if (_currentStep.value == 1) ...[
                        _buildStep2Products(
                          context,
                          themeController,
                          cartController,
                        ),
                      ] else if (_currentStep.value == 2) ...[
                        _buildStep3Payment(
                          context,
                          themeController,
                          cartController,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Navigation
            _buildBottomNavigation(context, themeController, cartController),
          ],
        );
      }),
    );
  }

  Widget _buildEmptyCartState(
    BuildContext context,
    ThemeController themeController,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 20.w,
            color: Colors.grey[400],
          ),
          SizedBox(height: 4.h),
          Text(
            'Your cart is empty',
            style: TextHelper.size18(context).copyWith(
              fontWeight: FontWeight.w600,
              color: themeController.isDark ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Add some items to your cart before checkout',
            textAlign: TextAlign.center,
            style: TextHelper.size14(context).copyWith(color: Colors.grey[600]),
          ),
          SizedBox(height: 4.h),
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: PremiumColors.gold,
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              'Continue Shopping',
              style: TextHelper.size14(
                context,
              ).copyWith(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(
    BuildContext context,
    ThemeController themeController,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: themeController.isDark ? PremiumColors.grey800 : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).toInt()),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Step 1: Address
          Expanded(
            child: _buildStepIndicator(
              context,
              themeController,
              stepNumber: 1,
              title: 'Address',
              isActive: _currentStep.value >= 0,
              isCompleted: _currentStep.value > 0,
            ),
          ),

          // Connector Line
          Container(
            height: 2,
            width: 8.w,
            margin: EdgeInsets.symmetric(horizontal: 2.w),
            decoration: BoxDecoration(
              color: _currentStep.value > 0
                  ? PremiumColors.gold
                  : Colors.grey[300],
              borderRadius: BorderRadius.circular(1),
            ),
          ),

          // Step 2: Products
          Expanded(
            child: _buildStepIndicator(
              context,
              themeController,
              stepNumber: 2,
              title: 'Products',
              isActive: _currentStep.value >= 1,
              isCompleted: _currentStep.value > 1,
            ),
          ),

          // Connector Line
          Container(
            height: 2,
            width: 8.w,
            margin: EdgeInsets.symmetric(horizontal: 2.w),
            decoration: BoxDecoration(
              color: _currentStep.value > 1
                  ? PremiumColors.gold
                  : Colors.grey[300],
              borderRadius: BorderRadius.circular(1),
            ),
          ),

          // Step 3: Payment
          Expanded(
            child: _buildStepIndicator(
              context,
              themeController,
              stepNumber: 3,
              title: 'Payment',
              isActive: _currentStep.value >= 2,
              isCompleted: _currentStep.value > 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(
    BuildContext context,
    ThemeController themeController, {
    required int stepNumber,
    required String title,
    required bool isActive,
    required bool isCompleted,
  }) {
    return Column(
      children: [
        Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(
            color: isCompleted
                ? PremiumColors.gold
                : isActive
                ? PremiumColors.gold
                : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? Icon(Icons.check, color: Colors.white, size: 5.w)
                : Text(
                    '$stepNumber',
                    style: TextHelper.size15(context).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          title,
          style: TextHelper.size12(context).copyWith(
            color: isActive ? PremiumColors.gold : Colors.grey[600],
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStep1Address(
    BuildContext context,
    ThemeController themeController,
  ) {
    return Obx(() {
      if (_isLoadingProfile.value) {
        return Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: themeController.isDark
                ? PremiumColors.grey800
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.05 * 255).toInt()),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.location_on, color: PremiumColors.gold, size: 5.w),
                  SizedBox(width: 2.w),
                  Text(
                    'Delivery Address',
                    style: TextHelper.size16(context).copyWith(
                      fontWeight: FontWeight.bold,
                      color: themeController.isDark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(PremiumColors.gold),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Loading your address...',
                style: TextHelper.size14(
                  context,
                ).copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }

      return Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: themeController.isDark ? PremiumColors.grey800 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.05 * 255).toInt()),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: PremiumColors.gold, size: 5.w),
                SizedBox(width: 2.w),
                Text(
                  'Delivery Address',
                  style: TextHelper.size16(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: themeController.isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),

            // Name Field
            CustomTextField(
              controller: _nameController,
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),
            SizedBox(height: 2.h),

            // Phone Field
            CustomTextField(
              controller: _phoneController,
              labelText: 'Phone Number',
              prefixIcon: Icon(Icons.phone),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                if (value.length < 10) {
                  return 'Please enter a valid phone number';
                }
                return null;
              },
            ),
            SizedBox(height: 2.h),

            // Address Field
            CustomTextField(
              controller: _addressController,
              labelText: 'Address',
              prefixIcon: Icon(Icons.home),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your address';
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
                    labelText: 'City',
                    prefixIcon: Icon(Icons.location_city),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your city';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: CustomTextField(
                    controller: _stateController,
                    labelText: 'State',
                    prefixIcon: Icon(Icons.map),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your state';
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
              labelText: 'Pincode',
              prefixIcon: Icon(Icons.pin_drop),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your pincode';
                }
                if (value.length != 6) {
                  return 'Please enter a valid 6-digit pincode';
                }
                return null;
              },
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStep2Products(
    BuildContext context,
    ThemeController themeController,
    CartController cartController,
  ) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: themeController.isDark ? PremiumColors.grey800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).toInt()),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shopping_cart, color: PremiumColors.gold, size: 5.w),
              SizedBox(width: 2.w),
              Text(
                'Review Products',
                style: TextHelper.size16(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: themeController.isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          Text(
            'Review your items and adjust quantities if needed',
            style: TextHelper.size14(context).copyWith(color: Colors.grey[600]),
          ),
          SizedBox(height: 2.h),

          ...cartController.cartItems.map(
            (item) => _buildEditableCartItem(
              context,
              themeController,
              cartController,
              item,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableCartItem(
    BuildContext context,
    ThemeController themeController,
    CartController cartController,
    dynamic cartItem,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: themeController.isDark
            ? PremiumColors.grey700
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 15.w,
            height: 15.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child: cartItem.productImage.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      cartItem.productImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.image_not_supported,
                          color: Colors.grey[400],
                        );
                      },
                    ),
                  )
                : Icon(Icons.image_not_supported, color: Colors.grey[400]),
          ),
          SizedBox(width: 3.w),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartItem.productName,
                  style: TextHelper.size14(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: themeController.isDark ? Colors.white : Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 0.5.h),
                if (cartItem.variantAttributes.isNotEmpty) ...[
                  Text(
                    '${ColorHelper.getColorName(cartItem.variantAttributes['color']?.toString() ?? '')} - ${cartItem.variantAttributes['size'] ?? ''}',
                    style: TextHelper.size14(
                      context,
                    ).copyWith(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 0.5.h),
                ],
                Row(
                  children: [
                    Text(
                      '₹${cartItem.price.toStringAsFixed(0)}',
                      style: TextHelper.size15(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: PremiumColors.gold,
                      ),
                    ),
                    if (cartItem.discount > 0) ...[
                      SizedBox(width: 2.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 0.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${cartItem.discount}% OFF',
                          style: TextHelper.size14(context).copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Quantity Controls
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Decrease Button
                Obx(
                  () => GestureDetector(
                    onTap: cartController.itemLoadingStates[cartItem.id] == true
                        ? null
                        : () => cartController.decreaseQuantity(
                            cartItem.id,
                            context: context,
                          ),
                    child: Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        color: cartItem.quantity <= 1
                            ? Colors.grey[200]
                            : PremiumColors.gold.withAlpha((0.1 * 255).toInt()),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                        ),
                      ),
                      child:
                          cartController.itemLoadingStates[cartItem.id] == true
                          ? SizedBox(
                              width: 4.w,
                              height: 4.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  PremiumColors.gold,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.remove,
                              size: 4.w,
                              color: cartItem.quantity <= 1
                                  ? Colors.grey[400]
                                  : PremiumColors.gold,
                            ),
                    ),
                  ),
                ),

                // Quantity Display
                Container(
                  width: 12.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: themeController.isDark
                        ? PremiumColors.grey600
                        : Colors.white,
                  ),
                  child: Center(
                    child: Text(
                      '${cartItem.quantity}',
                      style: TextHelper.size12(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: themeController.isDark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                ),

                // Increase Button
                Obx(
                  () => GestureDetector(
                    onTap: cartController.itemLoadingStates[cartItem.id] == true
                        ? null
                        : () => cartController.increaseQuantity(
                            cartItem.id,
                            context: context,
                          ),
                    child: Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        color: PremiumColors.gold.withAlpha(
                          (0.1 * 255).toInt(),
                        ),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      child:
                          cartController.itemLoadingStates[cartItem.id] == true
                          ? SizedBox(
                              width: 4.w,
                              height: 4.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  PremiumColors.gold,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.add,
                              size: 4.w,
                              color: PremiumColors.gold,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3Payment(
    BuildContext context,
    ThemeController themeController,
    CartController cartController,
  ) {
    return Column(
      children: [
        // Payment Method Section
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: themeController.isDark
                ? PremiumColors.grey800
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.05 * 255).toInt()),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.payment, color: PremiumColors.gold, size: 5.w),
                  SizedBox(width: 2.w),
                  Text(
                    'Payment Method',
                    style: TextHelper.size16(context).copyWith(
                      fontWeight: FontWeight.bold,
                      color: themeController.isDark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),

              // Cash on Delivery Option
              Obx(
                () => Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _selectedPaymentMethod.value == 'cash_on_delivery'
                          ? PremiumColors.gold
                          : Colors.grey[300]!,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: RadioListTile<String>(
                    value: 'cash_on_delivery',
                    groupValue: _selectedPaymentMethod.value,
                    onChanged: (value) {
                      _selectedPaymentMethod.value = value!;
                    },
                    title: Text(
                      'Cash on Delivery',
                      style: TextHelper.size14(context).copyWith(
                        fontWeight: FontWeight.w600,
                        color: themeController.isDark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      'Pay when your order is delivered',
                      style: TextHelper.size12(
                        context,
                      ).copyWith(color: Colors.grey[600]),
                    ),
                    secondary: Icon(Icons.money, color: PremiumColors.gold),
                    activeColor: PremiumColors.gold,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 3.h),

        // Order Summary
        _buildOrderSummary(context, themeController, cartController),
      ],
    );
  }

  Widget _buildOrderSummary(
    BuildContext context,
    ThemeController themeController,
    CartController cartController,
  ) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: themeController.isDark ? PremiumColors.grey800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).toInt()),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: TextHelper.size16(context).copyWith(
              fontWeight: FontWeight.bold,
              color: themeController.isDark ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(height: 2.h),

          // Subtotal
          _buildSummaryRow(
            context,
            themeController,
            'Subtotal',
            '₹${cartController.cartModel.value?.totalAmount.toStringAsFixed(0) ?? '0'}',
          ),
          SizedBox(height: 1.h),

          // Discount
          if (cartController.cartModel.value?.discountAmount != null &&
              cartController.cartModel.value!.discountAmount > 0)
            _buildSummaryRow(
              context,
              themeController,
              'Discount',
              '-₹${cartController.cartModel.value!.discountAmount.toStringAsFixed(0)}',
              isDiscount: true,
            ),
          SizedBox(height: 1.h),

          // Delivery Charges
          _buildSummaryRow(
            context,
            themeController,
            'Delivery Charges',
            'FREE',
            isDiscount: true,
          ),
          SizedBox(height: 1.h),

          Divider(color: Colors.grey[300]),
          SizedBox(height: 1.h),

          // Total
          _buildSummaryRow(
            context,
            themeController,
            'Total Amount',
            '₹${cartController.cartModel.value?.finalAmount.toStringAsFixed(0) ?? '0'}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    ThemeController themeController,
    String label,
    String value, {
    bool isDiscount = false,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextHelper.size14(context).copyWith(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isDiscount
                ? Colors.green
                : themeController.isDark
                ? Colors.white
                : Colors.black,
          ),
        ),
        Text(
          value,
          style: TextHelper.size14(context).copyWith(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isDiscount
                ? Colors.green
                : isTotal
                ? PremiumColors.gold
                : themeController.isDark
                ? Colors.white
                : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation(
    BuildContext context,
    ThemeController themeController,
    CartController cartController,
  ) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: themeController.isDark ? PremiumColors.grey800 : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).toInt()),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back Button (not shown on step 0)
          if (_currentStep.value > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _currentStep.value--;
                },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  side: BorderSide(color: PremiumColors.gold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Back',
                  style: TextHelper.size14(context).copyWith(
                    color: PremiumColors.gold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(width: 3.w),
          ],

          // Next/Place Order Button
          Expanded(
            flex: _currentStep.value == 0 ? 1 : 2,
            child: ElevatedButton(
              onPressed: _isProcessing.value
                  ? null
                  : () {
                      // Debouncing: Prevent clicks within 1 second
                      final now = DateTime.now();
                      if (_lastClickTime.value != null &&
                          now.difference(_lastClickTime.value!).inMilliseconds <
                              1000) {
                        return;
                      }
                      _lastClickTime.value = now;

                      if (_currentStep.value < 2) {
                        _goToNextStep();
                      } else {
                        _placeOrder(context, cartController);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: PremiumColors.gold,
                padding: EdgeInsets.symmetric(vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Obx(
                () => _isProcessing.value
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 4.w,
                            height: 4.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Processing...',
                            style: TextHelper.size14(context).copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        _currentStep.value < 2 ? 'Next' : 'Place Order',
                        style: TextHelper.size14(context).copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _goToNextStep() {
    if (_currentStep.value == 0) {
      // Validate address form
      if (_formKey.currentState!.validate()) {
        _currentStep.value++;
      }
    } else if (_currentStep.value == 1) {
      // Move to payment step
      _currentStep.value++;
    }
  }

  Future<void> _placeOrder(
    BuildContext context,
    CartController cartController,
  ) async {
    // Additional check to prevent multiple processing
    if (_isProcessing.value) return;

    _isProcessing.value = true;

    try {
      // Create shipping address
      final shippingAddress = OrderAddress(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        pincode: _pincodeController.text.trim(),
      );

      // Create order items from cart
      final orderItems = cartController.cartItems.map((cartItem) {
        return OrderItem(
          id: cartItem.id,
          productId: cartItem.productId,
          productName: cartItem.productName,
          productImage: cartItem.productImage,
          price: cartItem.price,
          discount: cartItem.discount,
          quantity: cartItem.quantity,
          variantId: cartItem.variantId,
          variantAttributes: cartItem.variantAttributes,
          totalPrice: cartItem.totalPrice,
        );
      }).toList();

      // Create order data for API (without auto-generated fields)
      final orderData = {
        'items': orderItems
            .map(
              (item) => {
                'productId': item.productId,
                'productName': item.productName,
                'productImage': item.productImage,
                'price': item.price,
                'discount': item.discount,
                'quantity': item.quantity,
                'variantId': item.variantId,
                'variantAttributes': item.variantAttributes,
                'totalPrice': item.totalPrice,
              },
            )
            .toList(),
        'shippingAddress': {
          'name': shippingAddress.name,
          'phone': shippingAddress.phone,
          'address': shippingAddress.address,
          'city': shippingAddress.city,
          'state': shippingAddress.state,
          'pincode': shippingAddress.pincode,
          'country': shippingAddress.country,
        },
        'billingAddress': {
          'name': shippingAddress.name,
          'phone': shippingAddress.phone,
          'address': shippingAddress.address,
          'city': shippingAddress.city,
          'state': shippingAddress.state,
          'pincode': shippingAddress.pincode,
          'country': shippingAddress.country,
        },
        'paymentMethod': _selectedPaymentMethod.value,
        'notes': '',
      };

      // Add to order controller
      final orderController = Get.find<OrderController>();
      final success = await orderController.createOrderFromData(
        orderData,
        context: context,
      );

      if (success) {
        // Clear cart without showing toast
        await cartController.clearCart(context: context, showToast: false);

        // Navigate back to dashboard with proper navigation
        Get.offAllNamed(Routes.DASHBOARD_SCREEN);
      }
    } catch (e) {
      print('Error placing order: $e');
      CustomSnackBar.SnackBar.error(
        title: 'Error',
        message: 'Failed to place order. Please try again.',
      );
    } finally {
      _isProcessing.value = false;
    }
  }
}
