import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../utils/app_colors.dart';
import '../../utils/text_styles.dart';
import '../constant_widgets.dart';
import 'custom_search_drop_down.dart';
import 'custom_textfield.dart';

class PasswordFieldController extends GetxController {
  var isVisible = false.obs;

  void toggleVisibility() {
    isVisible.value = !isVisible.value;
  }
}

class PasswordLabelFieldWithBorder extends StatelessWidget {
  final String label;
  final String hintText;
  final EdgeInsetsGeometry padding;
  final TextEditingController textEditingController;
  final InputBorder? border;
  final void Function(String)? onChanged;
  final ValidatorCallBack validatorCallBack;
  final PasswordFieldController controller;
  final bool prefixIconWidthFlexible;
  final Widget? prefixIcon;
  final TextStyle? hintStyle;

  PasswordLabelFieldWithBorder({
    super.key,
    required this.label,
    required this.hintText,
    this.padding = const EdgeInsets.all(5),
    required this.textEditingController,
    required this.controller,
    this.validatorCallBack,
    this.border,
    this.onChanged,
    this.prefixIconWidthFlexible = false,
    this.prefixIcon,
    this.hintStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextHelper.size16(context).copyWith(color: Colors.black, fontWeight: FontWeight.w400),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 1.h),
            child: Obx(
              () => CustomTextField(
                onChanged: onChanged,
                controller: textEditingController,
                maxLines: 1,
                obscureText: !controller.isVisible.value,
                style: TextHelper.size16(context).copyWith(color: Colors.black),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(2.h),
                  fillColor: ColorsForApp.whiteColor,
                  hintText: hintText,
                  hintStyle: TextHelper.size14(context).copyWith(color: Colors.grey.withAlpha((0.75 * 255).toInt())).merge(hintStyle),
                  border:
                      border ??
                      OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withAlpha((0.5 * 255).toInt())),
                      ),
                  enabledBorder:
                      border ??
                      OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withAlpha((0.5 * 255).toInt())),
                      ),
                  disabledBorder:
                      border ??
                      OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withAlpha((0.25 * 255).toInt())),
                      ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                  ),
                  focusedBorder:
                      border ??
                      OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary.withAlpha((0.5 * 255).toInt()), width: 1.5),
                      ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(controller.isVisible.value ? Icons.visibility : Icons.visibility_off, color: ColorsForApp.colorBlackShade),
                    onPressed: controller.toggleVisibility,
                  ),
                  prefixIcon: prefixIcon == null
                      ? null
                      : (prefixIconWidthFlexible
                            ? IntrinsicHeight(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (prefixIcon != null) prefixIcon!,
                                    VerticalDivider(
                                      indent: 1.h,
                                      endIndent: 1.h,
                                      color: Theme.of(context).colorScheme.onSurface.withAlpha((0.5 * 255).toInt()),
                                    ),
                                  ],
                                ),
                              )
                            : SizedBox(
                                width: 15.w,
                                child: IntrinsicHeight(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      if (prefixIcon != null) Expanded(child: Center(child: prefixIcon!)),
                                      VerticalDivider(
                                        indent: 1.h,
                                        endIndent: 1.h,
                                        width: 0,
                                        color: Theme.of(context).colorScheme.onSurface.withAlpha((0.5 * 255).toInt()),
                                      ),
                                      width(2.w),
                                    ],
                                  ),
                                ),
                              )),
                ),
                validator:
                    validatorCallBack ??
                    (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required.';
                      }
                      if (!RegExp(r'^.{8,}$').hasMatch(value)) {
                        return 'Password must be at least 8 characters long.';
                      }
                      if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
                        return 'Password must include at least one uppercase letter.';
                      }
                      if (!RegExp(r'(?=.*[a-z])').hasMatch(value)) {
                        return 'Password must include at least one lowercase letter.';
                      }
                      if (!RegExp(r'(?=.*\d)').hasMatch(value)) {
                        return 'Password must include at least one number.';
                      }
                      if (!RegExp(r'(?=.*[@$!%*?&#^])').hasMatch(value)) {
                        return 'Password must include at least one special character.';
                      }
                      return null;
                    },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
