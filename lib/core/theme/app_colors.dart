import 'package:flutter/material.dart';

/// Central color palette for the Zook app.
/// Mirrors the design tokens from the onboarding mockup.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFFFF4500);
  static const Color primaryDark = Color(0xFFCC3700);
  static const Color primaryLight = Color(0xFFFF6B35);
  static const Color primaryPale = Color(0xFFFFF0EB);

  // Neutrals
  static const Color black = Color(0xFF0A0A0A);
  static const Color charcoal = Color(0xFF333333);
  static const Color mid = Color(0xFF666666);
  static const Color light = Color(0xFF999999);
  static const Color border = Color(0xFFEBEBEB);
  static const Color surface = Color(0xFFF7F7F5);
  static const Color white = Color(0xFFFFFFFF);

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color successPale = Color(0xFFF0FDF4);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Onboarding illustration gradients
  static const List<Color> circleOrange = [Color(0xFFFFF0EB), Color(0xFFFFD4C2)];
  static const List<Color> circleGreen = [Color(0xFFF0FDF4), Color(0xFFBBF7D0)];
  static const List<Color> circleBlue = [Color(0xFFEFF6FF), Color(0xFFBFDBFE)];

  /// Product card image-area gradients.
  /// Ordered so consecutive (and every-other for 2-col grids) are distant hues.
  static const List<List<Color>> productImageGradients = [
    [Color(0xFFFFF0EB), Color(0xFFFFD4C2)], // orange
    [Color(0xFFEFF6FF), Color(0xFFBFDBFE)], // blue
    [Color(0xFFFFFBEB), Color(0xFFFDE68A)], // yellow
    [Color(0xFFF5F3FF), Color(0xFFDDD6FE)], // purple
    [Color(0xFFF0FDF4), Color(0xFFBBF7D0)], // green
    [Color(0xFFFDF4FF), Color(0xFFF0ABFC)], // magenta
  ];

  /// Cycles through [productImageGradients]; repeats only after a full pass.
  static List<Color> productGradientAt(int index) {
    final palette = productImageGradients;
    return palette[index % palette.length];
  }
}
