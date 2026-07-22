import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Dark gradient promo banner highlighting the Zook Verified programme.
class PromoBanner extends StatelessWidget {
  const PromoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.black, Color(0xFF2A1A0A)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.primary.withValues(alpha: 0.25),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ZOOK VERIFIED',
                          style: AppTextStyles.label.copyWith(
                              fontSize: 11,
                              color: AppColors.primary,
                              letterSpacing: 0.8)),
                      const SizedBox(height: 3),
                      Text('Quality checked\nsecondhand',
                          style: AppTextStyles.title.copyWith(
                              color: AppColors.white,
                              fontSize: 16,
                              height: 1.2)),
                      const SizedBox(height: 4),
                      Text('Every item inspected before listing',
                          style: AppTextStyles.caption.copyWith(
                              fontSize: 11,
                              color: AppColors.white.withValues(alpha: 0.45))),
                    ],
                  ),
                ),
                const Icon(Icons.verified_user,
                    size: 40, color: AppColors.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
