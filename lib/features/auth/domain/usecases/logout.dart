import '../repositories/auth_repository.dart';

/// Clears the stored session (access/refresh tokens).
class Logout {
  final AuthRepository repository;
  Logout(this.repository);

  Future<void> call() => repository.logout();
}
