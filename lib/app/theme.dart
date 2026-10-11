import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF001F1D);
  static const cardBackground = Color(0xFF001513);

  static const primary = Color(0xFF27D9A4);
  static const primaryDark = Color(0xFF18B98A);

  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF9AAEAB);

  static const border = Color(0xFF087D72);
  static const focusBorder = Color(0xFF8B3DFF);

  static const divider = Color(0xFF14534E);
}

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,

    scaffoldBackgroundColor: AppColors.background,

    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.primary,
      surface: AppColors.background,
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.textPrimary),
      bodyMedium: TextStyle(color: AppColors.textPrimary),
      bodySmall: TextStyle(color: AppColors.textSecondary),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.transparent,

      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.border, width: 1),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.focusBorder, width: 2),
      ),

      hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
    ),
  );
}
