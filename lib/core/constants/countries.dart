/// A dialing country supported by phone / OTP auth.
class Country {
  final String name;
  final String flag;

  /// National dialing code without '+', e.g. '971' or '91'.
  final String dialCode;

  /// E.164 prefix, e.g. '+971'.
  final String code;

  /// Placeholder for the national number.
  final String hint;

  /// Expected length of the national number (used to cap input).
  final int nationalLength;

  /// Regex the national number must satisfy to be a valid mobile.
  final String pattern;

  const Country({
    required this.name,
    required this.flag,
    required this.dialCode,
    required this.code,
    required this.hint,
    required this.nationalLength,
    required this.pattern,
  });

  /// National digits only — strips spaces, a leading country code, and any
  /// trunk '0'. Only strips the country code when the input is long enough to
  /// actually include it (so a 10-digit Indian number starting "91" is safe).
  String nationalDigits(String raw) {
    var d = raw.replaceAll(RegExp(r'\D'), '');
    if (d.length > nationalLength && d.startsWith(dialCode)) {
      d = d.substring(dialCode.length);
    }
    while (d.length > nationalLength && d.startsWith('0')) {
      d = d.substring(1);
    }
    return d;
  }

  /// E.164 form, e.g. "+919656082258".
  String toE164(String raw) => '$code${nationalDigits(raw)}';

  bool isValidMobile(String raw) =>
      RegExp(pattern).hasMatch(nationalDigits(raw));
}

/// United Arab Emirates — 9-digit mobile starting with 5.
const Country kUae = Country(
  name: 'United Arab Emirates',
  flag: '🇦🇪',
  dialCode: '971',
  code: '+971',
  hint: '50 000 0000',
  nationalLength: 9,
  pattern: r'^5\d{8}$',
);

/// India — 10-digit mobile starting 6–9.
const Country kIndia = Country(
  name: 'India',
  flag: '🇮🇳',
  dialCode: '91',
  code: '+91',
  hint: '98765 43210',
  nationalLength: 10,
  pattern: r'^[6-9]\d{9}$',
);

/// Countries offered in the phone picker (first entry is the default).
const List<Country> kCountries = [kUae, kIndia];
