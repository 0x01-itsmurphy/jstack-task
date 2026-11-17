import 'package:flutter/material.dart';

abstract final class AppTextTheme {
  static const TextTheme textTheme = TextTheme(
    displaySmall: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
    headlineMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
    headlineSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
    titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(fontSize: 16),
    bodyMedium: TextStyle(fontSize: 14),
    bodySmall: TextStyle(fontSize: 12),
    labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
  );
}
