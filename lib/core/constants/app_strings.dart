import 'dart:ui';

import '../../l10n/gen/app_localizations.dart';

/// Locale-aware user-facing strings.
///
/// Historically these were English-only `static const`s; they now delegate to
/// the gen-l10n [AppLocalizations] bundle (lib/l10n/app_en.arb / app_ar.arb)
/// while keeping the same static call sites (`AppStrings.welcomeBack`), so no
/// widget had to change. [load] is called by LocaleCubit whenever the locale
/// changes; the app rebuilds from the root, so every read picks up the new
/// language.
///
/// New screens should prefer `AppLocalizations.of(context)` directly; add new
/// keys to the ARB files either way.
class AppStrings {
  AppStrings._();

  static AppLocalizations _l = lookupAppLocalizations(const Locale('en'));

  /// Swap the active language. Falls back to English for unknown locales.
  static void load(Locale locale) {
    _l = AppLocalizations.supportedLocales.contains(Locale(locale.languageCode))
        ? lookupAppLocalizations(Locale(locale.languageCode))
        : lookupAppLocalizations(const Locale('en'));
  }

  static String get appName => _l.appName;
  static String get tagline => _l.tagline;

  // Country & Language
  static String get localeTitle => _l.localeTitle;
  static String get localeSubtitle => _l.localeSubtitle;
  static String get countryLabel => _l.countryLabel;
  static String get languageLabel => _l.languageLabel;
  static String get localeContinue => _l.localeContinue;
  static String get localeNote => _l.localeNote;

  // Onboarding
  static String get skip => _l.skip;
  static String get next => _l.next;
  static String get getStarted => _l.getStarted;

  // Login
  static String get welcomeBack => _l.welcomeBack;
  static String get signInToAccount => _l.signInToAccount;
  static String get mobileNumber => _l.mobileNumber;
  static String get continueWithOtp => _l.continueWithOtp;
  static String get invalidPhone => _l.invalidPhone;
  static String get orContinueWith => _l.orContinueWith;
  static String get continueWithApple => _l.continueWithApple;
  static String get continueWithGoogle => _l.continueWithGoogle;
  static String get noAccount => _l.noAccount;
  static String get signUpFree => _l.signUpFree;

  // Sign up
  static String get createAccount => _l.createAccount;
  static String get signUpSubtitle => _l.signUpSubtitle;
  static String get fullName => _l.fullName;
  static String get fullNameHint => _l.fullNameHint;
  static String get email => _l.email;
  static String get emailHint => _l.emailHint;
  static String get mobileHint => _l.mobileHint;
  static String get continueText => _l.continueText;
  static String get invalidName => _l.invalidName;
  static String get invalidEmail => _l.invalidEmail;
  static String get haveAccount => _l.haveAccount;
  static String get signIn => _l.signIn;

  // OTP
  static String get enterOtp => _l.enterOtp;
  static String get otpSentTo => _l.otpSentTo;
  static String get resendIn => _l.resendIn;
  static String get resendOtp => _l.resendOtp;
  static String get verifyContinue => _l.verifyContinue;
  static String get termsPrefix => _l.termsPrefix;
  static String get terms => _l.terms;
  static String get and => _l.and;
  static String get privacy => _l.privacy;

  // Tabs
  static String get tabSearch => _l.tabSearch;
  static String get tabCart => _l.tabCart;
  static String get tabOrders => _l.tabOrders;
  static String get tabProfile => _l.tabProfile;

  // Verify phone (attach flow)
  static String get verifyPhoneTitle => _l.verifyPhoneTitle;
  static String get addPhoneTitle => _l.addPhoneTitle;
  static String get enterCodeTitle => _l.enterCodeTitle;
  static String get phoneNeededForDelivery => _l.phoneNeededForDelivery;
  static String get sendCode => _l.sendCode;
  static String get resendCode => _l.resendCode;
  static String get verifyAndContinue => _l.verifyAndContinue;
  static String sentTo(String phone) => _l.sentTo(phone);
  static String get uatDevCode => _l.uatDevCode;

  // Alerts
  static String get verificationFailed => _l.verificationFailed;
  static String get signInFailed => _l.signInFailed;
  static String get registrationFailed => _l.registrationFailed;
  static String get pleaseTryAgain => _l.pleaseTryAgain;

  // Profile
  static String get logOut => _l.logOut;
  static String get comingSoon => _l.comingSoon;
}
