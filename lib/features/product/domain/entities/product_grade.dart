import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Condition grade assigned to a verified secondhand item.
enum ProductGrade {
  a('A', 'Like new', AppColors.success, AppColors.successPale, Color(0xFF15803D)),
  b('B', 'Good condition', AppColors.warning, Color(0xFFFFFBEB), Color(0xFF92400E)),
  c('C', 'Fair condition', Color(0xFF94A3B8), Color(0xFFF1F5F9), Color(0xFF475569));

  const ProductGrade(
    this.label,
    this.description,
    this.color,
    this.paleColor,
    this.textColor,
  );

  final String label;
  final String description;
  final Color color;
  final Color paleColor;
  final Color textColor;

  /// Compact label for the on-image grade tab, e.g. "GOOD", "LIKE NEW".
  String get shortLabel {
    switch (this) {
      case ProductGrade.a:
        return 'Like New';
      case ProductGrade.b:
        return 'Good';
      case ProductGrade.c:
        return 'Fair';
    }
  }
}
