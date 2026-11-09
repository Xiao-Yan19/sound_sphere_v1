import 'package:flutter/material.dart';

class AppColors {
  // Main backgrounds
  static const background = Color(0xFF191919);
  static const cardBackground = Color(0xFF242424);
  static const card = Color(0xFF303030);

  // Brand colours
  static const primary = Color(0xFF91EBD5);
  static const primaryDark = Color(0xFF419B8C);
  static const tealDark = Color(0xFF183B38);

  // Text
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFBDBDBD);

  // Borders and accents
  static const border = Color(0xFF419B8C);
  static const focusBorder = Color(0xFF8B3DFF);
  static const divider = Color(0xFF354A46);
}

/// The grey card gradient used by Home's song rows.
/// Login, Register and Profile reuse it so everything matches.
class AppGradients {
  static const card = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.card, AppColors.cardBackground],
  );
}

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,

    scaffoldBackgroundColor: AppColors.background,

    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.primaryDark,
      surface: AppColors.cardBackground,
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.textPrimary),
      bodyMedium: TextStyle(color: AppColors.textPrimary),
      bodySmall: TextStyle(color: AppColors.textSecondary),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
    ),

    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    iconTheme: const IconThemeData(
      color: AppColors.primary,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.cardBackground,

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 15,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: AppColors.border,
          width: 1,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: AppColors.focusBorder,
          width: 2,
        ),
      ),

      hintStyle: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 13,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7),
        ),
      ),
    ),

    dividerColor: AppColors.divider,
  );
}