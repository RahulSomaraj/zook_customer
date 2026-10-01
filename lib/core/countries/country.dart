/// A storefront country from `GET /countries`.
class Country {
  final String iso2;
  final String name;
  final String? dialCode;
  final String currencyCode;
  final bool isDefault;

  const Country({
    required this.iso2,
    required this.name,
    this.dialCode,
    required this.currencyCode,
    this.isDefault = false,
  });

  /// Flag emoji from the ISO code (regional indicator symbols).
  String get flag => iso2.length == 2
      ? String.fromCharCodes(
          iso2.toUpperCase().codeUnits.map((c) => 0x1F1E6 + c - 0x41))
      : '🏳️';

  String get meta =>
      [currencyCode, if ((dialCode ?? '').isNotEmpty) dialCode!].join(' · ');

  factory Country.fromJson(Map<String, dynamic> json) => Country(
        iso2: (json['iso2'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        dialCode: json['dialCode']?.toString(),
        currencyCode: (json['currencyCode'] ?? '').toString(),
        isDefault: json['isDefault'] == true,
      );

  /// Used when the API is unreachable (first launch offline).
  static const fallback = [
    Country(iso2: 'AE', name: 'United Arab Emirates', dialCode: '+971', currencyCode: 'AED', isDefault: true),
    Country(iso2: 'QA', name: 'Qatar', dialCode: '+974', currencyCode: 'QAR'),
    Country(iso2: 'SA', name: 'Saudi Arabia', dialCode: '+966', currencyCode: 'SAR'),
    Country(iso2: 'OM', name: 'Oman', dialCode: '+968', currencyCode: 'OMR'),
    Country(iso2: 'KW', name: 'Kuwait', dialCode: '+965', currencyCode: 'KWD'),
  ];
}
