import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/locale/locale_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';

/// A selectable country/currency option.
class _Country {
  final String flag;
  final String name;
  final String meta;
  const _Country(this.flag, this.name, this.meta);
}

const List<_Country> _kCountries = [
  _Country('🇦🇪', 'United Arab Emirates', 'AED · +971'),
  _Country('🇶🇦', 'Qatar', 'QAR · +974'),
  _Country('🇸🇦', 'Saudi Arabia', 'SAR · +966'),
  _Country('🇴🇲', 'Oman', 'OMR · +968'),
  _Country('🇰🇼', 'Kuwait', 'KWD · +965'),
];

/// A selectable language option ("Hello" greeting + name).
class _Language {
  final String hello;
  final String name;
  const _Language(this.hello, this.name);
}

const List<_Language> _kLanguages = [
  _Language('Hello!', 'English'),
  _Language('مرحباً', 'العربية · Arabic'),
];

/// Country & language selection, shown before onboarding.
///
/// This captures the user's preference; wiring it to app-wide localization
/// (translations + RTL) is a separate i18n task.
class LocalePage extends StatefulWidget {
  const LocalePage({super.key});

  @override
  State<LocalePage> createState() => _LocalePageState();
}

class _LocalePageState extends State<LocalePage> {
  int _country = 0;
  late int _language =
      context.read<LocaleCubit>().isArabic ? 1 : 0; // index into _kLanguages

  void _continue() {
    // Apply + persist the chosen language app-wide (index 1 = العربية).
    context.read<LocaleCubit>().setLanguage(_language == 1 ? 'ar' : 'en');
    // Reached from onboarding normally; from Profile it can just pop back.
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoute.onboarding.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.appName.toUpperCase(),
                  style: AppTextStyles.brand(size: 26)),
              const SizedBox(height: 20),
              Text(AppStrings.localeTitle,
                  style: AppTextStyles.title.copyWith(fontSize: 23)),
              const SizedBox(height: 5),
              Text(AppStrings.localeSubtitle,
                  style: AppTextStyles.subtitle.copyWith(height: 1.55)),
              const SizedBox(height: 16),
              _SectionLabel(AppStrings.countryLabel),
              const SizedBox(height: 8),
              for (var i = 0; i < _kCountries.length; i++) ...[
                _CountryRow(
                  country: _kCountries[i],
                  selected: i == _country,
                  onTap: () => setState(() => _country = i),
                ),
                if (i != _kCountries.length - 1) const SizedBox(height: 7),
              ],
              const SizedBox(height: 18),
              _SectionLabel(AppStrings.languageLabel),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (var i = 0; i < _kLanguages.length; i++) ...[
                    Expanded(
                      child: _LanguageCard(
                        language: _kLanguages[i],
                        selected: i == _language,
                        onTap: () => setState(() => _language = i),
                      ),
                    ),
                    if (i != _kLanguages.length - 1) const SizedBox(width: 10),
                  ],
                ],
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: AppStrings.localeContinue,
                onPressed: _continue,
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  AppStrings.localeNote,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption
                      .copyWith(fontSize: 11, height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTextStyles.caption.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.light,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _CountryRow extends StatelessWidget {
  final _Country country;
  final bool selected;
  final VoidCallback onTap;
  const _CountryRow({
    required this.country,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryPale : AppColors.white,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(country.flag, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(country.name,
                      style: AppTextStyles.body.copyWith(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black)),
                  const SizedBox(height: 1),
                  Text(country.meta,
                      style: AppTextStyles.caption
                          .copyWith(fontSize: 11, color: AppColors.mid)),
                ],
              ),
            ),
            _Radio(selected: selected),
          ],
        ),
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  final bool selected;
  const _Radio({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppColors.primary : AppColors.white,
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.border,
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: selected
          ? Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white,
              ),
            )
          : null,
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final _Language language;
  final bool selected;
  final VoidCallback onTap;
  const _LanguageCard({
    required this.language,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryPale : AppColors.white,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(language.hello,
                    style: AppTextStyles.title.copyWith(fontSize: 19)),
                const SizedBox(height: 3),
                Text(language.name,
                    style: AppTextStyles.caption.copyWith(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mid)),
              ],
            ),
            if (selected)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.check,
                      size: 11, color: AppColors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
