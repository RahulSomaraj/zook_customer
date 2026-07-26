import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../product/domain/entities/product.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../datasources/wishlist_remote_data_source.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  final WishlistRemoteDataSource remoteDataSource;
  WishlistRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Product>>> getWishlist() async {
    try {
      final items = await remoteDataSource.getWishlist();
      return Right(List<Product>.from(items));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> add(String productId) =>
      _guard(() => remoteDataSource.add(productId));

  @override
  Future<Either<Failure, Unit>> remove(String productId) =>
      _guard(() => remoteDataSource.remove(productId));

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
