import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Typography for the app.
/// Brand wordmark uses Montserrat (900); everything else uses Manrope.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle brand({double size = 56, Color color = AppColors.primary}) =>
      GoogleFonts.montserrat(
        fontSize: size,
        fontWeight: FontWeight.w900,
        color: color,
        letterSpacing: -2,
        height: 1,
      );

  static TextStyle get heading => GoogleFonts.manrope(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: AppColors.black,
        letterSpacing: -0.5,
        height: 1.2,
      );

  static TextStyle get title => GoogleFonts.manrope(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: AppColors.black,
      );

  static TextStyle get subtitle => GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.mid,
        height: 1.65,
      );

  static TextStyle get body => GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.charcoal,
      );

  static TextStyle get label => GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.charcoal,
        letterSpacing: 0.05 * 12,
      );

  static TextStyle get button => GoogleFonts.manrope(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: AppColors.white,
      );

  static TextStyle get caption => GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.light,
      );
}
