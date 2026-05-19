import 'package:flutter/material.dart';

class AppColors {
  static const teal900 = Color(0xFF003C3A);
  static const teal800 = Color(0xFF005B56);
  static const teal700 = Color(0xFF006D67);
  static const teal600 = Color(0xFF00857D);
  static const teal50 = Color(0xFFEAF7F4);
  static const mint50 = Color(0xFFF5FBF9);
  static const border = Color(0xFFD5E6E2);
}

ThemeData buildAppTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.teal700,
    brightness: Brightness.light,
  ).copyWith(
    primary: AppColors.teal700,
    secondary: AppColors.teal600,
    surface: Colors.white,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.mint50,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.teal700,
      foregroundColor: Colors.white,
      centerTitle: false,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.teal700,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.teal700,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.teal700,
        side: const BorderSide(color: AppColors.teal700),
        minimumSize: const Size.fromHeight(46),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.teal700,
      foregroundColor: Colors.white,
      extendedTextStyle: TextStyle(fontWeight: FontWeight.w700),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      labelStyle: const TextStyle(color: AppColors.teal800),
      floatingLabelStyle: const TextStyle(color: AppColors.teal700, fontWeight: FontWeight.w700),
      prefixIconColor: AppColors.teal700,
      suffixIconColor: AppColors.teal700,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.teal700, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.teal50,
      selectedColor: AppColors.teal700,
      labelStyle: const TextStyle(color: AppColors.teal800, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      side: const BorderSide(color: AppColors.border),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.teal900,
      contentTextStyle: TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
    ),
    dividerTheme: const DividerThemeData(color: AppColors.border),
    listTileTheme: const ListTileThemeData(
      iconColor: AppColors.teal700,
      textColor: Color(0xFF163B38),
      titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF163B38)),
      subtitleTextStyle: TextStyle(fontSize: 14, height: 1.35, color: Color(0xFF607D78)),
    ),
  );
}
