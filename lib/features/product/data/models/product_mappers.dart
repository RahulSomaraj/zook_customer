import 'package:flutter/material.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/product_grade.dart';

/// Shared mapping helpers used by product/detail models.
class ProductMappers {
  ProductMappers._();

  static ProductGrade grade(String value) {
    switch (value.toLowerCase()) {
      case 'like_new':
      case 'likenew':
        return ProductGrade.a;
      case 'fair':
        return ProductGrade.c;
      case 'good':
      default:
        return ProductGrade.b;
    }
  }

  static int price(dynamic raw) =>
      (double.tryParse(raw?.toString() ?? '') ?? 0).round();

  /// Builds a full image URL from a stored key. Full URLs pass through.
  static String imageUrl(String? value) {
    if (value == null || value.isEmpty) return '';
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    if (ApiConstants.mediaBaseUrl.isEmpty) return '';
    final key =
        trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;
    return '${ApiConstants.mediaBaseUrl}/$key';
  }

  static String emojiForSlug(String slug) {
    switch (slug) {
      case 'smartphones':
      case 'ipods':
      case 'tablets':
        return '📱';
      case 'laptops':
        return '💻';
      case 'gaming':
        return '🎮';
      case 'cameras':
        return '📷';
      case 'audio':
        return '🎧';
      case 'wearables':
        return '⌚';
      default:
        return '📦';
    }
  }

  /// Gradient for list/grid position [index]. Full palette before repeat.
  static List<Color> gradientAt(int index) =>
      AppColors.productGradientAt(index);

  /// Stable gradient for a product id (detail, cart, etc.).
  static List<Color> gradientFor(String id) {
    final n = AppColors.productImageGradients.length;
    return AppColors.productGradientAt(id.hashCode.abs() % n);
  }
}
