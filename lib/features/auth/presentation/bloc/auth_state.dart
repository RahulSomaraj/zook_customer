part of 'auth_bloc.dart';

enum AuthStatus { initial, loading, otpSent, authenticated, failure }

class AuthState extends Equatable {
  final AuthStatus status;
  final String phoneNumber;
  final AuthUser? user;
  final String? devOtp;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.phoneNumber = '',
    this.user,
    this.devOtp,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? phoneNumber,
    AuthUser? user,
    String? devOtp,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      user: user ?? this.user,
      devOtp: devOtp,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, phoneNumber, user, devOtp, errorMessage];
}
