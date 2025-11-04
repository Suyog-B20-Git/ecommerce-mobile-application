import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../controller/theme_controller.dart';
import '../../controller/profile_controller.dart';
import '../../utils/theme_config.dart';
import '../../utils/text_styles.dart';
import '../../widgets/textfields/custom_textfield.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late ProfileController profileController;
  late ThemeController themeController;

  @override
  void initState() {
    super.initState();
    profileController = Get.put(ProfileController());
    themeController = Get.find<ThemeController>();
    profileController.loadUserProfile(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeController.isDark
          ? PremiumColors.charcoal
          : PremiumColors.softBackground,
      appBar: AppBar(
        title: Text(
          'Edit Profile',
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
        // Show loading only when loading and no profile data
        if (profileController.isLoading.value &&
            profileController.userProfile.value == null) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(PremiumColors.gold),
            ),
          );
        }

        return _buildProfileForm();
      }),
    );
  }

  Widget _buildProfileForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Picture Section
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 12.w,
                    backgroundColor: PremiumColors.gold.withAlpha(
                      (0.2 * 255).toInt(),
                    ),
                    child: Obx(
                      () => Text(
                        profileController.profileInitial.value,
                        style: TextStyle(
                          color: PremiumColors.gold,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: PremiumColors.gold,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: themeController.isDark
                              ? PremiumColors.charcoal
                              : Colors.white,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 4.w,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4.h),

            // Name Field
            CustomTextField(
              controller: profileController.nameController,
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person_outline),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                if (value.length < 2) {
                  return 'Name must be at least 2 characters';
                }
                return null;
              },
              onChanged: (value) {
                // Update profile initial when name changes
                profileController.updateProfileInitial();
              },
            ),
            SizedBox(height: 3.h),

            // Phone Field
            CustomTextField(
              controller: profileController.phoneController,
              labelText: 'Phone Number',
              prefixIcon: Icon(Icons.phone_outlined),
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
            SizedBox(height: 3.h),

            // Date of Birth Field
            CustomTextField(
              controller: profileController.dateOfBirthController,
              labelText: 'Date of Birth',
              prefixIcon: Icon(Icons.calendar_today_outlined),
              isDateField: true,
              allowFutureDates: false,
              validator: (value) {
                // Date of birth is optional
                return null;
              },
            ),
            SizedBox(height: 3.h),

            // Gender Selection
            Text(
              'Gender',
              style: TextHelper.size14(context).copyWith(
                fontWeight: FontWeight.w600,
                color: themeController.isDark ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 1.5.h),
            Obx(
              () => Row(
                children: [
                  Expanded(
                    child: _buildGenderOption(
                      context,
                      profileController,
                      'male',
                      'Male',
                      profileController.selectedGender.value == 'male',
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: _buildGenderOption(
                      context,
                      profileController,
                      'female',
                      'Female',
                      profileController.selectedGender.value == 'female',
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: _buildGenderOption(
                      context,
                      profileController,
                      'other',
                      'Other',
                      profileController.selectedGender.value == 'other',
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 5.h),

            // Save Button
            Obx(
              () => ElevatedButton(
                onPressed: profileController.isLoading.value
                    ? null
                    : () async {
                        final success = await profileController.saveProfile(
                          context: context,
                          formKey: _formKey,
                        );
                        if (success) {
                          Get.back();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: PremiumColors.gold,
                  padding: EdgeInsets.symmetric(vertical: 2.5.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: profileController.isLoading.value
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
                        'Save Changes',
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
    );
  }

  Widget _buildGenderOption(
    BuildContext context,
    ProfileController controller,
    String value,
    String label,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () => controller.setGender(value),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        decoration: BoxDecoration(
          color: isSelected
              ? PremiumColors.gold.withAlpha((0.2 * 255).toInt())
              : (themeController.isDark
                    ? PremiumColors.grey800
                    : Colors.grey[100]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? PremiumColors.gold
                : Colors.grey.withAlpha((0.3 * 255).toInt()),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextHelper.size14(context).copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? PremiumColors.gold
                  : (themeController.isDark ? Colors.white : Colors.black),
            ),
          ),
        ),
      ),
    );
  }
}
