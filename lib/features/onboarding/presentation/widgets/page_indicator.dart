import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Animated dot indicator. Active dot stretches into a pill.
class PageIndicator extends StatelessWidget {
  final int count;
  final int activeIndex;
  const PageIndicator({super.key, required this.count, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(count, (i) {
        final active = i == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(right: 6),
          height: 6,
          width: active ? 24 : 6,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.border,
            borderRadius: BorderRadius.circular(9999),
          ),
        );
      }),
    );
  }
}
