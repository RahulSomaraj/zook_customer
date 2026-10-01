import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../orders/domain/entities/customer_order.dart';
import '../entities/payment_method.dart';

abstract class CheckoutRepository {
  /// Converts the SERVER cart into an order. Callers must sync the local cart
  /// to the server first (see CartCubit.syncToServer).
  Future<Either<Failure, CustomerOrder>> checkout({
    required String addressId,
    required PaymentMethod paymentMethod,
  });
}
