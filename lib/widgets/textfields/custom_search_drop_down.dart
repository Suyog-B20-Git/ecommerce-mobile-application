import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:sizer/sizer.dart';

import '../../utils/text_styles.dart';
import '../constant_widgets.dart';

typedef ValidatorCallBack = String? Function(String? value)?;

class SuggestionTextFieldHelper {
  static Column buildSuggestionField<T>({
    Key? key,
    String? labelName,
    bool recommend = false,
    bool readOnly = false,
    required BuildContext context,
    required String hintText,
    required TextEditingController controller,
    ValidatorCallBack? validatorCallBack,
    required void Function(T item)? onSelected,
    required FutureOr<List<T>> Function(String search) suggestionsCallback,
    required Widget Function(BuildContext buildContext, T item) itemBuilder,
    void Function(String)? onChanged,
    Widget? prefixIcon, // ADDED
    final bool prefixIconWidthFlexible = false,
    final void Function()? onTap,
  }) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelName != null && labelName.isNotEmpty)
          RichText(
            text: TextSpan(
              text: labelName,
              style: TextHelper.size15(context).copyWith(fontWeight: FontWeight.w500),
              children: recommend ? [const TextSpan(text: ' *', style: TextStyle(color: Colors.red))] : [],
            ),
          ),
        height(0.5.h),
        TypeAheadField<T>(
          builder: (context, textController, focusNode) {
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              readOnly: readOnly,
              autofocus: false,
              onTap: () {
                if (onTap != null) {
                  onTap();
                }
              },
              style: TextHelper.size16(context),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 2.h, horizontal: prefixIcon == null ? 2.w : 0),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withAlpha((0.5 * 255).toInt())),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary.withAlpha((0.5 * 255).toInt()), width: 1.5),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withAlpha((0.5 * 255).toInt())),
                ),
                hintText: hintText,
                hintStyle: TextHelper.size14(context).copyWith(color: Colors.grey.withAlpha((0.75 * 255).toInt())),
                suffixIcon: Icon(Icons.keyboard_arrow_down, size: 19.sp, color: Colors.black),
                prefixIcon:
                    prefixIcon == null
                        ? null
                        : (prefixIconWidthFlexible
                            ? IntrinsicHeight(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (prefixIcon != null) prefixIcon,
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
              validator: (value) => validatorCallBack?.call(value),
              onChanged: onChanged,
            );
          },
          controller: controller,
          itemBuilder: itemBuilder,
          hideOnUnfocus: false,
          onSelected: onSelected,
          hideOnEmpty: true,
          hideOnSelect: true,
          suggestionsCallback: suggestionsCallback,
        ),
      ],
    );
  }
}
