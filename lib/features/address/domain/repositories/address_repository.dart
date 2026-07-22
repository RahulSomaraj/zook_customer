import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/address.dart';

/// Manages the customer's saved delivery addresses (live API).
abstract class AddressRepository {
  Future<Either<Failure, Address>> create(Address address);
  Future<Either<Failure, List<Address>>> getAddresses();
  Future<Either<Failure, Unit>> delete(String id);
}
