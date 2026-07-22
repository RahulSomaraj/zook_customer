import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../product/domain/entities/product_grade.dart';
import '../../../product/presentation/widgets/grade_badge.dart';
import '../cubit/category_cubit.dart';

/// Row of grade filter pills (All / A / B / C).
class GradeFilterRow extends StatelessWidget {
  final GradeFilter selected;
  final ValueChanged<GradeFilter> onSelected;
  const GradeFilterRow({super.key, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Text('Grade:',
              style: AppTextStyles.label
                  .copyWith(fontSize: 12, letterSpacing: 0, color: AppColors.mid)),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _option('All',
                      onTap: () => onSelected(GradeFilter.all),
                      selected: selected == GradeFilter.all),
                  const SizedBox(width: 8),
                  _gradeOption(ProductGrade.a, 'Like New', GradeFilter.a),
                  const SizedBox(width: 8),
                  _gradeOption(ProductGrade.b, 'Good', GradeFilter.b),
                  const SizedBox(width: 8),
                  _gradeOption(ProductGrade.c, 'Fair', GradeFilter.c),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gradeOption(ProductGrade grade, String label, GradeFilter filter) {
    final isSel = selected == filter;
    return GestureDetector(
      onTap: () => onSelected(filter),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          color: isSel ? AppColors.successPale : AppColors.white,
          border: Border.all(
              color: isSel ? AppColors.success : AppColors.border, width: 1.5),
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GradeBadge(grade: grade, size: 16),
            const SizedBox(width: 4),
            Text(label,
                style: AppTextStyles.label.copyWith(
                  fontSize: 11,
                  letterSpacing: 0,
                  color: isSel ? const Color(0xFF15803D) : AppColors.mid,
                )),
          ],
        ),
      ),
    );
  }

  Widget _option(String label,
      {required VoidCallback onTap, required bool selected}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? AppColors.successPale : AppColors.white,
          border: Border.all(
              color: selected ? AppColors.success : AppColors.border,
              width: 1.5),
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Text(label,
            style: AppTextStyles.label.copyWith(
              fontSize: 11,
              letterSpacing: 0,
              color: selected ? const Color(0xFF15803D) : AppColors.mid,
            )),
      ),
    );
  }
}
