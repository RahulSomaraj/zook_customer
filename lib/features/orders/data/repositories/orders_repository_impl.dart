import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/customer_order.dart';
import '../../domain/entities/orders_page_result.dart';
import '../../domain/entities/shipment_tracking.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_remote_data_source.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersRemoteDataSource remoteDataSource;
  OrdersRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, OrdersPageResult>> getOrders({
    OrderFilter filter = OrderFilter.all,
    int page = 1,
  }) =>
      _guard(() => remoteDataSource.getOrders(filter: filter, page: page));

  @override
  Future<Either<Failure, CustomerOrder>> getOrder(String orderId) =>
      _guard(() => remoteDataSource.getOrder(orderId));

  @override
  Future<Either<Failure, ShipmentTracking?>> getTracking(
          String orderId, String subOrderId) =>
      _guard(() => remoteDataSource.getTracking(orderId, subOrderId));

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, null, e.code));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }
}
