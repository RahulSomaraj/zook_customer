import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/product.dart';
import '../entities/product_detail.dart';

/// Source of marketplace listings (live API).
abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getRecentlyListed();
  Future<Either<Failure, List<Product>>> getTopPicks();
  Future<Either<Failure, List<Product>>> getByCategory(String categoryId,
      {String sort});
  Future<Either<Failure, List<Product>>> search(String query, {String sort});
  Future<Either<Failure, ProductDetail>> getProductDetail(String id);
}
