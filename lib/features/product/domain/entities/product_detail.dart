import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'product_grade.dart';

/// Full product detail returned by `GET /products/{id}`.
class ProductDetail extends Equatable {
  final String id;
  final String brand;
  final String model;
  final int? year;
  final int priceAed;
  final ProductGrade grade;
  final String? storageVariant;
  final String? color;
  final String? description;
  final String? whatIsIncluded;
  final String categoryName;
  final String categorySlug;
  final String emoji;
  final List<Color> imageGradient;

  /// Full hero image URL (catalog stock image) or empty.
  final String heroImageUrl;

  /// Full URLs for inspection images (empty entries filtered out).
  final List<String> inspectionImages;

  final String vendorName;
  final String? vendorAddress;

  const ProductDetail({
    required this.id,
    required this.brand,
    required this.model,
    required this.priceAed,
    required this.grade,
    required this.categoryName,
    required this.categorySlug,
    required this.emoji,
    required this.imageGradient,
    this.year,
    this.storageVariant,
    this.color,
    this.description,
    this.whatIsIncluded,
    this.heroImageUrl = '',
    this.inspectionImages = const [],
    this.vendorName = '',
    this.vendorAddress,
  });

  int get tabbyInstalment => (priceAed / 4).round();

  String get vendorInitials {
    final parts = vendorName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'ZK';
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1)
          .toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  List<Object?> get props => [id];
}
