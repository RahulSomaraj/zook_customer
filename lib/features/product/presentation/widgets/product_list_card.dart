import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/product.dart';
import 'grade_badge.dart';

/// Horizontal list-row card used on the Search screen.
class ProductListCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onWishlistTap;

  /// Overrides [product.imageGradient] when set (e.g. list index cycle).
  final List<Color>? imageGradient;

  const ProductListCard({
    super.key,
    required this.product,
    this.onTap,
    this.onWishlistTap,
    this.imageGradient,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Container(
              width: 80,
              height: 80,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: imageGradient ?? product.imageGradient,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              alignment: Alignment.center,
              child: product.imageUrl.isEmpty
                  ? Text(product.emoji, style: const TextStyle(fontSize: 36))
                  : Image.network(
                      product.imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Text(product.emoji,
                          style: const TextStyle(fontSize: 36)),
                      loadingBuilder: (context, child, progress) =>
                          progress == null
                              ? child
                              : Text(product.emoji,
                                  style: const TextStyle(fontSize: 36)),
                    ),
            ),
            const SizedBox(width: 12),
            // Body
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.brand.toUpperCase(),
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 10,
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
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      GradeBadge(grade: product.grade, size: 18),
                      const SizedBox(width: 5),
                      Text(product.grade.description,
                          style: AppTextStyles.caption.copyWith(
                              fontSize: 11, color: AppColors.mid)),
                      const Spacer(),
                      if (product.isVerified)
                        Container(
                          padding: const EdgeInsets.fromLTRB(6, 2, 8, 2),
                          decoration: BoxDecoration(
                            color: AppColors.successPale,
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.verified,
                                  size: 11, color: Color(0xFF15803D)),
                              const SizedBox(width: 3),
                              Text(
                                'Verified',
                                style: AppTextStyles.caption.copyWith(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF15803D),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'AED ',
                              style: AppTextStyles.caption.copyWith(
                                  fontSize: 11, color: AppColors.mid),
                            ),
                            TextSpan(
                              text: formatAmount(product.priceAed),
                              style: AppTextStyles.title.copyWith(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      if (product.store != null)
                        Flexible(
                          child: Text(
                            product.store!,
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption.copyWith(
                                fontSize: 10, color: AppColors.light),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (onWishlistTap != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onWishlistTap,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.only(top: 2, left: 4),
                  child: Icon(
                    product.isWishlisted
                        ? Icons.favorite
                        : Icons.favorite_border,
                    size: 20,
                    color: product.isWishlisted
                        ? AppColors.primary
                        : AppColors.light,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
