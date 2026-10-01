import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/address.dart';
import '../../domain/repositories/address_repository.dart';
import '../datasources/address_remote_data_source.dart';
import '../models/address_model.dart';

class AddressRepositoryImpl implements AddressRepository {
  final AddressRemoteDataSource remoteDataSource;
  AddressRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Address>> create(Address address) async {
    try {
      final created =
          await remoteDataSource.create(AddressModel.fromEntity(address));
      return Right(created);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> delete(String id) async {
    try {
      await remoteDataSource.delete(id);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Address>>> getAddresses() async {
    try {
      final models = await remoteDataSource.getAddresses();
      // Return a true List<Address> (not List<AddressModel>) so downstream
      // generic ops like firstWhere(orElse:) don't hit a covariance error.
      return Right(List<Address>.from(models));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> update(Address address) => _guard(() {
        // toJson omits empty optionals; on PATCH that would keep the old
        // value, so send explicit nulls to clear fields the user emptied.
        final json = AddressModel.fromEntity(address).toJson();
        for (final key in const ['line2', 'postalCode', 'landmark']) {
          json.putIfAbsent(key, () => null);
        }
        return remoteDataSource.update(address.id!, json);
      });

  @override
  Future<Either<Failure, Unit>> setDefault(String id) =>
      _guard(() => remoteDataSource.update(id, {'isDefault': true}));

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
