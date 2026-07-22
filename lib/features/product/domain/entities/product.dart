import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'product_grade.dart';

/// A marketplace listing.
class Product extends Equatable {
  final String id;
  final String brand;
  final String name;
  final int priceAed;
  final ProductGrade grade;
  final String emoji;
  final List<Color> imageGradient;
  final bool isVerified;
  final bool isNew;
  final bool isWishlisted;
  final String? store;
  final String categoryId;

  /// Full network image URL. Empty when no remote image (falls back to emoji).
  final String imageUrl;

  // ── Detail-screen fields (optional) ──
  final int? year;
  final String? conditionNote;
  final String? sellerInitials;
  final String? sellerMeta;
  final int? batteryHealthPct;

  const Product({
    required this.id,
    required this.brand,
    required this.name,
    required this.priceAed,
    required this.grade,
    required this.emoji,
    required this.imageGradient,
    this.isVerified = true,
    this.isNew = false,
    this.isWishlisted = false,
    this.store,
    this.categoryId = 'electronics',
    this.imageUrl = '',
    this.year,
    this.conditionNote,
    this.sellerInitials,
    this.sellerMeta,
    this.batteryHealthPct,
  });

  /// Tabby "pay in 4" monthly instalment (rounded).
  int get tabbyInstalment => (priceAed / 4).round();

  Product copyWith({bool? isWishlisted}) => Product(
        id: id,
        brand: brand,
        name: name,
        priceAed: priceAed,
        grade: grade,
        emoji: emoji,
        imageGradient: imageGradient,
        isVerified: isVerified,
        isNew: isNew,
        isWishlisted: isWishlisted ?? this.isWishlisted,
        store: store,
        categoryId: categoryId,
        imageUrl: imageUrl,
        year: year,
        conditionNote: conditionNote,
        sellerInitials: sellerInitials,
        sellerMeta: sellerMeta,
        batteryHealthPct: batteryHealthPct,
      );

  @override
  List<Object?> get props => [id];
}
