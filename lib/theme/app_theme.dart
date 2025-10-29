import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(backgroundColor: AppColors.background, elevation: 0),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: AppColors.accent),
  );
}
