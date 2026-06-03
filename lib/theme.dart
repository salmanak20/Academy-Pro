import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF001A4D);
  static const Color primaryContainer = Color(0xFF0A2E73);
  static const Color onPrimary = Colors.white;
  static const Color secondary = Color(0xFF765A00);
  static const Color secondaryContainer = Color(0xFFFFCE4B);
  static const Color onSecondaryContainer = Color(0xFF735800);
  static const Color background = Color(0xFFF7FAFE);
  static const Color surface = Color(0xFFF7FAFE);
  static const Color onSurface = Color(0xFF181C1F);
  static const Color onSurfaceVariant = Color(0xFF444651);
  static const Color outline = Color(0xFF747682);
  static const Color outlineVariant = Color(0xFFC4C6D2);
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color surfaceContainerHighest = Color(0xFFE0E3E7);
  static const Color surfaceContainerHigh = Color(0xFFE5E8EC);
  static const Color primaryFixed = Color(0xFFDAE2FF);
  static const Color secondaryFixed = Color(0xFFFFDF95);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
        error: AppColors.error,
        errorContainer: AppColors.errorContainer,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.02 * 48,
          color: AppColors.primary,
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
        bodyLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: AppColors.onSurface,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.onSurface,
        ),
        labelMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.05 * 14,
          color: AppColors.onSurface,
        ),
      ),
    );
  }
}
