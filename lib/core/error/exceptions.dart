/// Low-level exceptions thrown by data sources. Repositories catch these and
/// convert them into [Failure]s.
class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Server error']);
}

class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'Network error']);
}

class CacheException implements Exception {
  final String message;
  CacheException([this.message = 'Cache error']);
}
