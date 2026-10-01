import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../orders/data/models/order_model.dart';
import '../../../orders/domain/entities/customer_order.dart';
import '../../domain/entities/payment_method.dart';

abstract class CheckoutRemoteDataSource {
  Future<CustomerOrder> checkout({
    required String addressId,
    required PaymentMethod paymentMethod,
  });
}

class CheckoutRemoteDataSourceImpl implements CheckoutRemoteDataSource {
  final DioClient client;
  CheckoutRemoteDataSourceImpl({required this.client});

  @override
  Future<CustomerOrder> checkout({
    required String addressId,
    required PaymentMethod paymentMethod,
  }) async {
    try {
      final res = await client.dio.post(
        ApiConstants.checkout,
        data: {'addressId': addressId, 'paymentMethod': paymentMethod.apiValue},
      );
      final map = (res.data as Map).cast<String, dynamic>();
      if (map['success'] == true && map['data'] is Map) {
        return OrderModel.fromJson((map['data'] as Map).cast<String, dynamic>());
      }
      throw ServerException(_message(map), null, map['code']?.toString());
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map) {
        final map = data.cast<String, dynamic>();
        throw ServerException(_message(map), null, map['code']?.toString());
      }
      throw ServerException(e.message ?? 'Network error. Please try again.');
    }
  }

  String _message(Map<String, dynamic> map) {
    final msg = map['message'] ?? map['error'];
    if (msg is String) return msg;
    if (msg is List && msg.isNotEmpty) return msg.first.toString();
    return 'Could not place your order. Please try again.';
  }
}
