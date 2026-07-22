import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/cart_item.dart';

/// Server-synced cart operations (live API).
abstract class CartRepository {
  Future<Either<Failure, List<CartItem>>> getCart();
  Future<Either<Failure, Unit>> addItem(String productId, int quantity);
  Future<Either<Failure, Unit>> updateItem(String productId, int quantity);
  Future<Either<Failure, Unit>> removeItem(String productId);
  Future<Either<Failure, Unit>> clearCart();
}
