import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class VerifyOtp implements UseCase<AuthUser, VerifyOtpParams> {
  final AuthRepository repository;
  VerifyOtp(this.repository);

  @override
  Future<Either<Failure, AuthUser>> call(VerifyOtpParams params) =>
      repository.verifyOtp(
        phoneNumber: params.phoneNumber,
        otp: params.otp,
      );
}

class VerifyOtpParams extends Equatable {
  final String phoneNumber;
  final String otp;
  const VerifyOtpParams({required this.phoneNumber, required this.otp});

  @override
  List<Object?> get props => [phoneNumber, otp];
}
