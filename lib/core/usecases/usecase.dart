import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../error/failures.dart';

/// Contract every use case implements. [Type] is the success payload,
/// [Params] is the input. Use [NoParams] when no input is required.
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
