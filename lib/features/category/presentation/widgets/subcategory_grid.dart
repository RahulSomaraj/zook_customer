import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/category_icons.dart';
import '../../../product/domain/entities/category.dart';

/// 2-column grid of sub-category chips.
class SubCategoryGrid extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  const SubCategoryGrid({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: kSubCategories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          mainAxisExtent: 44,
        ),
        itemBuilder: (context, i) {
          final cat = kSubCategories[i];
          final active = i == selectedIndex;
          return GestureDetector(
            onTap: () => onSelected(i),
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
