import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_detail.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';

/// Live products repository. Every listing (home "recently listed" / "top
/// picks", category browse and search) is served by the single `/products`
/// endpoint with context-appropriate query params.
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Product>>> getRecentlyListed() =>
      _guard(() => remoteDataSource.getProducts(sort: 'recent', limit: 20));

  @override
  Future<Either<Failure, List<Product>>> getTopPicks() =>
      _guard(() => remoteDataSource.getProducts(sort: 'top_picks', limit: 20));

  @override
  Future<Either<Failure, List<Product>>> getByCategory(String categoryId,
          {String sort = 'recent'}) =>
      _guard(() => remoteDataSource.getProducts(
            categoryId: categoryId,
            sort: sort,
            limit: 20,
          ));

  @override
  Future<Either<Failure, List<Product>>> search(String query,
          {String sort = 'recent'}) =>
      _guard(() => remoteDataSource.getProducts(
            search: query,
            sort: sort,
            limit: 20,
          ));

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
