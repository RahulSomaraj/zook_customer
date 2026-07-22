/// App-wide configuration constants.
class AppConstants {
  AppConstants._();

  /// Default dialing country code (E.164 prefix), no spaces. e.g. +971.
  static const String countryCode = '+971';

  /// National dialing code without the '+', used when normalising input.
  static const String countryDialCode = '971';

  /// Flag shown next to the country code in phone inputs.
  static const String countryFlag = '🇦🇪';

  /// Normalises a raw phone input into E.164, e.g. "50 123 4567" or
  /// "0501234567" → "+971501234567". Strips spaces, a leading country code,
  /// and a national trunk '0'.
  static String toE164(String raw) {
    var digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith(countryDialCode)) {
      digits = digits.substring(countryDialCode.length);
    }
    if (digits.startsWith('0')) digits = digits.substring(1);
    return '$countryCode$digits';
  }

  /// Returns the national digits (no country code, no trunk '0') for [raw].
  static String nationalDigits(String raw) {
    var digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith(countryDialCode)) {
      digits = digits.substring(countryDialCode.length);
    }
    if (digits.startsWith('0')) digits = digits.substring(1);
    return digits;
  }

  /// Validates a UAE mobile number. The national part must be 9 digits and
  /// start with 5 (UAE mobile prefixes 050/052/054/055/056/058).
  static bool isValidMobile(String raw) {
    return RegExp(r'^5\d{8}$').hasMatch(nationalDigits(raw));
  }
}
