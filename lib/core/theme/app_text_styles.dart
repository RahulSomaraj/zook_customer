import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Typography for the app.
/// Brand wordmark uses Montserrat (900); UI text uses Manrope for English and
/// Cairo for Arabic (Manrope has no Arabic glyphs).
class AppTextStyles {
  AppTextStyles._();

  /// Set by LocaleCubit alongside AppStrings.load(). The app rebuilds from the
  /// root on locale change, so every style read picks the right font family.
  static bool arabic = false;

  /// Locale-appropriate UI font.
  static TextStyle _ui({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) =>
      arabic
          ? GoogleFonts.cairo(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: color,
              // Arabic script needs no Latin-style tracking.
              letterSpacing: 0,
              height: height,
            )
          : GoogleFonts.manrope(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: color,
              letterSpacing: letterSpacing,
              height: height,
            );

  static TextStyle brand({double size = 56, Color color = AppColors.primary}) =>
      GoogleFonts.montserrat(
        fontSize: size,
        fontWeight: FontWeight.w900,
        color: color,
        letterSpacing: -2,
        height: 1,
      );

  static TextStyle get heading => _ui(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: AppColors.black,
        letterSpacing: -0.5,
        height: 1.2,
      );

  static TextStyle get title => _ui(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: AppColors.black,
      );

  static TextStyle get subtitle => _ui(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.mid,
        height: 1.65,
      );

  static TextStyle get body => _ui(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.charcoal,
      );

  static TextStyle get label => _ui(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.charcoal,
        letterSpacing: 0.05 * 12,
      );

  static TextStyle get button => _ui(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: AppColors.white,
      );

  static TextStyle get caption => _ui(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.light,
      );
}
