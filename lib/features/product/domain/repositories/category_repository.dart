import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/category.dart';

/// Source of browse categories (home pills / category header).
abstract class CategoryRepository {
  Future<Either<Failure, List<ShopCategory>>> getCategories();
}
