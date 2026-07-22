import '../../domain/entities/auth_user.dart';

/// Data-layer model. Parses the `/auth/customer/otp/verify` response.
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
}
