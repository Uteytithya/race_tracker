import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData appTheme = ThemeData(
  fontFamily: GoogleFonts.montserrat().fontFamily,
  primaryColor: AppColors.primary500,
  scaffoldBackgroundColor: AppColors.secondary,
  colorScheme: ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary500,
    onPrimary: AppColors.secondary,
    secondary: AppColors.primary400,
    onSecondary: AppColors.secondary,
    error: AppColors.danger,
    onError: AppColors.secondary,
    surface: AppColors.primary600,
    onSurface: Colors.white,
  ),
  textTheme: TextTheme(
    headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700), // Heading
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400), // Body
    displayLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600), // Data Display
    labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500), // Button
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400), // Caption
    labelSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500), // Overline
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Medium Radius
      ),
    ),
  ),
  tabBarTheme: TabBarThemeData(
    labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    unselectedLabelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
  ),
  
);

class AppSpacing {
  static const double small = 12.0;
  static const double medium = 16.0;
  static const double large = 24.0;
  static const double xl = 32.0;
  static const double xxl = 40.0;
}

class AppRadius {
  static const BorderRadius medium = BorderRadius.all(Radius.circular(16.0));
  static const BorderRadius large = BorderRadius.all(Radius.circular(24.0));
}

class AppColors {
  static const Color primary800 = Color(0xFF2B3587);
  static const Color primary600 = Color(0xFF4758E0);
  static const Color primary500 = Color(0xFF4E61F6);
  static const Color primary400 = Color(0xFF7181F8);

  static const Color secondary = Color(0xFFFFFFFF);
  static const Color danger = Color(0xFFEE443F);
}