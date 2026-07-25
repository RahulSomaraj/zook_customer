part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// App launched — restore any cached session/user into state.
class AppStarted extends AuthEvent {
  const AppStarted();
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

/// User submitted the registration form to create a new account.
class RegisterRequested extends AuthEvent {
  final String fullName;
  final String email;
  final String countryCode;
  final String phone;
  const RegisterRequested({
    required this.fullName,
    required this.email,
    required this.countryCode,
    required this.phone,
  });

  @override
  List<Object?> get props => [fullName, email, countryCode, phone];
}

/// User tapped "Continue with Google" — runs the native Google → Supabase →
/// backend exchange and signs them in (auto-creates the account first time).
class GoogleSignInRequested extends AuthEvent {
  const GoogleSignInRequested();
}

/// Authenticated user (e.g. Google signup) asked to attach a phone number —
/// sends the attach OTP. Distinct from [OtpRequested], which is a login flow.
class PhoneAttachOtpRequested extends AuthEvent {
  final String phoneNumber;
  const PhoneAttachOtpRequested(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

/// Authenticated user submitted the attach OTP code.
class PhoneAttachSubmitted extends AuthEvent {
  final String phoneNumber;
  final String otp;
  const PhoneAttachSubmitted({required this.phoneNumber, required this.otp});

  @override
  List<Object?> get props => [phoneNumber, otp];
}

/// User asked to sign out. Clears the stored session.
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}
