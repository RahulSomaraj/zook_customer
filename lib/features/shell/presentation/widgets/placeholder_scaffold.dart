import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Simple placeholder used for tabs that are not yet designed.
class PlaceholderScaffold extends StatelessWidget {
  final String title;
  final String emoji;
  final String message;
  const PlaceholderScaffold({
    super.key,
    required this.title,
    required this.emoji,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(title, style: AppTextStyles.title.copyWith(fontSize: 18)),
        backgroundColor: AppColors.white,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            Text(message, style: AppTextStyles.subtitle),
          ],
        ),
      ),
    );
  }
}
