// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'Zook';

  @override
  String get tagline => 'سوق الإمارات الموثوق للسلع المستعملة';

  @override
  String get localeTitle => 'من أين تتسوق؟';

  @override
  String get localeSubtitle => 'بلدك يحدد العملة وصيغة رقم الهاتف.';

  @override
  String get countryLabel => 'الدولة';

  @override
  String get languageLabel => 'اللغة';

  @override
  String get localeContinue => 'متابعة';

  @override
  String get localeNote =>
      'يمكنك تغيير الدولة واللغة في أي وقت من الملف الشخصي.';

  @override
  String get skip => 'تخطي';

  @override
  String get next => 'التالي';

  @override
  String get getStarted => 'ابدأ الآن';

  @override
  String get welcomeBack => 'مرحبًا بعودتك';

  @override
  String get signInToAccount => 'سجّل الدخول إلى حسابك';

  @override
  String get mobileNumber => 'رقم الهاتف المتحرك';

  @override
  String get continueWithOtp => 'المتابعة برمز التحقق';

  @override
  String get invalidPhone => 'رقم هاتف غير صالح';

  @override
  String get orContinueWith => 'أو تابع باستخدام';

  @override
  String get continueWithApple => 'المتابعة عبر Apple';

  @override
  String get continueWithGoogle => 'المتابعة عبر Google';

  @override
  String get noAccount => 'ليس لديك حساب؟';

  @override
  String get signUpFree => 'سجّل مجانًا';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get signUpSubtitle => 'انضم إلى Zook في ثوانٍ';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get fullNameHint => 'أدخل اسمك الكامل';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get emailHint => 'أدخل بريدك الإلكتروني';

  @override
  String get mobileHint => 'أدخل رقم هاتفك المتحرك';

  @override
  String get continueText => 'متابعة';

  @override
  String get invalidName => 'اسم غير صالح';

  @override
  String get invalidEmail => 'بريد إلكتروني غير صالح';

  @override
  String get haveAccount => 'لديك حساب بالفعل؟';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get enterOtp => 'أدخل رمز التحقق';

  @override
  String get otpSentTo => 'أرسلنا رمزًا من 6 أرقام إلى';

  @override
  String get resendIn => 'إعادة الإرسال خلال';

  @override
  String get resendOtp => 'إعادة إرسال الرمز';

  @override
  String get verifyContinue => 'تحقق وتابع';

  @override
  String get termsPrefix => 'بمتابعتك فإنك توافق على';

  @override
  String get terms => 'شروط الخدمة';

  @override
  String get and => 'و';

  @override
  String get privacy => 'سياسة الخصوصية';

  @override
  String get tabSearch => 'بحث';

  @override
  String get tabCart => 'السلة';

  @override
  String get tabOrders => 'الطلبات';

  @override
  String get tabProfile => 'الملف الشخصي';

  @override
  String get verifyPhoneTitle => 'تأكيد الهاتف';

  @override
  String get addPhoneTitle => 'أضف رقم هاتفك المتحرك';

  @override
  String get enterCodeTitle => 'أدخل الرمز المكوّن من 6 أرقام';

  @override
  String get phoneNeededForDelivery => 'نحتاج إلى رقم هاتف مؤكد لتوصيل طلبك.';

  @override
  String get sendCode => 'إرسال الرمز';

  @override
  String get resendCode => 'إعادة إرسال الرمز';

  @override
  String get verifyAndContinue => 'تحقق وتابع';

  @override
  String sentTo(String phone) {
    return 'أُرسل إلى $phone';
  }

  @override
  String get uatDevCode => 'رمز بيئة الاختبار';

  @override
  String get verificationFailed => 'فشل التحقق';

  @override
  String get signInFailed => 'فشل تسجيل الدخول';

  @override
  String get registrationFailed => 'فشل إنشاء الحساب';

  @override
  String get pleaseTryAgain => 'يرجى المحاولة مرة أخرى.';

  @override
  String get logOut => 'تسجيل الخروج';

  @override
  String get comingSoon => 'قريبًا';
}
