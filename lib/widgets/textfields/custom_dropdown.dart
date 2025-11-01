import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../utils/text_styles.dart';
import '../constant_widgets.dart';

class CustomDropdown extends StatelessWidget {
  final String? title;
  final List<String> items;
  final String hint;
  final Function(String) onChanged;
  final double maxHeight;
  final String? value;
  final String? Function(String? value)? validator;
  final bool mandatory;
  final Widget? prefixIcon;
  final bool prefixIconWidthFlexible;

  // New parameter for decoration override
  final InputDecoration? customDecoration;

  CustomDropdown({
    Key? key,
    this.title,
    required this.items,
    required this.hint,
    required this.onChanged,
    this.value,
    double? maxHeight,
    this.validator,
    this.mandatory = false,
    this.prefixIcon,
    this.prefixIconWidthFlexible = false,
    this.customDecoration, // new
  }) : maxHeight = maxHeight ?? 13.h,
       super(key: key);

  // Helper method to get a valid value that exists in items
  String? _getValidValue() {
    if (value == null || value!.isEmpty) {
      return null;
    }

    // Check if the current value exists in the items list
    if (items.contains(value)) {
      return value;
    }

    // If value doesn't exist in items, return null to show hint
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Default decoration
    InputDecoration defaultDecoration = InputDecoration(
      contentPadding: EdgeInsets.symmetric(
        vertical: 2.h,
        horizontal: prefixIcon == null ? 2.w : 0,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withAlpha((0.5 * 255).toInt()),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withAlpha((0.5 * 255).toInt()),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Theme.of(
            context,
          ).colorScheme.secondary.withAlpha((0.5 * 255).toInt()),
          width: 1.5,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withAlpha((0.25 * 255).toInt()),
        ),
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
                        prefixIcon!,
                        VerticalDivider(
                          indent: 1.h,
                          endIndent: 1.h,
                          color: Theme.of(context).colorScheme.onSurface
                              .withAlpha((0.5 * 255).toInt()),
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
                          Expanded(child: Center(child: prefixIcon!)),
                          VerticalDivider(
                            indent: 1.h,
                            endIndent: 1.h,
                            width: 0,
                            color: Theme.of(context).colorScheme.onSurface
                                .withAlpha((0.5 * 255).toInt()),
                          ),
                          width(2.w),
                        ],
                      ),
                    ),
                  )),
    );

    // Merge with custom decoration if provided
    final effectiveDecoration = defaultDecoration.copyWith(
      // Only overwrite properties if customDecoration has them
      border: customDecoration?.border ?? defaultDecoration.border,
      enabledBorder:
          customDecoration?.enabledBorder ?? defaultDecoration.enabledBorder,
      focusedBorder:
          customDecoration?.focusedBorder ?? defaultDecoration.focusedBorder,
      contentPadding:
          customDecoration?.contentPadding ?? defaultDecoration.contentPadding,
      prefixIcon: customDecoration?.prefixIcon ?? defaultDecoration.prefixIcon,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null && title!.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: 0.5.h),
            child: RichText(
              text: TextSpan(
                text: title!,
                style: TextHelper.size15(
                  context,
                ).copyWith(fontWeight: FontWeight.w500),
                children: mandatory
                    ? [
                        TextSpan(
                          text: ' *',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ]
                    : [],
              ),
            ),
          ),
        DropdownButtonFormField2<String>(
          isExpanded: true,
          value: _getValidValue(),
          decoration: effectiveDecoration,
          hint: Text(
            hint,
            style: TextHelper.size14(
              context,
            ).copyWith(color: Colors.grey.withAlpha((0.75 * 255).toInt())),
          ),
          items: items
              .toSet() // Remove duplicates
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, style: const TextStyle(fontSize: 14)),
                ),
              )
              .toList(),
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
          dropdownStyleData: DropdownStyleData(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.sp),
            ),
            maxHeight: maxHeight,
          ),
          menuItemStyleData: MenuItemStyleData(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
          ),
          iconStyleData: IconStyleData(
            icon: const Icon(Icons.arrow_drop_down, color: Colors.black45),
            iconSize: 18.sp,
          ),
          validator: validator,
        ),
      ],
    );
  }
}
