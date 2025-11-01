import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../utils/app_colors.dart';
import '../../utils/text_styles.dart';
import '../../widgets/textfields/custom_textfield.dart';
import '../constant_widgets.dart';
import '../custom_buttons.dart';
import '../textfields/custom_dropdown.dart';

class CustomDialog {
  CustomDialog._();
  static void showCustomDialogWithButtons({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColors,
    required String title,
    required String subtitle,
    required String button1Text,
    required VoidCallback onButton1Pressed,
    required String button2Text,
    required VoidCallback onButton2Pressed,
    ValueChanged<String>? onChanged,
    TextEditingController? textController,
    // String? labelText,
    String? hintText,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 85.w,
            padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 5.w),
            decoration: BoxDecoration(
              color: backgroundColors,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(2, 4))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title and Close Button
                Stack(
                  children: [
                    Center(child: Text(title, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: Colors.black))),
                    Positioned(
                      right: 0,
                      top: -2.h,
                      child: IconButton(icon: const Icon(Icons.close, color: Colors.black), onPressed: () => Get.back()),
                    ),
                  ],
                ),
                height(2.h),

                // Subtitle
                Text(subtitle, textAlign: TextAlign.center, style: TextStyle(fontSize: 14.sp, color: ColorsForApp.subTitleColor)),

                // Optional TextField
                if (textController != null) ...[
                  height(2.h),
                  CustomTextField(
                    // labelText: labelText ?? "Label",
                    hintText: hintText ?? "Enter something...",
                    controller: textController,
                    onChanged: onChanged,
                  ),
                ],

                height(3.h),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Button 1
                    GestureDetector(
                      onTap: onButton1Pressed,
                      child: Container(
                        width: 30.w,
                        padding: EdgeInsets.symmetric(vertical: 1.5.h),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Text(button1Text, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: Colors.grey)),
                      ),
                    ),

                    // Button 2
                    GestureDetector(
                      onTap: onButton2Pressed,
                      child: Container(
                        width: 30.w,
                        padding: EdgeInsets.symmetric(vertical: 1.5.h),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: ColorsForApp.primaryColor,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(2, 3))],
                        ),
                        child: Text(button2Text, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void showDialogWithDropDownButtons({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required backgroundColors,
    required String title,
    required String label,
    required String hint,
    required double maxHeight,
    required List<String> items,
    required String button1Text,
    required void Function(String?) onButton1Pressed,
    required String button2Text,
    required void Function(String?) onButton2Pressed,
    required void Function(String?) onChanged,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        var selectedValue = ''.obs;

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Container(
                width: 85.w,
                padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 5.w),
                decoration: BoxDecoration(
                  color: backgroundColors,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(2, 4))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      children: [
                        Center(child: Text(title, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: Colors.black))),
                        Positioned(
                          right: 0,
                          top: -2.h,
                          child: IconButton(icon: const Icon(Icons.close, color: Colors.black), onPressed: () => Get.close(1)),
                        ),
                      ],
                    ),
                    height(2.h),
                    Column(
                      children: [
                        CustomDropdown(
                          title: label,
                          items: items,
                          hint: hint,
                          onChanged: (value) {
                            selectedValue.value = value;
                            onChanged(value);
                          },
                          maxHeight: maxHeight,
                        ),
                      ],
                    ),
                    height(3.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () => onButton1Pressed(selectedValue.value),
                          child: Container(
                            width: 30.w,
                            padding: EdgeInsets.symmetric(vertical: 1.5.h),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Text(button1Text, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: Colors.grey)),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => onButton2Pressed(selectedValue.value),
                          child: Container(
                            width: 30.w,
                            padding: EdgeInsets.symmetric(vertical: 1.5.h),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: ColorsForApp.primaryColor,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(2, 3))],
                            ),
                            child: Text(button2Text, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  static void showCustomDialogWithImages({
    required BuildContext context,
    required String imagePath,
    required String title,
    required String subtitle,
    required String cancelButtonText,
    required String okButtonText,
    required VoidCallback onCancel,
    required VoidCallback onOk,
    Color backgroundColor = Colors.white,
    Color titleColor = Colors.black,
    Color subtitleColor = Colors.grey,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 85.w,
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
            decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(20)),
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(child: Image.asset(imagePath, height: 6.h, width: 6.h, fit: BoxFit.contain)),
                    height(2.h),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: titleColor),
                    ),
                    height(1.h),
                    Text(subtitle, textAlign: TextAlign.center, style: TextStyle(fontSize: 14.sp, color: subtitleColor)),
                    height(3.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Cancel Button
                        GestureDetector(
                          onTap: () {
                            Get.close(1);
                            // onCancel();
                          },
                          child: Container(
                            width: 30.w,
                            padding: EdgeInsets.symmetric(vertical: 1.5.h),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(cancelButtonText, style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
                          ),
                        ),
                        // OK Button
                        GestureDetector(
                          onTap: () {
                            // Get.close(1);
                            onOk();
                          },
                          child: Container(
                            width: 30.w,
                            padding: EdgeInsets.symmetric(vertical: 1.5.h),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: ColorsForApp.primaryColor, borderRadius: BorderRadius.circular(10)),
                            child: Text(okButtonText, style: TextStyle(fontSize: 14.sp, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Close Icon
                Positioned(
                  right: 0,
                  top: -2.h,
                  child: IconButton(icon: const Icon(Icons.close, color: Colors.black), onPressed: () => Get.back()),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void showCustomDialogWithTextFieldButtons({
    required BuildContext context,
    required Color backgroundColors,
    required String title,
    required String subtitle,
    required String button1Text,
    required VoidCallback onButton1Pressed,
    required String button2Text,
    required VoidCallback onButton2Pressed,
    VoidCallback? onClosePressed,
    String label = '',
    String hint = '',
    TextEditingController? textFieldController,
    void Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 85.w,
            padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 5.w),
            decoration: BoxDecoration(
              color: backgroundColors,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(2, 4))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    Center(child: Text(title, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500, color: Colors.black))),
                    Positioned(
                      right: 0,
                      top: -2.2.h,
                      child: IconButton(icon: Icon(Icons.close, color: Colors.red), onPressed: onClosePressed ?? () => Get.back()),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(subtitle, textAlign: TextAlign.center, style: TextStyle(fontSize: 14.sp, color: Colors.black)),
                SizedBox(height: 2.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    style: TextHelper.size16(context).copyWith(fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface),
                  ),
                ),
                CustomTextField(hintText: hint, controller: textFieldController, onChanged: onChanged, validator: validator),
                SizedBox(height: 3.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: onButton1Pressed,
                      child: Container(
                        width: 30.w,
                        padding: EdgeInsets.symmetric(vertical: 1.5.h),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(2, 3))],
                        ),
                        child: Text(button1Text, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400, color: Colors.grey)),
                      ),
                    ),
                    GestureDetector(
                      onTap: onButton2Pressed,
                      child: Container(
                        width: 30.w,
                        padding: EdgeInsets.symmetric(vertical: 1.5.h),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: ColorsForApp.primaryColor,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(2, 3))],
                        ),
                        child: Text(button2Text, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static AlertDialog yesNoDialog(BuildContext context, {String? title, required String note}) {
    return AlertDialog(
      title: Text(title ?? 'Alert', style: TextStyle(fontSize: 16.sp)),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(note, style: TextStyle(fontSize: 14.sp)),
          height(2.h),
          Row(
            children: [
              Expanded(
                child: CustomButtonTwo(
                  width: 30.w,
                  borderSide: BorderSide(color: ColorsForApp.primaryColor, width: 1.5),
                  labelStyle: TextStyle(color: ColorsForApp.primaryColor),
                  onPressed: () {
                    Get.back(result: false);
                  },
                  label: 'No',
                ),
              ),
              width(3.w),
              Expanded(
                child: CustomButtonTwo(
                  width: 30.w,
                  onPressed: () {
                    Get.back(result: true);
                  },
                  label: 'Yes',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CustomFormDialog extends StatelessWidget {
  final String title;
  final List<Widget> fields;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const CustomFormDialog({Key? key, required this.title, required this.fields, required this.onSave, required this.onCancel})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(icon: Icon(Icons.close), onPressed: () => Get.back()),
              ],
            ),

            // Divider Line
            Divider(),

            // Dynamic Fields
            ...fields,

            SizedBox(height: 10),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(onPressed: onCancel, style: ElevatedButton.styleFrom(backgroundColor: Colors.grey), child: Text("Cancel")),
                ElevatedButton(onPressed: onSave, style: ElevatedButton.styleFrom(backgroundColor: Colors.blue), child: Text("Save")),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CustomDownloadDialog extends StatelessWidget {
  final String title;
  final String button1Text;
  final String button2Text;
  final VoidCallback onButton1Pressed;
  final VoidCallback onButton2Pressed;

  const CustomDownloadDialog({
    super.key,
    required this.title,
    required this.button1Text,
    required this.button2Text,
    required this.onButton1Pressed,
    required this.onButton2Pressed,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon(Icons.download_for_offline_rounded, color: Colors.pink, size: 30.sp),
            // const SizedBox(height: 10),
            Text(title, style: TextHelper.size18(context).copyWith(fontWeight: FontWeight.bold)),
            height(2.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onButton1Pressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.download, color: Colors.white),
                    label: Text(button1Text, style: TextHelper.size14(context).copyWith(color: Colors.white)),
                  ),
                ),
                width(2.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onButton2Pressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                    label: Text(button2Text, style: TextHelper.size14(context).copyWith(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
