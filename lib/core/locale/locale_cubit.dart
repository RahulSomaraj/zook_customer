import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_strings.dart';
import '../theme/app_text_styles.dart';

/// Holds and persists the app language (en / ar). Emitting a new locale
/// rebuilds MaterialApp (locale + theme + direction), and [_apply] flips the
/// static AppStrings/AppTextStyles bindings so legacy `AppStrings.x` call
/// sites pick up the new language on that rebuild.
class LocaleCubit extends Cubit<Locale> {
  static const _kKey = 'app_locale';
  final SharedPreferences prefs;

  LocaleCubit({required this.prefs})
      : super(Locale(prefs.getString(_kKey) ?? 'en')) {
    _apply(state);
  }

  bool get isArabic => state.languageCode == 'ar';

  Future<void> setLanguage(String languageCode) async {
    final locale = Locale(languageCode == 'ar' ? 'ar' : 'en');
    await prefs.setString(_kKey, locale.languageCode);
    _apply(locale);
    emit(locale);
  }

  void _apply(Locale locale) {
    AppStrings.load(locale);
    AppTextStyles.arabic = locale.languageCode == 'ar';
  }
}
