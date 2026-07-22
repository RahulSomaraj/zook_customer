import 'package:flutter/material.dart';

/// A single onboarding slide's content + styling.
class OnboardingItem {
  final String emoji;
  final List<Color> circleGradient;
  final String title;
  final String subtitle;
  final OnboardingBadge topBadge;
  final OnboardingBadge bottomBadge;

  const OnboardingItem({
    required this.emoji,
    required this.circleGradient,
    required this.title,
    required this.subtitle,
    required this.topBadge,
    required this.bottomBadge,
  });
}

/// A small floating badge shown over the illustration.
class OnboardingBadge {
  final IconData icon;
  final Color iconColor;
  final String text;

  /// Overrides [icon] with a custom-painted glyph when set.
  final Widget? iconWidget;

  const OnboardingBadge({
    required this.icon,
    required this.iconColor,
    required this.text,
    this.iconWidget,
  });
}
