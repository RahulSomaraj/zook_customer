import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/foundation.dart';

import '../constants/app_strings.dart';
import '../settings/settings_remote_data_source.dart';
import '../theme/app_text_styles.dart';

/// Holds and persists the app language (en / ar). Emitting a new locale
/// rebuilds MaterialApp (locale + theme + direction), and [_apply] flips the
/// static AppStrings/AppTextStyles bindings so legacy `AppStrings.x` call
/// sites pick up the new language on that rebuild.
class LocaleCubit extends Cubit<Locale> {
  static const _kKey = 'app_locale';
  static const _kCountry = 'app_country';
  final SharedPreferences prefs;

  /// Syncs the language to the customer's profile when signed in.
  final SettingsRemoteDataSource? settings;
  final bool Function()? isLoggedIn;

  LocaleCubit({required this.prefs, this.settings, this.isLoggedIn})
      : super(Locale(prefs.getString(_kKey) ?? 'en')) {
    _apply(state);
  }

  bool get isArabic => state.languageCode == 'ar';

  Future<void> setLanguage(String languageCode) async {
    final locale = Locale(languageCode == 'ar' ? 'ar' : 'en');
    await prefs.setString(_kKey, locale.languageCode);
    _apply(locale);
    emit(locale);
    if (isLoggedIn?.call() ?? false) pushToServer();
  }

  /// Selected storefront country (ISO2), e.g. "AE". Null until chosen.
  String? get countryCode => prefs.getString(_kCountry);

  Future<void> setCountry(String iso2) => prefs.setString(_kCountry, iso2);

  /// Best-effort: store the current language on the customer profile. Called
  /// on change while signed in and right after sign-in (the language is
  /// picked before login on first run).
  Future<void> pushToServer() async {
    try {
      await settings?.updateLanguage(state.languageCode);
    } catch (e) {
      debugPrint('Language sync failed: $e');
    }
  }

  void _apply(Locale locale) {
    AppStrings.load(locale);
    AppTextStyles.arabic = locale.languageCode == 'ar';
  }
}
