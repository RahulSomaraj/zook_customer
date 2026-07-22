import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// Registers a new customer account.
class Register implements UseCase<Unit, RegisterParams> {
  final AuthRepository repository;
  Register(this.repository);

  @override
  Future<Either<Failure, Unit>> call(RegisterParams params) =>
      repository.register(
        fullName: params.fullName,
        email: params.email,
        countryCode: params.countryCode,
        phone: params.phone,
      );
}

class RegisterParams extends Equatable {
  final String fullName;
  final String email;
  final String countryCode;
  final String phone;
  const RegisterParams({
    required this.fullName,
    required this.email,
    required this.countryCode,
    required this.phone,
  });

  @override
  List<Object?> get props => [fullName, email, countryCode, phone];
}
