import '../../domain/entities/address.dart';

/// Data-layer model mapping [Address] to/from the addresses API.
class AddressModel extends Address {
  const AddressModel({
    super.id,
    required super.fullName,
    required super.phone,
    required super.label,
    required super.line1,
    super.line2,
    required super.city,
    required super.state,
    super.country,
    super.postalCode,
    super.landmark,
    super.latitude,
    super.longitude,
    super.isActive,
    super.isDefault,
  });

  factory AddressModel.fromEntity(Address a) => AddressModel(
        id: a.id,
        fullName: a.fullName,
        phone: a.phone,
        label: a.label,
        line1: a.line1,
        line2: a.line2,
        city: a.city,
        state: a.state,
        country: a.country,
        postalCode: a.postalCode,
        landmark: a.landmark,
        latitude: a.latitude,
        longitude: a.longitude,
        isActive: a.isActive,
        isDefault: a.isDefault,
      );

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    double? toDouble(dynamic v) =>
        v == null ? null : double.tryParse(v.toString());
    return AddressModel(
      id: json['id']?.toString(),
      fullName: (json['fullName'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      label: (json['label'] ?? 'Home').toString(),
      line1: (json['line1'] ?? '').toString(),
      line2: json['line2']?.toString(),
      city: (json['city'] ?? '').toString(),
      state: (json['state'] ?? '').toString(),
      country: (json['country'] ?? 'UAE').toString(),
      postalCode: json['postalCode']?.toString(),
      landmark: json['landmark']?.toString(),
      latitude: toDouble(json['latitude']),
      longitude: toDouble(json['longitude']),
      isActive: json['isActive'] != false,
      isDefault: json['isDefault'] == true,
    );
  }

  /// Request body for `POST /customers/addresses`.
  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'phone': phone,
        'label': label,
        'line1': line1,
        if (line2 != null && line2!.trim().isNotEmpty) 'line2': line2,
        'city': city,
        'state': state,
        'country': country,
        if (postalCode != null && postalCode!.trim().isNotEmpty)
          'postalCode': postalCode,
        if (landmark != null && landmark!.trim().isNotEmpty)
          'landmark': landmark,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        'isActive': isActive,
        'isDefault': isDefault,
      };
}
