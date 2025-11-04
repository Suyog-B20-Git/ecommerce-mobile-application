import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../utils/text_styles.dart';
import '../constant_widgets.dart';

class CustomTextField extends StatelessWidget {
  final void Function()? onTap;
  final InputDecoration? decoration;
  final bool autofocus;
  final bool readOnly;
  final String? labelText;
  final TextStyle? labelStyle;
  final String? hintText;
  final TextStyle? hintStyle;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool prefixIconWidthFlexible;
  final bool enabled;
  final TextEditingController? controller;
  final String? Function(String? value)? validator;
  final TextStyle? style;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final TextInputType? keyboardType;
  final String? counterText;
  final InputBorder? border;
  final int? maxLines;
  final int? minLines;
  final Color? fillColor;
  final bool? isDateField;
  final bool? isTimeField;
  final bool allowFutureDates;
  final TextStyle? errorStyle;
  final void Function(String)? onChanged;
  final bool obscureText;
  final Future<List<String>> Function(String query)? suggestionsCallback;
  final void Function(String)? onSuggestionSelected;
  final bool recommend;
  const CustomTextField({
    super.key,
    this.onTap,
    this.decoration,
    this.autofocus = false,
    this.readOnly = false,
    this.labelText,
    this.labelStyle,
    this.hintText,
    this.hintStyle,
    this.prefixIcon,
    this.controller,
    this.prefixIconWidthFlexible = false,
    this.enabled = true,
    this.suffixIcon,
    this.validator,
    this.style,
    this.inputFormatters,
    this.maxLength,
    this.keyboardType,
    this.counterText,
    this.border,
    this.maxLines,
    this.minLines,
    this.isDateField = false,
    this.isTimeField = false,
    this.allowFutureDates = false,
    this.errorStyle,
    this.onChanged,
    this.obscureText = false,
    this.suggestionsCallback,
    this.onSuggestionSelected,
    this.fillColor,
    this.recommend = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null)
          Padding(
            padding: EdgeInsets.only(bottom: 0.5.h),
            child: RichText(
              text: TextSpan(
                text: labelText,
                style: (labelStyle ?? TextHelper.size15(context)).copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                children: recommend
                    ? const [
                        TextSpan(
                          text: ' *',
                          style: TextStyle(color: Colors.red),
                        ),
                      ]
                    : [],
              ),
            ),
          ),
        TextFormField(
          controller: controller,
          validator: validator,
          onTap: () {
            if (isTimeField == true) {
              TimePickerHelper.selectTime(context, controller!);
            } else if (isDateField == true) {
              DatePickerHelper.selectDate(
                context,
                controller!,
                allowFutureDates: allowFutureDates,
              );
            } else {
              if (onTap != null) {
                onTap!();
              }
            }
          },
          autofocus: autofocus,
          enabled: enabled,
          readOnly: readOnly || isDateField!,
          style: TextHelper.size16(context)
              .copyWith(
                color: Colors.black87, // Ensure text is clearly visible
              )
              .merge(style),
          cursorWidth: 1,
          maxLength: maxLength,
          maxLines: maxLines,
          minLines: minLines,
          inputFormatters: inputFormatters,
          cursorHeight: 2.h,
          keyboardType: keyboardType,
          onChanged: onChanged,
          obscureText: obscureText,
          decoration:
              decoration ??
              InputDecoration(
                // labelText: labelText ?? '',
                //  floatingLabelBehavior: FloatingLabelBehavior.always,
                counterText: counterText ?? '',
                fillColor: fillColor ?? Colors.white,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 2.h,
                  horizontal: prefixIcon == null ? 2.w : 0,
                ),
                // labelStyle: TextHelper.size16(context).merge(labelStyle),
                hintText: hintText,
                hintStyle: TextHelper.size14(context)
                    .copyWith(
                      color: Colors.grey[600], // More visible hint text
                    )
                    .merge(hintStyle),
                errorStyle: TextStyle(fontSize: 13.sp).merge(errorStyle),
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
                                    color: Colors
                                        .grey[400]!, // More visible divider
                                  ),
                                ],
                              ),
                            )
                          : SizedBox(
                              width: 15.w,
                              child: IntrinsicHeight(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    if (prefixIcon != null)
                                      Expanded(
                                        child: Center(child: prefixIcon!),
                                      ),
                                    VerticalDivider(
                                      indent: 1.h,
                                      endIndent: 1.h,
                                      width: 0,
                                      color: Colors
                                          .grey[400]!, // More visible divider
                                    ),
                                    width(2.w),
                                  ],
                                ),
                              ),
                            )),
                suffixIcon: suffixIcon,
                border:
                    border ??
                    OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Colors.grey[400]!, // More visible border
                        width: 1.5,
                      ),
                    ),
                enabledBorder:
                    border ??
                    OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Colors.grey[400]!, // More visible border
                        width: 1.5,
                      ),
                    ),
                disabledBorder:
                    border ??
                    OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color:
                            Colors.grey[300]!, // More visible disabled border
                        width: 1.0,
                      ),
                    ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.error,
                    width: 1.5,
                  ),
                ),
                focusedBorder:
                    border ??
                    OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2.0,
                      ),
                    ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.error,
                    width: 2.0,
                  ),
                ),
              ),
        ),
      ],
    );
  }
}

class DatePickerHelper {
  static Future<void> selectDate(
    BuildContext context,
    TextEditingController controller, {
    bool allowFutureDates = false,
  }) async {
    DateTime now = DateTime.now();
    DateTime initialDate = now;
    DateTime firstDate = DateTime(1950);
    DateTime lastDate = allowFutureDates
        ? DateTime(2100, 12, 31)
        : DateTime(now.year, now.month, now.day);

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFFD97706), // PremiumColors.gold
              onPrimary: Colors.white,
              secondary: const Color(0xFFD97706),
              onSecondary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
              background: Colors.white,
              onBackground: Colors.black87,
              error: Colors.red,
              onError: Colors.white,
              brightness: Brightness.light,
              surfaceContainerHighest: Colors.grey[100],
              secondaryContainer: Colors.grey[50],
            ),
            scaffoldBackgroundColor: Colors.white,
            dialogBackgroundColor: Colors.white,
            cardColor: Colors.white,
            canvasColor: Colors.white,
            primaryColor: const Color(0xFFD97706),
            textTheme: TextTheme(
              displayLarge: TextStyle(color: Colors.black87),
              displayMedium: TextStyle(color: Colors.black87),
              displaySmall: TextStyle(color: Colors.black87),
              headlineLarge: TextStyle(color: Colors.black87),
              headlineMedium: TextStyle(color: Colors.black87),
              headlineSmall: TextStyle(color: Colors.black87),
              titleLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
              titleMedium: TextStyle(color: Colors.black87),
              titleSmall: TextStyle(color: Colors.black87),
              bodyLarge: TextStyle(color: Colors.black87),
              bodyMedium: TextStyle(color: Colors.black87),
              bodySmall: TextStyle(color: Colors.black87),
              labelLarge: TextStyle(color: Colors.black87),
              labelMedium: TextStyle(color: Colors.black87),
              labelSmall: TextStyle(color: Colors.black87),
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: Colors.white,
              headerBackgroundColor: const Color(0xFFD97706),
              headerForegroundColor: Colors.white,
              dayStyle: TextStyle(color: Colors.black87),
              weekdayStyle: TextStyle(color: Colors.black87),
              yearStyle: TextStyle(color: Colors.black87),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      controller.text = formattedDate;
    }
  }
}

class TimePickerHelper {
  static Future<void> selectTime(
    BuildContext context,
    TextEditingController controller,
  ) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      final now = DateTime.now();
      final selectedTime = DateTime(
        now.year,
        now.month,
        now.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      final formattedTime = DateFormat('HH:mm:ss').format(selectedTime);

      controller.text = formattedTime;
    }
  }
}
