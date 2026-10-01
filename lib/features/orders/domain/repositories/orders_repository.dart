import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/customer_order.dart';
import '../entities/orders_page_result.dart';
import '../entities/shipment_tracking.dart';

abstract class OrdersRepository {
  Future<Either<Failure, OrdersPageResult>> getOrders({
    OrderFilter filter = OrderFilter.all,
    int page = 1,
  });

  Future<Either<Failure, CustomerOrder>> getOrder(String orderId);

  /// Right(null) = not handed to the courier yet.
  Future<Either<Failure, ShipmentTracking?>> getTracking(
      String orderId, String subOrderId);
}
