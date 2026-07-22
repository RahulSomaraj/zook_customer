import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/auth_user.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/send_otp.dart';
import '../../domain/usecases/verify_otp.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SendOtp sendOtp;
  final VerifyOtp verifyOtp;
  final Logout logout;

  AuthBloc({
    required this.sendOtp,
    required this.verifyOtp,
    required this.logout,
  }) : super(const AuthState()) {
    on<OtpRequested>(_onOtpRequested);
    on<OtpSubmitted>(_onOtpSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await logout();
    emit(const AuthState()); // back to unauthenticated/initial
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
          status: AuthStatus.failure, errorMessage: failure.message)),
      (devCode) =>
          emit(state.copyWith(status: AuthStatus.otpSent, devOtp: devCode)),
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
