import 'package:equatable/equatable.dart';

/// Authenticated user entity (domain layer — framework-agnostic).
class AuthUser extends Equatable {
  final String id;
  final String phoneNumber;
  final String? fullName;
  final String? email;
  final List<String> roles;
  final String? accessToken;
  final String? refreshToken;

  const AuthUser({
    required this.id,
    required this.phoneNumber,
    this.fullName,
    this.email,
    this.roles = const [],
    this.accessToken,
    this.refreshToken,
  });

  @override
  List<Object?> get props =>
      [id, phoneNumber, fullName, email, roles, accessToken, refreshToken];
}
