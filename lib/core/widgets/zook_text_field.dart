import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Labeled text field matching the mockup's field styling.
class ZookTextField extends StatelessWidget {
  final String? label;
  final String hint;
  final TextStyle? hintStyle;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final Widget? prefix;
  final ValueChanged<String>? onChanged;
  final String? errorText;

  const ZookTextField({
    super.key,
    this.label,
    required this.hint,
    this.hintStyle,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.prefix,
    this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!.toUpperCase(), style: AppTextStyles.label),
          const SizedBox(height: 6),
        ],
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: AppTextStyles.body.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: hintStyle,
            prefixIcon: prefix,
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: AppTextStyles.caption.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
  }
}
