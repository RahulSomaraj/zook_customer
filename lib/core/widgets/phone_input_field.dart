import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Phone number input with a fixed country-code prefix, matching the mockup.
class PhoneInputField extends StatelessWidget {
  final TextEditingController? controller;
  final String countryFlag;
  final String countryCode;
  final String hint;
  final TextStyle? hintStyle;
  final ValueChanged<String>? onChanged;

  /// When non-null, the field shows a red border and this message below it.
  final String? errorText;

  const PhoneInputField({
    super.key,
    this.controller,
    this.countryFlag = AppConstants.countryFlag,
    this.countryCode = AppConstants.countryCode,
    this.hint = '50 000 0000',
    this.hintStyle,
    this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(
                    right: BorderSide(color: AppColors.border, width: 1.5),
                  ),
                ),
                child: Text(
                  '$countryFlag $countryCode',
                  style:
                      AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: onChanged,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: hintStyle,
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (hasError) ...[
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
