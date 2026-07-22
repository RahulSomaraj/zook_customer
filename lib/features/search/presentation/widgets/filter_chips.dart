import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Horizontal scrolling category filter chips on the Search screen.
class FilterChips extends StatelessWidget {
  final List<String> labels;
  final int activeIndex;
  final ValueChanged<int> onSelected;
  const FilterChips({
    super.key,
    required this.labels,
    required this.activeIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (labels.length <= 1) return const SizedBox.shrink();
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            for (var i = 0; i < labels.length; i++) ...[
              _Chip(
                label: labels[i],
                active: i == activeIndex,
                onTap: () => onSelected(i),
              ),
              if (i != labels.length - 1) const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _Chip({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.white,
          border: Border.all(
              color: active ? AppColors.primary : AppColors.border, width: 1.5),
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Text(
          label,
          style: AppTextStyles.label.copyWith(
            fontSize: 12,
            letterSpacing: 0,
            color: active ? AppColors.white : AppColors.mid,
          ),
        ),
      ),
    );
  }
}
