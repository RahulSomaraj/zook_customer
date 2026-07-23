import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/category_icons.dart';
import '../../../product/domain/entities/category.dart';

/// Minimum width for a category pill, sized to comfortably fit the "Laptops"
/// label so shorter labels don't render narrower.
const double _kMinPillWidth = 72;

/// Horizontally scrolling category selector.
class CategoryPills extends StatelessWidget {
  final List<ShopCategory> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  const CategoryPills({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          for (var i = 0; i < categories.length; i++) ...[
            _Pill(
              category: categories[i],
              active: i == selectedIndex,
              onTap: () => onSelected(i),
            ),
            if (i != categories.length - 1) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final ShopCategory category;
  final bool active;
  final VoidCallback onTap;
  const _Pill({required this.category, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minWidth: _kMinPillWidth),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.white,
          border: Border.all(
              color: active ? AppColors.primary : AppColors.border, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              categoryIconFor(category.slug ?? category.label),
              size: 20,
              color: active ? AppColors.white : AppColors.mid,
            ),
            const SizedBox(height: 4),
            Text(
              category.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: AppTextStyles.label.copyWith(
                fontSize: 10,
                letterSpacing: 0,
                color: active ? AppColors.white : AppColors.mid,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
