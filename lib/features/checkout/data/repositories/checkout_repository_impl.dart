import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../orders/domain/entities/customer_order.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/repositories/checkout_repository.dart';
import '../datasources/checkout_remote_data_source.dart';

class CheckoutRepositoryImpl implements CheckoutRepository {
  final CheckoutRemoteDataSource remoteDataSource;
  CheckoutRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, CustomerOrder>> checkout({
    required String addressId,
    required PaymentMethod paymentMethod,
  }) async {
    try {
      return Right(await remoteDataSource.checkout(
        addressId: addressId,
        paymentMethod: paymentMethod,
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, null, e.code));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }
}
