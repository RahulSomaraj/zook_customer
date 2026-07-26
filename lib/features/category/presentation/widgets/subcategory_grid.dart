import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/category_icons.dart';
import '../../../product/domain/entities/category.dart';

/// 2-column grid of category blocks (original category-page design), populated
/// with the shared category list and highlighting the selected one.
class SubCategoryGrid extends StatelessWidget {
  final List<ShopCategory> categories;
  final String selectedId;
  final ValueChanged<ShopCategory> onSelected;
  const SubCategoryGrid({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: categories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          mainAxisExtent: 44,
        ),
        itemBuilder: (context, i) {
          final cat = categories[i];
          final active = cat.id == selectedId;
          return GestureDetector(
            onTap: () => onSelected(cat),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: active ? AppColors.primaryPale : AppColors.white,
                border: Border.all(
                    color: active ? AppColors.primary : AppColors.border,
                    width: 1.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    categoryIconFor(cat.slug ?? cat.label),
                    size: 18,
                    color: active ? AppColors.primary : AppColors.charcoal,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      cat.label,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.label.copyWith(
                        fontSize: 12,
                        letterSpacing: 0,
                        color: active ? AppColors.primary : AppColors.mid,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
