import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_grade.dart';

/// Grid-style product card used on Home and Category screens.
///
/// Mirrors the "browse" mockup: a verified strip and a corner grade tab sit
/// over the image, with a Tabby instalment line beneath the price.
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onWishlistTap;

  /// Overrides [product.imageGradient] when set (e.g. list/grid index cycle).
  final List<Color>? imageGradient;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onWishlistTap,
    this.imageGradient,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(18),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Stack(
                children: [
                  Positioned.fill(child: _image()),
                  if (product.isVerified)
                    const Positioned(
                      left: 8,
                      bottom: 7,
                      child: _VerifiedStrip(),
                    ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: _GradeTab(grade: product.grade),
                  ),
                ],
              ),
            ),
            // Body
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.brand.toUpperCase(),
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 9,
                      color: AppColors.light,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'AED ',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 10,
                            color: AppColors.mid,
                          ),
                        ),
                        TextSpan(
                          text: formatAmount(product.priceAed),
                          style: AppTextStyles.title.copyWith(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  _TabbyLine(monthly: product.tabbyInstalment),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _image() {
    final gradient = imageGradient ?? product.imageGradient;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
      ),
      child: product.imageUrl.isEmpty
          ? Center(
              child:
                  Text(product.emoji, style: const TextStyle(fontSize: 36)))
          : Image.network(
              product.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Center(
                child:
                    Text(product.emoji, style: const TextStyle(fontSize: 36)),
              ),
              loadingBuilder: (context, child, progress) => progress == null
                  ? child
                  : Center(
                      child: Text(product.emoji,
                          style: const TextStyle(fontSize: 36)),
                    ),
            ),
    );
  }
}

/// "✓ Verified" strip anchored bottom-left over the product image.
class _VerifiedStrip extends StatelessWidget {
  const _VerifiedStrip();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.verified, size: 13, color: Color(0xFF1D9BF0)),
        const SizedBox(width: 3),
        Text(
          'Verified',
          style: AppTextStyles.caption.copyWith(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF334B3A),
          ),
        ),
      ],
    );
  }
}

/// White corner tab showing the grade, e.g. "B · GOOD" with a coloured rule
/// sitting a couple of pixels below the text (matches the browse mockup).
class _GradeTab extends StatelessWidget {
  final ProductGrade grade;
  const _GradeTab({required this.grade});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(10)),
      ),
      child: Container(
        padding: const EdgeInsets.only(bottom: 3),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: grade.color, width: 2),
          ),
        ),
        child: Text(
          '${grade.label} · ${grade.shortLabel.toUpperCase()}',
          style: AppTextStyles.caption.copyWith(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: AppColors.black,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}

/// Tabby "pay in 4" instalment line, e.g. "tabby  As low as AED 212/mo".
class _TabbyLine extends StatelessWidget {
  final int monthly;
  const _TabbyLine({required this.monthly});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
          decoration: BoxDecoration(
            color: const Color(0xFF3EEDBF),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'tabby',
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F1F1A),
              letterSpacing: -0.2,
            ),
          ),
        ),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            'As low as AED $monthly/mo',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              fontSize: 9,
              color: AppColors.mid,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
