import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppColorScheme {
  static final ColorScheme light = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    surface: AppColors.lightSurface,
    error: AppColors.error,
  );

  static final ColorScheme dark = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.dark,
    secondary: AppColors.secondary,
    surface: AppColors.darkSurface,
    error: AppColors.error,
  );
}
