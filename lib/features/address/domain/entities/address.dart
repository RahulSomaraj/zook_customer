import 'package:equatable/equatable.dart';

/// A customer delivery address.
class Address extends Equatable {
  final String? id;
  final String fullName;
  final String phone;
  final String label; // Home / Work / …
  final String line1;
  final String? line2;
  final String city;
  final String state;
  final String country;
  final String? postalCode;
  final String? landmark;
  final double? latitude;
  final double? longitude;
  final bool isActive;
  final bool isDefault;

  const Address({
    this.id,
    required this.fullName,
    required this.phone,
    required this.label,
    required this.line1,
    this.line2,
    required this.city,
    required this.state,
    this.country = 'UAE',
    this.postalCode,
    this.landmark,
    this.latitude,
    this.longitude,
    this.isActive = true,
    this.isDefault = false,
  });

  /// A single-line summary of the street lines (used in compact rows).
  String get streetLine =>
      [line1, if (line2 != null && line2!.trim().isNotEmpty) line2]
          .join(', ');

  /// "Dubai, UAE" style region line.
  String get regionLine =>
      [city, if (state.isNotEmpty && state != city) state, country]
          .where((e) => e.trim().isNotEmpty)
          .join(', ');

  Address copyWith({String? id, bool? isDefault}) => Address(
        id: id ?? this.id,
        fullName: fullName,
        phone: phone,
        label: label,
        line1: line1,
        line2: line2,
        city: city,
        state: state,
        country: country,
        postalCode: postalCode,
        landmark: landmark,
        latitude: latitude,
        longitude: longitude,
        isActive: isActive,
        isDefault: isDefault ?? this.isDefault,
      );

  @override
  List<Object?> get props => [
        id,
        fullName,
        phone,
        label,
        line1,
        line2,
        city,
        state,
        country,
        postalCode,
        landmark,
        isDefault,
      ];
}
