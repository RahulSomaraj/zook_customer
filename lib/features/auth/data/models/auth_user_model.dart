import '../../domain/entities/auth_user.dart';

/// Data-layer model. Parses the `/auth/customer/otp/verify` response and
/// (de)serialises the cached profile stored in local prefs.
class AuthUserModel extends AuthUser {
  const AuthUserModel({
    required super.id,
    required super.phoneNumber,
    super.fullName,
    super.email,
    super.roles,
    super.accessToken,
    super.refreshToken,
  });

  /// Builds a model from the `data` object of the verify response.
  ///
  /// Shape:
  /// { "status": "authenticated",
  ///   "tokens": { "accessToken", "refreshToken", "user": { id, email, ... } } }
  factory AuthUserModel.fromVerifyData(
    Map<String, dynamic> data, {
    required String phone,
  }) {
    final tokens = (data['tokens'] as Map?)?.cast<String, dynamic>() ?? {};
    final user = (tokens['user'] as Map?)?.cast<String, dynamic>() ?? {};
    return AuthUserModel(
      id: user['id']?.toString() ?? '',
      phoneNumber: phone,
      fullName: user['fullName'] as String?,
      email: user['email'] as String?,
      roles: (user['roles'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      accessToken: tokens['accessToken'] as String?,
      refreshToken: tokens['refreshToken'] as String?,
    );
  }

  /// The profile fields we persist locally (tokens are stored separately).
  Map<String, dynamic> toJson() => {
        'id': id,
        'phoneNumber': phoneNumber,
        'fullName': fullName,
        'email': email,
        'roles': roles,
      };

  /// Rebuilds a cached profile (no tokens) from local storage.
  factory AuthUserModel.fromJson(Map<String, dynamic> json) => AuthUserModel(
        id: json['id']?.toString() ?? '',
        phoneNumber: json['phoneNumber']?.toString() ?? '',
        fullName: json['fullName'] as String?,
        email: json['email'] as String?,
        roles: (json['roles'] as List?)?.map((e) => e.toString()).toList() ??
            const [],
      );
}
