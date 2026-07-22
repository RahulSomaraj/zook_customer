part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// User submitted their phone number to receive an OTP.
class OtpRequested extends AuthEvent {
  final String phoneNumber;
  const OtpRequested(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

/// User submitted the OTP code for verification.
class OtpSubmitted extends AuthEvent {
  final String phoneNumber;
  final String otp;
  const OtpSubmitted({required this.phoneNumber, required this.otp});

  @override
  List<Object?> get props => [phoneNumber, otp];
}

/// User asked to sign out. Clears the stored session.
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}
