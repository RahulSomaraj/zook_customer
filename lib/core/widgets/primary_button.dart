import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Pill-shaped primary CTA used across the app.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final Color textColor;
  final bool isLoading;
  final Widget? trailing;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = AppColors.primary,
    this.textColor = AppColors.white,
    this.isLoading = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9999),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.30),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            disabledBackgroundColor: color.withValues(alpha: 0.6),
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9999),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(label, style: AppTextStyles.button.copyWith(color: textColor)),
                    if (trailing != null) ...[
                      const SizedBox(width: 8),
                      trailing!,
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}
