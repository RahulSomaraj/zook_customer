import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../product/domain/entities/product.dart';

/// Reads and mutates the signed-in user's wishlist (live API).
abstract class WishlistRepository {
  Future<Either<Failure, List<Product>>> getWishlist();
  Future<Either<Failure, Unit>> add(String productId);
  Future<Either<Failure, Unit>> remove(String productId);
}
