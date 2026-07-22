import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/product.dart';
import 'product_card.dart';

/// A 2-column layout of [ProductCard]s. Each card hugs its own content; the two
/// cards in a row share the taller height. Non-scrolling — meant to live inside
/// an outer scroll view.
class ProductGrid extends StatelessWidget {
  final List<Product> products;
  final EdgeInsets padding;
  final double spacing;
  final void Function(Product)? onTap;
  final void Function(Product)? onWishlistTap;

  const ProductGrid({
    super.key,
    required this.products,
    this.padding = const EdgeInsets.fromLTRB(16, 0, 16, 16),
    this.spacing = 10,
    this.onTap,
    this.onWishlistTap,
  });

  Widget _card(Product p, int index) => ProductCard(
        product: p,
        imageGradient: AppColors.productGradientAt(index),
        onTap: onTap == null ? null : () => onTap!(p),
        onWishlistTap: onWishlistTap == null ? null : () => onWishlistTap!(p),
      );

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < products.length; i += 2) {
      final hasRight = i + 1 < products.length;
      rows.add(
        Padding(
          padding: EdgeInsets.only(bottom: spacing),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _card(products[i], i)),
              SizedBox(width: spacing),
              Expanded(
                child: hasRight
                    ? _card(products[i + 1], i + 1)
                    : const SizedBox(),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rows,
      ),
    );
  }
}
