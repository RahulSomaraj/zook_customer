import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/register.dart';
import '../../domain/usecases/send_otp.dart';
import '../../domain/usecases/verify_otp.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Register register;
  final SendOtp sendOtp;
  final VerifyOtp verifyOtp;
  final Logout logout;
  final AuthRepository authRepository;

  AuthBloc({
    required this.register,
    required this.sendOtp,
    required this.verifyOtp,
    required this.logout,
    required this.authRepository,
  }) : super(const AuthState()) {
    on<AppStarted>(_onAppStarted);
    on<RegisterRequested>(_onRegisterRequested);
    on<OtpRequested>(_onOtpRequested);
    on<OtpSubmitted>(_onOtpSubmitted);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<PhoneAttachOtpRequested>(_onPhoneAttachOtpRequested);
    on<PhoneAttachSubmitted>(_onPhoneAttachSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
  }

  /// Restores the cached user (name/phone) so the home greeting and profile
  /// show the signed-in user after an app relaunch, not just right after login.
  void _onAppStarted(AppStarted event, Emitter<AuthState> emit) {
    final user = authRepository.currentUser;
    if (user != null) {
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        phoneNumber: user.phoneNumber,
      ));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await logout();
    emit(const AuthState()); // back to unauthenticated/initial
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    final e164 = '${event.countryCode}${event.phone}';
    emit(state.copyWith(status: AuthStatus.loading, phoneNumber: e164));

    final result = await register(RegisterParams(
      fullName: event.fullName,
      email: event.email,
      countryCode: event.countryCode,
      phone: event.phone,
    ));

    await result.fold(
      (failure) async => emit(state.copyWith(
          status: AuthStatus.failure, errorMessage: failure.message)),
      (_) async {
        // Account created — send an OTP so the user can verify and sign in.
        final otp = await sendOtp(SendOtpParams(phoneNumber: e164));
        otp.fold(
          (failure) => emit(state.copyWith(
              status: AuthStatus.failure, errorMessage: failure.message)),
          (devCode) =>
              emit(state.copyWith(status: AuthStatus.otpSent, devOtp: devCode)),
        );
      },
    );
  }

  Future<void> _onOtpRequested(
    OtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(
        status: AuthStatus.loading, phoneNumber: event.phoneNumber));
    final result = await sendOtp(SendOtpParams(phoneNumber: event.phoneNumber));
    result.fold(
      (failure) => emit(state.copyWith(
          status: AuthStatus.failure,
          errorMessage: failure.message,
          retryAfterSeconds: failure.retryAfterSeconds)),
      (devCode) =>
          emit(state.copyWith(status: AuthStatus.otpSent, devOtp: devCode)),
    );
  }

  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await authRepository.signInWithGoogle();
    result.fold(
      (failure) {
        // A cancelled picker just returns to the idle screen, no error alert.
        if (failure.message == 'Sign-in cancelled.') {
          emit(state.copyWith(status: AuthStatus.initial));
        } else {
          emit(state.copyWith(
              status: AuthStatus.failure, errorMessage: failure.message));
        }
      },
      (user) =>
          emit(state.copyWith(status: AuthStatus.authenticated, user: user)),
    );
  }

  Future<void> _onPhoneAttachOtpRequested(
    PhoneAttachOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(
        status: AuthStatus.loading, phoneNumber: event.phoneNumber));
    final result = await authRepository.sendPhoneAttachOtp(event.phoneNumber);
    result.fold(
      (failure) => emit(state.copyWith(
          status: AuthStatus.failure,
          errorMessage: failure.message,
          retryAfterSeconds: failure.retryAfterSeconds)),
      (devCode) => emit(state.copyWith(
          status: AuthStatus.phoneAttachOtpSent, devOtp: devCode)),
    );
  }

  Future<void> _onPhoneAttachSubmitted(
    PhoneAttachSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await authRepository.verifyPhoneAttach(
      phoneNumber: event.phoneNumber,
      otp: event.otp,
    );
    result.fold(
      (failure) => emit(state.copyWith(
          status: AuthStatus.failure, errorMessage: failure.message)),
      (_) => emit(state.copyWith(status: AuthStatus.phoneAttached)),
    );
  }

  Future<void> _onOtpSubmitted(
    OtpSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await verifyOtp(
      VerifyOtpParams(phoneNumber: event.phoneNumber, otp: event.otp),
    );
    result.fold(
      (failure) => emit(state.copyWith(
          status: AuthStatus.failure, errorMessage: failure.message)),
      (user) =>
          emit(state.copyWith(status: AuthStatus.authenticated, user: user)),
    );
  }
}
