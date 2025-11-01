import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import 'font_utils.dart';

// Premium color palette
class PremiumColors {
  // Charcoal and Gold theme
  static const Color charcoal = Color(0xFF111827);
  static const Color gold = Color(0xFFD97706);
  static const Color softBackground = Color(0xFFF9FAFB);

  // Light theme colors
  static const Color lightPrimary = gold;
  static const Color lightSecondary = charcoal;
  static const Color lightSurface = Colors.white;
  static const Color lightBackground = softBackground;
  static const Color lightOnSurface = charcoal;
  static const Color lightOnPrimary = Colors.white;

  // Dark theme colors
  static const Color darkPrimary = gold;
  static const Color darkSecondary = Color(0xFF1F2937);
  static const Color darkSurface = charcoal;
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkOnSurface = Colors.white;
  static const Color darkOnPrimary = charcoal;

  // Accent colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Neutral colors
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);
}

class ThemeConfig {
  static String _getFontFamily() {
    return FontUtils.getFontFamily();
  }

  static ThemeData lightTheme() {
    ColorScheme colorScheme = const ColorScheme.light(
      primary: PremiumColors.lightPrimary,
      primaryContainer: PremiumColors.gold,
      secondary: PremiumColors.lightSecondary,
      secondaryContainer: PremiumColors.grey200,
      tertiary: PremiumColors.info,
      tertiaryContainer: PremiumColors.grey100,
      surface: PremiumColors.lightSurface,
      surfaceBright: PremiumColors.lightBackground,
      surfaceContainer: PremiumColors.grey50,
      surfaceContainerHigh: PremiumColors.grey100,
      surfaceContainerHighest: PremiumColors.grey200,
      onSurface: PremiumColors.lightOnSurface,
      onSurfaceVariant: PremiumColors.grey700,
      onPrimary: PremiumColors.lightOnPrimary,
      onSecondary: PremiumColors.lightOnPrimary,
      onTertiary: PremiumColors.lightOnPrimary,
      outline: PremiumColors.grey300,
      outlineVariant: PremiumColors.grey200,
      shadow: PremiumColors.grey900,
      scrim: PremiumColors.grey900,
      inverseSurface: PremiumColors.grey800,
      onInverseSurface: PremiumColors.lightOnSurface,
      inversePrimary: PremiumColors.gold,
      error: PremiumColors.error,
      onError: Colors.white,
      errorContainer: Color(0xFFFFEBEE),
      onErrorContainer: PremiumColors.error,
    );
    return _createTheme(colorScheme);
  }

  static ThemeData darkTheme() {
    ColorScheme colorScheme = const ColorScheme.dark(
      primary: PremiumColors.darkPrimary,
      primaryContainer: PremiumColors.gold,
      secondary: PremiumColors.darkSecondary,
      secondaryContainer: PremiumColors.grey700,
      tertiary: PremiumColors.info,
      tertiaryContainer: PremiumColors.grey800,
      surface: PremiumColors.darkSurface,
      surfaceBright: PremiumColors.darkBackground,
      surfaceContainer: PremiumColors.grey800,
      surfaceContainerHigh: PremiumColors.grey700,
      surfaceContainerHighest: PremiumColors.grey600,
      onSurface: PremiumColors.darkOnSurface,
      onSurfaceVariant: PremiumColors.grey300,
      onPrimary: PremiumColors.darkOnPrimary,
      onSecondary: PremiumColors.darkOnSurface,
      onTertiary: PremiumColors.darkOnSurface,
      outline: PremiumColors.grey600,
      outlineVariant: PremiumColors.grey700,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: PremiumColors.grey100,
      onInverseSurface: PremiumColors.darkOnSurface,
      inversePrimary: PremiumColors.gold,
      error: PremiumColors.error,
      onError: Colors.white,
      errorContainer: Color(0xFF4B1113),
      onErrorContainer: Color(0xFFFFDAD6),
    );
    return _createTheme(colorScheme);
  }

  static ThemeData _createTheme(ColorScheme colorScheme) {
    TextTheme textTheme = _createTextTheme(colorScheme);
    return ThemeData(
      fontFamily: _getFontFamily(),
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      primaryColor: colorScheme.primary,
      scaffoldBackgroundColor: colorScheme.surface,
      useMaterial3: true,
      splashColor: colorScheme.primaryFixedDim,
      textTheme: textTheme,
      switchTheme: _createSwitchTheme(colorScheme),
      radioTheme: _createRadioTheme(colorScheme),
      checkboxTheme: _createCheckboxTheme(colorScheme),
      textButtonTheme: _createTextButtonTheme(colorScheme),
      appBarTheme: _createAppBarTheme(colorScheme),
      bottomNavigationBarTheme: _createBottomNavigationBarTheme(colorScheme),
      inputDecorationTheme: _createInputDecorationTheme(colorScheme, textTheme),
      textSelectionTheme: _createTextSelectionTheme(colorScheme),
      listTileTheme: _createListTileTheme(colorScheme),
      dialogTheme: _createDialogTheme(colorScheme),
      bottomSheetTheme: _createBottomSheetTheme(colorScheme),
      dividerTheme: _createDividerTheme(colorScheme),
      buttonTheme: _createButtonTheme(colorScheme),
      snackBarTheme: _createSnackBarTheme(colorScheme),
      datePickerTheme: _createDatePickerTheme(colorScheme),
      sliderTheme: const SliderThemeData(
        minThumbSeparation: 0.5,
        trackShape: RoundedRectSliderTrackShape(),
      ),
      scrollbarTheme: const ScrollbarThemeData(radius: Radius.circular(100)),
    );
  }

  static TextTheme _createTextTheme(ColorScheme colorScheme) {
    final fontFamily = _getFontFamily();
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 28.sp,
        color: colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.normal,
      ),
      displayMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 26.sp,
        color: colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.normal,
      ),
      displaySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 24.sp,
        color: colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.normal,
      ),
      headlineLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 22.sp,
        color: colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.normal,
      ),
      headlineMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 20.sp,
        color: colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.normal,
      ),
      headlineSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 18.sp,
        color: colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.normal,
      ),
      titleLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16.sp,
        color: colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.normal,
      ),
      titleMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 15.sp,
        color: colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.normal,
      ),
      titleSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14.sp,
        color: colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.normal,
      ),
      bodyLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 13.sp,
        color: colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.normal,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12.sp,
        color: colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.normal,
      ),
      bodySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 11.sp,
        color: colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.normal,
      ),
      labelLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 10.sp,
        color: colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.normal,
      ),
      labelMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 9.sp,
        color: colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.normal,
      ),
      labelSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 8.sp,
        color: colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.normal,
      ),
    );
  }

  static SwitchThemeData _createSwitchTheme(ColorScheme colorScheme) {
    return SwitchThemeData(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      thumbColor: WidgetStateProperty.all(colorScheme.onSurface),
      trackColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.disabled) ||
            states.contains(WidgetState.selected)) {
          return colorScheme.onPrimary;
        }
        return colorScheme.surface;
      }),
    );
  }

  static RadioThemeData _createRadioTheme(ColorScheme colorScheme) {
    return RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primary;
        }
        return colorScheme.onSurface.withAlpha((0.5 * 255).toInt());
      }),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      overlayColor: WidgetStateProperty.all(colorScheme.surface),
      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
    );
  }

  static CheckboxThemeData _createCheckboxTheme(ColorScheme colorScheme) {
    return CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primary;
        }
        return colorScheme.surface;
      }),
      side: BorderSide(width: 1.5, color: colorScheme.onSurface),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      checkColor: WidgetStateProperty.all(colorScheme.surface),
      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
    );
  }

  static TextButtonThemeData _createTextButtonTheme(ColorScheme colorScheme) {
    return TextButtonThemeData(
      style: ButtonStyle(
        overlayColor: WidgetStateProperty.all(colorScheme.surface),
        foregroundColor: WidgetStateProperty.all(colorScheme.onSurface),
      ),
    );
  }

  static AppBarTheme _createAppBarTheme(ColorScheme colorScheme) {
    return AppBarTheme(
      scrolledUnderElevation: 0,
      elevation: 0,
      iconTheme: IconThemeData(size: 16.sp, color: colorScheme.onSurface),
      actionsIconTheme: IconThemeData(
        size: 16.sp,
        color: colorScheme.onSurface,
      ),
      titleTextStyle: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),
      centerTitle: false,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
      ),
      foregroundColor: colorScheme.onSurface,
      backgroundColor: Colors.white,
    );
  }

  static BottomNavigationBarThemeData _createBottomNavigationBarTheme(
    ColorScheme colorScheme,
  ) {
    return BottomNavigationBarThemeData(
      elevation: 0,
      enableFeedback: false,
      backgroundColor: colorScheme.surface,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      selectedItemColor: colorScheme.primary,
      selectedIconTheme: IconThemeData(size: 18.sp),
      unselectedIconTheme: IconThemeData(size: 16.sp),
      unselectedItemColor: colorScheme.onSurface.withAlpha(
        (0.75 * 255).toInt(),
      ),
      selectedLabelStyle: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: colorScheme.primaryFixedDim,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface.withAlpha((0.75 * 255).toInt()),
      ),
    );
  }

  static InputDecorationTheme _createInputDecorationTheme(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return InputDecorationTheme(
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: colorScheme.surface, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: colorScheme.shadow),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: colorScheme.shadow),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: colorScheme.shadow, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      floatingLabelBehavior: FloatingLabelBehavior.never,
      counterStyle: textTheme.bodyMedium,
      labelStyle: textTheme.titleSmall,
      hintStyle: textTheme.bodyLarge,
      filled: true,
      fillColor: colorScheme.surface,
    );
  }

  static ListTileThemeData _createListTileTheme(ColorScheme colorScheme) {
    return ListTileThemeData(
      titleTextStyle: TextStyle(color: colorScheme.onSurface),
      tileColor: colorScheme.surface,
      iconColor: colorScheme.onSurface,
    );
  }

  static DialogThemeData _createDialogTheme(ColorScheme colorScheme) {
    return DialogThemeData(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.grey,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      actionsPadding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      insetPadding: EdgeInsets.symmetric(horizontal: 8.w),
      titleTextStyle: TextStyle(
        fontFamily: _getFontFamily(),
        fontSize: 14.sp,
        color: colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: TextStyle(
        fontFamily: _getFontFamily(),
        fontSize: 11.sp,
        color: colorScheme.onSurfaceVariant.withAlpha((0.8 * 255).toInt()),
      ),
    );
  }

  static BottomSheetThemeData _createBottomSheetTheme(ColorScheme colorScheme) {
    return BottomSheetThemeData(
      modalBackgroundColor: colorScheme.surface,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surface,
    );
  }

  static DividerThemeData _createDividerTheme(ColorScheme colorScheme) {
    return DividerThemeData(
      color: colorScheme.onSurface.withAlpha((0.4 * 255).toInt()),
      thickness: 0.5,
    );
  }

  static ButtonThemeData _createButtonTheme(ColorScheme colorScheme) {
    return ButtonThemeData(
      textTheme: ButtonTextTheme.primary,
      colorScheme: colorScheme,
      height: 52,
    );
  }

  static SnackBarThemeData _createSnackBarTheme(ColorScheme colorScheme) {
    return SnackBarThemeData(
      backgroundColor: colorScheme.primary,
      contentTextStyle: TextStyle(color: colorScheme.onSurface),
      elevation: 20,
    );
  }

  static DatePickerThemeData _createDatePickerTheme(ColorScheme colorScheme) {
    return DatePickerThemeData(
      dayStyle: TextStyle(fontSize: 10.sp, color: colorScheme.onSurfaceVariant),
      yearStyle: TextStyle(
        fontSize: 10.sp,
        color: colorScheme.onSurfaceVariant,
      ),
      weekdayStyle: TextStyle(
        fontSize: 12.sp,
        color: colorScheme.onSurfaceVariant,
      ),
      headerBackgroundColor: colorScheme.primary,
      inputDecorationTheme: InputDecorationTheme(
        helperStyle: TextStyle(color: colorScheme.onSurface),
        errorStyle: TextStyle(color: colorScheme.onSurface),
        labelStyle: TextStyle(color: colorScheme.onSurface),
      ),
      rangePickerShape: Border.all(color: Colors.transparent),
      headerHelpStyle: TextStyle(
        fontSize: 12.sp,
        color: colorScheme.onSurfaceVariant,
      ),
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surface,
    );
  }

  static _createTextSelectionTheme(ColorScheme colorScheme) {
    return TextSelectionThemeData(cursorColor: colorScheme.onSurfaceVariant);
  }
}
