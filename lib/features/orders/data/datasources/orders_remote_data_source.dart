import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/customer_order.dart';
import '../../domain/entities/orders_page_result.dart';
import '../../domain/entities/shipment_tracking.dart';
import '../models/order_model.dart';

abstract class OrdersRemoteDataSource {
  /// `GET /customers/orders?status=&page=&limit=` — newest first.
  Future<OrdersPageResult> getOrders({
    OrderFilter filter = OrderFilter.all,
    int page = 1,
    int limit = 20,
  });

  Future<CustomerOrder> getOrder(String orderId);

  /// Null when the parcel hasn't been handed to the courier yet
  /// (API 409 `SHIPMENT_NOT_CREATED`).
  Future<ShipmentTracking?> getTracking(String orderId, String subOrderId);
}

class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  final DioClient client;
  OrdersRemoteDataSourceImpl({required this.client});

  @override
  Future<OrdersPageResult> getOrders({
    OrderFilter filter = OrderFilter.all,
    int page = 1,
    int limit = 20,
  }) async {
    final data = await _get(ApiConstants.orders, query: {
      'status': filter.name,
      'page': page,
      'limit': limit,
    });
    final items = (data['items'] as List?) ?? const [];
    final meta = (data['meta'] as Map?)?.cast<String, dynamic>() ?? const {};
    final rawCounts = (data['counts'] as Map?)?.cast<String, dynamic>() ?? const {};
    return OrdersPageResult(
      items: [
        for (final e in items)
          if (e is Map) OrderModel.fromJson(e.cast<String, dynamic>()),
      ],
      page: (meta['page'] as num?)?.toInt() ?? page,
      totalPages: (meta['totalPages'] as num?)?.toInt() ?? 1,
      counts: {
        for (final f in OrderFilter.values)
          f: (rawCounts[f.name] as num?)?.toInt() ?? 0,
      },
    );
  }

  @override
  Future<CustomerOrder> getOrder(String orderId) async {
    final data = await _get(ApiConstants.order(orderId));
    return OrderModel.fromJson(data);
  }

  @override
  Future<ShipmentTracking?> getTracking(
      String orderId, String subOrderId) async {
    try {
      final data = await _get(ApiConstants.subOrderTracking(orderId, subOrderId));
      return ShipmentTracking.fromJson(data);
    } on ServerException catch (e) {
      if (e.code == 'SHIPMENT_NOT_CREATED') return null;
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    try {
      final res = await client.dio.get(path, queryParameters: query);
      final map = (res.data as Map).cast<String, dynamic>();
      if (map['success'] == true && map['data'] is Map) {
        return (map['data'] as Map).cast<String, dynamic>();
      }
      throw ServerException(_message(map), null, map['code']?.toString());
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map) {
        final map = data.cast<String, dynamic>();
        final code = map['code']?.toString();
        // Unknown route (no API code) = server doesn't have this endpoint yet;
        // don't show Nest's raw "Cannot GET /api/..." to customers.
        if (e.response?.statusCode == 404 && code == null) {
          throw ServerException(
              "Orders aren't available right now. Please try again later.");
        }
        throw ServerException(_message(map), null, code);
      }
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw ServerException('No connection. Check your internet and retry.');
      }
      throw ServerException(e.message ?? 'Network error. Please try again.');
    }
  }

  String _message(Map<String, dynamic> map) {
    final msg = map['message'] ?? map['error'];
    if (msg is String) return msg;
    if (msg is List && msg.isNotEmpty) return msg.first.toString();
    return 'Could not load your order.';
  }
}
