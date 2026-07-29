// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Zook';

  @override
  String get tagline => 'UAE\'s trusted secondhand marketplace';

  @override
  String get localeTitle => 'Where are you shopping from?';

  @override
  String get localeSubtitle =>
      'Your country sets your currency and phone number format.';

  @override
  String get countryLabel => 'Country';

  @override
  String get languageLabel => 'Language';

  @override
  String get localeContinue => 'Continue';

  @override
  String get localeNote =>
      'You can change country and language anytime in Profile.';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get Started';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get signInToAccount => 'Sign in to your account';

  @override
  String get mobileNumber => 'Mobile number';

  @override
  String get continueWithOtp => 'Continue with OTP';

  @override
  String get invalidPhone => 'Invalid mobile number';

  @override
  String get orContinueWith => 'or continue with';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get signUpFree => 'Sign up free';

  @override
  String get createAccount => 'Create account';

  @override
  String get signUpSubtitle => 'Join Zook in a few seconds';

  @override
  String get fullName => 'Full name';

  @override
  String get fullNameHint => 'Enter your full name';

  @override
  String get email => 'Email';

  @override
  String get emailHint => 'Enter your email';

  @override
  String get mobileHint => 'Enter your mobile number';

  @override
  String get continueText => 'Continue';

  @override
  String get invalidName => 'Invalid name';

  @override
  String get invalidEmail => 'Invalid email address';

  @override
  String get haveAccount => 'Already have an account?';

  @override
  String get signIn => 'Sign in';

  @override
  String get enterOtp => 'Enter OTP';

  @override
  String get otpSentTo => 'We sent a 6-digit code to';

  @override
  String get resendIn => 'Resend in';

  @override
  String get resendOtp => 'Resend OTP';

  @override
  String get verifyContinue => 'Verify & Continue';

  @override
  String get termsPrefix => 'By continuing you agree to Zook\'s';

  @override
  String get terms => 'Terms of Service';

  @override
  String get and => 'and';

  @override
  String get privacy => 'Privacy Policy';

  @override
  String get tabSearch => 'Search';

  @override
  String get tabCart => 'Cart';

  @override
  String get tabOrders => 'Orders';

  @override
  String get tabProfile => 'Profile';

  @override
  String get verifyPhoneTitle => 'Verify phone';

  @override
  String get addPhoneTitle => 'Add your mobile number';

  @override
  String get enterCodeTitle => 'Enter the 6-digit code';

  @override
  String get phoneNeededForDelivery =>
      'We need a verified phone number to deliver your order.';

  @override
  String get sendCode => 'Send code';

  @override
  String get resendCode => 'Resend code';

  @override
  String get verifyAndContinue => 'Verify & continue';

  @override
  String sentTo(String phone) {
    return 'Sent to $phone';
  }

  @override
  String get uatDevCode => 'UAT dev code';

  @override
  String get verificationFailed => 'Verification failed';

  @override
  String get signInFailed => 'Sign-in failed';

  @override
  String get registrationFailed => 'Registration failed';

  @override
  String get pleaseTryAgain => 'Please try again.';

  @override
  String get logOut => 'Log out';

  @override
  String get comingSoon => 'Coming soon';
}
