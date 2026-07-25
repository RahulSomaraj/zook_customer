import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/auth_user.dart';

/// Contract the data layer fulfils. Presentation depends on this, not on Dio.
abstract class AuthRepository {
  /// Registers a new customer account with the given details.
  Future<Either<Failure, Unit>> register({
    required String fullName,
    required String email,
    required String countryCode,
    required String phone,
  });

  /// Requests an OTP be sent to [phoneNumber] (E.164, e.g. +97150...).
  /// Returns the dev code if the API provides one (UAT), otherwise null.
  Future<Either<Failure, String?>> sendOtp(String phoneNumber);

  /// Verifies [otp] for [phoneNumber], persists the tokens and returns the user.
  Future<Either<Failure, AuthUser>> verifyOtp({
    required String phoneNumber,
    required String otp,
  });

  /// Native Google sign-in (via Supabase), exchanges for our session tokens,
  /// persists them and returns the user.
  Future<Either<Failure, AuthUser>> signInWithGoogle();

  /// Sends an OTP to attach [phoneNumber] to the current signed-in user.
  /// Returns the dev code when the API provides one (UAT), otherwise null.
  Future<Either<Failure, String?>> sendPhoneAttachOtp(String phoneNumber);

  /// Verifies the attach OTP; the API sets phone + phoneVerified on the
  /// current user. Used to unlock checkout after a social signup.
  Future<Either<Failure, Unit>> verifyPhoneAttach({
    required String phoneNumber,
    required String otp,
  });

  /// True if a valid session (access token) is stored.
  bool get isLoggedIn;

  /// The cached signed-in user (name, phone, …) restored from local storage,
  /// or null when no session is stored. Used to rehydrate state on app start.
  AuthUser? get currentUser;

  /// Clears the stored session.
  Future<void> logout();
}
