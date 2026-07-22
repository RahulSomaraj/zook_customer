import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// "Title ........ View all ›" row used above product sections.
class SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback? onAction;
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel = 'View all',
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.title.copyWith(fontSize: 16)),
          GestureDetector(
            onTap: onAction,
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(actionLabel,
                    style: AppTextStyles.label.copyWith(
                        fontSize: 12,
                        letterSpacing: 0,
                        color: AppColors.primary)),
                const Icon(Icons.chevron_right,
                    size: 16, color: AppColors.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
