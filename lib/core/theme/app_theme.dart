import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Builds the global [ThemeData] for the app.
class AppTheme {
  AppTheme._();

  static ThemeData get light => build(arabic: false);

  /// Theme with a locale-appropriate default font (Manrope / Cairo).
  static ThemeData build({required bool arabic}) {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.white,
      primaryColor: AppColors.primary,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.primary,
        secondary: AppColors.primaryLight,
        surface: AppColors.white,
        error: Colors.red,
      ),
      textTheme: arabic
          ? GoogleFonts.cairoTextTheme(base.textTheme)
          : GoogleFonts.manropeTextTheme(base.textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        elevation: 0,
        foregroundColor: AppColors.black,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: _outline(AppColors.border),
        enabledBorder: _outline(AppColors.border),
        focusedBorder: _outline(AppColors.primary, width: 1.5),
        hintStyle: const TextStyle(color: AppColors.light),
      ),
    );
  }

  static OutlineInputBorder _outline(Color color, {double width = 1.5}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );
}
