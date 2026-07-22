import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';

/// Talks to the wishlist endpoints:
/// - POST   `/wishlist/{productId}` → add
/// - DELETE `/wishlist/{productId}` → remove
abstract class WishlistRemoteDataSource {
  Future<void> add(String productId);
  Future<void> remove(String productId);
}

class WishlistRemoteDataSourceImpl implements WishlistRemoteDataSource {
  final DioClient client;
  WishlistRemoteDataSourceImpl({required this.client});

  @override
  Future<void> add(String productId) =>
      _send(() => client.dio.post(ApiConstants.wishlistItem(productId)));

  @override
  Future<void> remove(String productId) =>
      _send(() => client.dio.delete(ApiConstants.wishlistItem(productId)));

  /// Runs [request] and normalises Dio/server errors into [ServerException].
  Future<void> _send(Future<Response> Function() request) async {
    try {
      final res = await request();
      final data = res.data;
      // Endpoints return 204 (no body) on success; when a body is present,
      // honour an explicit `success: false`.
      if (data is Map && data['success'] == false) {
        throw ServerException(_messageFrom(data.cast<String, dynamic>()));
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map) {
        throw ServerException(_messageFrom(data.cast<String, dynamic>()));
      }
      throw ServerException(e.message ?? 'Network error. Please try again.');
    }
  }

  String _messageFrom(Map<String, dynamic> map) {
    final msg = map['message'] ?? map['error'];
    if (msg is String) return msg;
    return 'Could not update your wishlist.';
  }
}
