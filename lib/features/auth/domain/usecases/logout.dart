import '../repositories/auth_repository.dart';

/// Revokes the session server-side, then clears the stored tokens.
class Logout {
  final AuthRepository repository;
  Logout(this.repository);

  Future<void> call() => repository.logout();
}
