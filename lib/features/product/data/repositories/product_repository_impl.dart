import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_detail.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';

/// Live products repository. `recently-listed`, `top-picks` and category
/// browse hit the API. Search reuses the recently-listed feed (filtered
/// client-side) until a dedicated endpoint exists.
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Product>>> getRecentlyListed() =>
      _guard(remoteDataSource.getRecentlyListed);

  @override
  Future<Either<Failure, List<Product>>> getTopPicks() =>
      _guard(remoteDataSource.getTopPicks);

  @override
  Future<Either<Failure, List<Product>>> getByCategory(String categoryId) =>
      _guard(() => remoteDataSource.getByCategory(categoryId));

  @override
  Future<Either<Failure, ProductDetail>> getProductDetail(String id) async {
    try {
      return Right(await remoteDataSource.getProductDetail(id));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Product>>> search(String query) =>
      _guard(() async {
        final items = await remoteDataSource.getRecentlyListed();
        final q = query.toLowerCase().trim();
        if (q.isEmpty) return items;
        return items
            .where((p) =>
                p.name.toLowerCase().contains(q) ||
                p.brand.toLowerCase().contains(q))
            .toList();
      });

  Future<Either<Failure, List<Product>>> _guard(
    Future<List<Product>> Function() action,
  ) async {
    try {
      return Right(await action());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }
}
