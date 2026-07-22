import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class SendOtp implements UseCase<String?, SendOtpParams> {
  final AuthRepository repository;
  SendOtp(this.repository);

  @override
  Future<Either<Failure, String?>> call(SendOtpParams params) =>
      repository.sendOtp(params.phoneNumber);
}

class SendOtpParams extends Equatable {
  final String phoneNumber;
  const SendOtpParams({required this.phoneNumber});

  @override
  List<Object?> get props => [phoneNumber];
}
