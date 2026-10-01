import 'package:equatable/equatable.dart';

/// Base type for all recoverable failures surfaced to the domain/presentation
/// layers. Repositories return [Failure]s instead of throwing.
abstract class Failure extends Equatable {
  final String message;

  /// On rate-limit failures: seconds until retry is allowed (from the API's
  /// 429 body). Null otherwise.
  final int? retryAfterSeconds;

  const Failure(this.message, {this.retryAfterSeconds});

  @override
  List<Object?> get props => [message, retryAfterSeconds];
}

class ServerFailure extends Failure {
  /// API error code, when the server sent one (see [ServerException.code]).
  final String? code;

  const ServerFailure([
    super.message = 'Something went wrong. Try again.',
    int? retryAfterSeconds,
    this.code,
  ]) : super(retryAfterSeconds: retryAfterSeconds);

  @override
  List<Object?> get props => [...super.props, code];
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
