import 'package:flutter/material.dart';

class AppColors {
  // Main backgrounds
  static const background = Color(0xFFFDF4EC);
  static const cardBackground = Color(0xFFFFFFFF);
  static const card = Color(0xFFFFFFFF);

  // Brand colours
  static const primary = Color(0xFFFDA57D);
  static const primaryDark = Color(0xFFFC8F68);
  static const tealDark = Color(0xFF151215); // Legacy name

  // Additional peach shades
  static const peachLight = Color(0xFFFDC2A2);
  static const peachPale = Color(0xFFFCE1D0);

  // Text
  static const textPrimary = Color(0xFF151215);
  static const textSecondary = Color(0xFF5E4547);
  static const pureWhite = Color(0xFFFFFFFF);

  // Borders and accents
  static const border = Color(0xFFEBC0AE);
  static const focusBorder = Color(0xFFFC8F68);
  static const divider = Color(0xFFFDC2A2);

  // Glassmorphism
  static const glass = Color(0xCCFFFFFF);
  static const glassBorder = Color(0x99FDC2A2);

  // Player accents
  static const playerGradientStart = Color(0xFFFC8F68);
  static const playerGradientEnd = Color(0xFFFDA57D);

  // Dark surfaces
static const charcoal = Color(0xFF282328);
static const charcoalLight = Color(0xFF413438);
}

class AppGradients {
  // General card gradient
  static const card = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFFCE1D0)],
  );

  // Peach gradient for primary buttons
  static const peach = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary, AppColors.primaryDark],
  );

  // Light premium background
  static const dark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFDF4EC), Color(0xFFFCE1D0)],
  );

  // Light glass-style surface
  static const glass = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xEEFFFFFF), Color(0xBBFCE1D0)],
  );
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,

    scaffoldBackgroundColor: AppColors.background,

    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.primaryDark,
      surface: AppColors.cardBackground,
      tertiary: AppColors.peachLight,
      onPrimary: AppColors.textPrimary,
      onSecondary: AppColors.textPrimary,
      onSurface: AppColors.textPrimary,
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.textPrimary),
      bodyMedium: TextStyle(color: AppColors.textPrimary),
      bodySmall: TextStyle(color: AppColors.textSecondary),
      titleLarge: TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: false,
    ),

    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 2,
      shadowColor: Color(0x22A36D58),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border, width: 0.7),
      ),
    ),

    iconTheme: const IconThemeData(color: AppColors.primaryDark),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.cardBackground,

      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border, width: 1),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.focusBorder, width: 1.5),
      ),

      hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),

      labelStyle: const TextStyle(color: AppColors.textSecondary),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textPrimary,
        elevation: 1,

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      ),
    ),

    dividerColor: AppColors.divider,

    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.card,
      contentTextStyle: TextStyle(color: AppColors.textPrimary),
    ),

    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primaryDark,
    ),
  );
}
