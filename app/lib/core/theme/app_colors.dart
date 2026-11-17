import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color primary = Color(0xFF4F46E5);
  static const Color secondary = Color(0xFF0EA5E9);

  static const Color lightBackground = Color(0xFFF7F8FC);
  static const Color lightSurface = Colors.white;
  static const Color darkBackground = Color(0xFF0F1117);
  static const Color darkSurface = Color(0xFF1A1D27);

  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);

  static const Color credit = success;
  static const Color debit = error;

  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey700 = Color(0xFF374151);
}
