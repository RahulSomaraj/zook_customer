import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_remote_data_source.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remoteDataSource;
  CartRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<CartItem>>> getCart() async {
    try {
      final items = await remoteDataSource.getCart();
      // Return a true List<CartItem> (not List<CartItemModel>) to avoid
      // generic covariance surprises downstream.
      return Right(List<CartItem>.from(items));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> addItem(String productId, int quantity) =>
      _guard(() => remoteDataSource.addItem(productId, quantity));

  @override
  Future<Either<Failure, Unit>> updateItem(String productId, int quantity) =>
      _guard(() => remoteDataSource.updateItem(productId, quantity));

  @override
  Future<Either<Failure, Unit>> removeItem(String productId) =>
      _guard(() => remoteDataSource.removeItem(productId));

  @override
  Future<Either<Failure, Unit>> clearCart() =>
      _guard(remoteDataSource.clearCart);

  Future<Either<Failure, Unit>> _guard(Future<void> Function() action) async {
    try {
      await action();
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }
}
