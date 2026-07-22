import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';

/// Adds/removes products from the signed-in user's wishlist (live API).
abstract class WishlistRepository {
  Future<Either<Failure, Unit>> add(String productId);
  Future<Either<Failure, Unit>> remove(String productId);
}
