import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF080A10);
  static const backgroundAlt = Color(0xFF0D1018);
  static const backgroundAlt2 = Color(0xFF0D1422);
  static const surface = Color(0xFF121620);
  static const surfaceAlt = Color(0xFF181D28);
  static const surfaceMuted = Color(0xFF10141D);
  static const border = Color(0x1FFFFFFF);
  static const borderStrong = Color(0x2FFFFFFF);
  static const lime = Color(0xFFC8FF00);
  static const limeDim = Color(0x1AC8FF00);
  static const limeGlow = Color(0x40C8FF00);
  static const cyan = Color(0xFF00E5FF);
  static const cyanDim = Color(0x1A00E5FF);
  static const amber = Color(0xFFFFB300);
  static const amberDim = Color(0x1AFFB300);
  static const rose = Color(0xFFFF3D71);
  static const roseDim = Color(0x1AFF3D71);
  static const violet = Color(0xFF9B59FF);
  static const violetDim = Color(0x1A9B59FF);
  static const textPrimary = Color(0xFFEEF1FB);
  static const textSecondary = Color(0xFF8A90AA);
  static const textTertiary = Color(0xFF4A5068);
}

class AppTheme {
  static ThemeData get darkTheme {
    const colorScheme = ColorScheme.dark(
      primary: AppColors.lime,
      secondary: AppColors.cyan,
      surface: AppColors.surface,
      error: AppColors.rose,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      cardColor: AppColors.surface,
      dividerColor: AppColors.border,
      splashFactory: NoSplash.splashFactory,
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
          height: 1,
        ),
        headlineMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
          height: 1,
        ),
        titleLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
        titleMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
        bodyLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          height: 1.4,
        ),
        bodyMedium: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          height: 1.4,
        ),
        bodySmall: TextStyle(
          color: AppColors.textTertiary,
          fontSize: 11,
          height: 1.3,
          letterSpacing: 0.5,
        ),
        labelLarge: TextStyle(
          color: Colors.black,
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
        ),
        labelMedium: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.border),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.lime,
          foregroundColor: Colors.black,
          disabledBackgroundColor: AppColors.surfaceAlt,
          disabledForegroundColor: AppColors.textTertiary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.borderStrong),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceAlt,
        contentTextStyle: const TextStyle(color: AppColors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        behavior: SnackBarBehavior.floating,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.limeDim,
        labelTextStyle: const MaterialStatePropertyAll(
          TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
        hintStyle: const TextStyle(
          color: AppColors.textTertiary,
          fontSize: 13,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.lime),
        ),
      ),
    );
  }
}
