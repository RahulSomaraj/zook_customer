/// Low-level exceptions thrown by data sources. Repositories catch these and
/// convert them into [Failure]s.
class ServerException implements Exception {
  final String message;

  /// On 429 responses: seconds until the client may retry (drives resend
  /// timers). Null when the server didn't provide one.
  final int? retryAfterSeconds;

  /// Stable machine code from the API envelope (e.g. `INSUFFICIENT_STOCK`,
  /// `PHONE_VERIFICATION_REQUIRED`). Branch on this, never on [message].
  final String? code;

  ServerException([
    this.message = 'Server error',
    this.retryAfterSeconds,
    this.code,
  ]);
}

class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'Network error']);
}

class CacheException implements Exception {
  final String message;
  CacheException([this.message = 'Cache error']);
}
