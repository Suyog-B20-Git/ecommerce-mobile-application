import 'package:flutter/material.dart';

import '../utils/text_styles.dart';

class CustomButton extends StatelessWidget {
  // final void Function() onPressed;
  final VoidCallback? onPressed;
  final String label;
  final TextStyle? labelStyle;
  final EdgeInsets? padding;
  final double? width;
  final BorderRadius? borderRadius;
  final double? height;
  final Color? buttonColor;
  final Color? textColor;
  final double? elevation;
  final Color? borderColor;
  final double? borderWidth;
  final FontWeight? fontWeight;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.labelStyle,
    this.padding,
    this.width,
    this.borderRadius,
    this.height,
    this.buttonColor,
    this.textColor,
    this.elevation,
    this.borderColor,
    this.borderWidth = 0,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      minWidth: width,
      height: height,
      elevation: elevation ?? 0,
      clipBehavior: Clip.hardEdge,
      color: buttonColor ?? Theme.of(context).colorScheme.primary,
      padding: padding,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(15),
        side: BorderSide(color: borderColor ?? Theme.of(context).colorScheme.onSurface.withOpacity(0.5), width: borderWidth ?? 0),
      ),
      splashColor: Colors.transparent,
      child: Text(
        label,
        style: TextHelper.size16(
          context,
        ).copyWith(fontWeight: fontWeight ?? FontWeight.w400, color: textColor ?? Theme.of(context).colorScheme.surface).merge(labelStyle),
      ),
    );
  }
}

class CustomButtonTwo extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final TextStyle? labelStyle;
  final EdgeInsets? padding;
  final double? width;
  final BorderRadius? borderRadius;

  final Color? buttonColor;

  final BorderSide borderSide;

  const CustomButtonTwo({
    super.key,
    required this.onPressed,
    required this.label,
    this.labelStyle,
    this.padding,
    this.width,
    this.borderRadius,
    this.buttonColor,
    this.borderSide = BorderSide.none,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      minWidth: width,
      elevation: 0,
      clipBehavior: Clip.hardEdge,
      color: buttonColor ?? (borderSide != BorderSide.none ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.primary),
      padding: padding,
      shape: RoundedRectangleBorder(borderRadius: borderRadius ?? BorderRadius.circular(15), side: borderSide),
      splashColor: Colors.transparent,
      child: Text(label, style: TextHelper.size16(context).copyWith(color: Theme.of(context).colorScheme.surface).merge(labelStyle)),
    );
  }
}
