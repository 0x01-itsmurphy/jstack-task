import 'package:flutter/material.dart';

import 'app_color_scheme.dart';
import 'app_colors.dart';
import 'app_text_theme.dart';

abstract final class AppTheme {
  static ThemeData light() =>
      _build(AppColorScheme.light, AppColors.lightBackground);

  static ThemeData dark() =>
      _build(AppColorScheme.dark, AppColors.darkBackground);

  static ThemeData _build(ColorScheme colors, Color background) {
    final radius = BorderRadius.circular(14);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      textTheme: AppTextTheme.textTheme,
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: background,
        foregroundColor: colors.onSurface,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: radius),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(borderRadius: radius),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: colors.outlineVariant),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
