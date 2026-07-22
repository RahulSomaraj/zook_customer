import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/onboarding_item.dart';

/// Renders one onboarding slide: centred illustration emoji, floating badges
/// (top-right and bottom-left) and the title/subtitle copy.
class OnboardingSlide extends StatelessWidget {
  final OnboardingItem item;
  const OnboardingSlide({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              // Centred illustration (no background circle)
              Center(
                child: Text(item.emoji, style: const TextStyle(fontSize: 96)),
              ),
              // Floating badge — top right
              Positioned(
                top: 24,
                right: 20,
                child: _Badge(badge: item.topBadge),
              ),
              // Floating badge — bottom left
              Positioned(
                bottom: 24,
                left: 20,
                child: _Badge(badge: item.bottomBadge),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 0, 28, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.title, style: AppTextStyles.heading),
              const SizedBox(height: 10),
              Text(item.subtitle, style: AppTextStyles.subtitle),
            ],
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final OnboardingBadge badge;
  const _Badge({required this.badge});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          badge.iconWidget ??
              Icon(badge.icon, size: 15, color: badge.iconColor),
          const SizedBox(width: 6),
          Text(
            badge.text,
            style: AppTextStyles.label.copyWith(
              fontSize: 11,
              letterSpacing: 0,
              color: AppColors.charcoal,
            ),
          ),
        ],
      ),
    );
  }
}
