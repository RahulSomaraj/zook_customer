part of 'auth_bloc.dart';

enum AuthStatus {
  initial,
  loading,
  otpSent,
  authenticated,
  failure,

  /// Phone-attach flow (authenticated user adding a phone): code sent.
  phoneAttachOtpSent,

  /// Phone-attach flow: phone verified and linked to the current account.
  phoneAttached,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final String phoneNumber;
  final AuthUser? user;
  final String? devOtp;
  final String? errorMessage;

  /// From a 429: seconds until the next OTP send is allowed. Drives the
  /// resend countdown when present.
  final int? retryAfterSeconds;

  const AuthState({
    this.status = AuthStatus.initial,
    this.phoneNumber = '',
    this.user,
    this.devOtp,
    this.errorMessage,
    this.retryAfterSeconds,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? phoneNumber,
    AuthUser? user,
    String? devOtp,
    String? errorMessage,
    int? retryAfterSeconds,
  }) {
    return AuthState(
      status: status ?? this.status,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      user: user ?? this.user,
      devOtp: devOtp,
      errorMessage: errorMessage,
      retryAfterSeconds: retryAfterSeconds,
    );
  }

  @override
  List<Object?> get props =>
      [status, phoneNumber, user, devOtp, errorMessage, retryAfterSeconds];
}
