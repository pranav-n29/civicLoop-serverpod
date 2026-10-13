import 'package:flutter/material.dart';

abstract final class CivicColors {
  static const navy = Color(0xFF10213A);
  static const blue = Color(0xFF2563EB);
  static const background = Color(0xFFF5F7FB);
  static const card = Colors.white;
  static const secondaryText = Color(0xFF64748B);
  static const border = Color(0xFFE2E8F0);
  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFD97706);
  static const critical = Color(0xFFDC2626);
  static const blueTint = Color(0xFFDBEAFE);
  static const successTint = Color(0xFFDCFCE7);
  static const warningTint = Color(0xFFFEF3C7);
  static const criticalTint = Color(0xFFFEE2E2);
}

abstract final class CivicSpacing {
  static const page = 22.0;
  static const section = 20.0;
  static const card = 16.0;
  static const compact = 12.0;
  static const control = 52.0;
}

abstract final class CivicRadii {
  static const card = 16.0;
  static const control = 14.0;
  static const pill = 24.0;
}

abstract final class CivicTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: CivicColors.blue,
      brightness: Brightness.light,
    ).copyWith(
      primary: CivicColors.blue,
      onPrimary: Colors.white,
      secondary: CivicColors.navy,
      onSecondary: Colors.white,
      surface: CivicColors.card,
      onSurface: CivicColors.navy,
      outline: CivicColors.border,
      error: CivicColors.critical,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: CivicColors.background,
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          color: CivicColors.navy,
          fontSize: 30,
          fontWeight: FontWeight.w800,
          height: 1.1,
        ),
        headlineSmall: TextStyle(
          color: CivicColors.navy,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          height: 1.15,
        ),
        titleLarge: TextStyle(
          color: CivicColors.navy,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
        titleMedium: TextStyle(
          color: CivicColors.navy,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(
          color: CivicColors.navy,
          fontSize: 15,
          height: 1.45,
        ),
        bodyMedium: TextStyle(
          color: CivicColors.secondaryText,
          fontSize: 13,
          height: 1.45,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: CivicColors.background,
        foregroundColor: CivicColors.navy,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: CivicColors.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CivicRadii.card),
          side: const BorderSide(color: CivicColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CivicColors.card,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CivicRadii.control),
          borderSide: const BorderSide(color: CivicColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CivicRadii.control),
          borderSide: const BorderSide(color: CivicColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CivicRadii.control),
          borderSide: const BorderSide(color: CivicColors.blue, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: CivicColors.blue,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(CivicSpacing.control),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CivicRadii.control),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: CivicColors.navy,
          minimumSize: const Size.fromHeight(CivicSpacing.control),
          side: const BorderSide(color: CivicColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CivicRadii.control),
          ),
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: CivicColors.card,
        indicatorColor: CivicColors.blueTint,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CivicRadii.control),
        ),
      ),
    );
  }
}
