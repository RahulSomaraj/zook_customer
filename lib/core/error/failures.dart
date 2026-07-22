import 'package:equatable/equatable.dart';

/// Base type for all recoverable failures surfaced to the domain/presentation
/// layers. Repositories return [Failure]s instead of throwing.
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Something went wrong. Try again.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error.']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed.']);
}
