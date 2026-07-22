import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../product/presentation/widgets/grade_badge.dart';
import '../../domain/entities/cart_item.dart';

class CartItemTile extends StatelessWidget {
  final CartItem item;
  final VoidCallback onRemove;
  const CartItemTile({super.key, required this.item, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final p = item.product;
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 72,
            height: 72,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: p.imageGradient),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            alignment: Alignment.center,
            child: p.imageUrl.isEmpty
                ? Text(p.emoji, style: const TextStyle(fontSize: 32))
                : Image.network(
                    p.imageUrl,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Text(p.emoji, style: const TextStyle(fontSize: 32)),
                    loadingBuilder: (context, child, progress) =>
                        progress == null
                            ? child
                            : Text(p.emoji,
                                style: const TextStyle(fontSize: 32)),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.brand.toUpperCase(),
                    style: AppTextStyles.caption.copyWith(
                        fontSize: 10,
                        color: AppColors.light,
                        letterSpacing: 0.5)),
                const SizedBox(height: 2),
                Text(p.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    GradeBadge(grade: p.grade, size: 18),
                    const SizedBox(width: 4),
                    Text(p.grade.description,
                        style: AppTextStyles.caption.copyWith(
                            fontSize: 11, color: AppColors.mid)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('AED ${formatAmount(p.priceAed)}',
                        style: AppTextStyles.title.copyWith(fontSize: 16)),
                    GestureDetector(
                      onTap: onRemove,
                      child: Text('Remove',
                          style: AppTextStyles.label.copyWith(
                              fontSize: 11,
                              letterSpacing: 0,
                              color: AppColors.light)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
