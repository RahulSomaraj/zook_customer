import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/countries.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Phone number input with a tappable country-code prefix (UAE, India, …).
class PhoneInputField extends StatelessWidget {
  final TextEditingController? controller;

  /// Currently-selected country. Tapping the prefix opens a picker when
  /// [onCountryChanged] is provided.
  final Country country;
  final ValueChanged<Country>? onCountryChanged;

  final String? hint;
  final TextStyle? hintStyle;
  final ValueChanged<String>? onChanged;

  /// When non-null, shows this message below the field (no red border).
  final String? errorText;

  const PhoneInputField({
    super.key,
    this.controller,
    this.country = kUae,
    this.onCountryChanged,
    this.hint,
    this.hintStyle,
    this.onChanged,
    this.errorText,
  });

  Future<void> _pickCountry(BuildContext context) async {
    final selected = await showModalBottomSheet<Country>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Select country',
                    style: AppTextStyles.title.copyWith(fontSize: 16)),
              ),
            ),
            for (final c in kCountries)
              ListTile(
                title: Text(c.name,
                    style: AppTextStyles.body.copyWith(
                        color: AppColors.black, fontWeight: FontWeight.w600)),
                trailing: Text(c.code,
                    style: AppTextStyles.body.copyWith(
                        color: c.code == country.code
                            ? AppColors.primary
                            : AppColors.mid,
                        fontWeight: FontWeight.w700)),
                selected: c.code == country.code,
                selectedTileColor: AppColors.primaryPale,
                onTap: () => Navigator.of(ctx).pop(c),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (selected != null) onCountryChanged?.call(selected);
  }

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;
    final canPick = onCountryChanged != null;
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
              GestureDetector(
                onTap: canPick ? () => _pickCountry(context) : null,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                      right: BorderSide(color: AppColors.border, width: 1.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(country.code,
                          style: AppTextStyles.body
                              .copyWith(fontWeight: FontWeight.w700)),
                      if (canPick) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down,
                            size: 18, color: AppColors.mid),
                      ],
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(country.nationalLength),
                  ],
                  onChanged: onChanged,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: hint ?? country.hint,
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
