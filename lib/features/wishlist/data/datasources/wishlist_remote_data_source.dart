import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../product/data/models/product_model.dart';

/// Talks to the wishlist endpoints:
/// - GET    `/wishlist`             → { items: [Product] }
/// - POST   `/wishlist/{productId}` → add
/// - DELETE `/wishlist/{productId}` → remove
abstract class WishlistRemoteDataSource {
  Future<List<ProductModel>> getWishlist();
  Future<void> add(String productId);
  Future<void> remove(String productId);
}

class WishlistRemoteDataSourceImpl implements WishlistRemoteDataSource {
  final DioClient client;
  WishlistRemoteDataSourceImpl({required this.client});

  @override
  Future<List<ProductModel>> getWishlist() async {
    try {
      final res = await client.dio.get(ApiConstants.wishlist);
      final decoded =
          res.data is String ? jsonDecode(res.data as String) : res.data;
      if (decoded is! Map) return const [];
      final map = decoded.cast<String, dynamic>();

      // items may live at data.items, data (list), or items.
      final data = map['data'];
      List raw = const [];
      if (data is Map && data['items'] is List) {
        raw = data['items'] as List;
      } else if (data is List) {
        raw = data;
      } else if (map['items'] is List) {
        raw = map['items'] as List;
      }

      final out = <ProductModel>[];
      for (var i = 0; i < raw.length; i++) {
        final e = raw[i];
        if (e is! Map) continue;
        final line = e.cast<String, dynamic>();
        // A wishlist row may be a bare Product or `{ product: {...} }`.
        final prod = line['product'] is Map
            ? (line['product'] as Map).cast<String, dynamic>()
            : line;
        try {
          out.add(ProductModel.fromJson(prod, gradientIndex: i));
        } catch (err) {
          debugPrint('Skipping unparsable wishlist line: $err');
        }
      }
      return out;
    } on DioException catch (e) {
      throw _asServerException(e);
    } catch (e) {
      throw ServerException('Could not read your wishlist: $e');
    }
  }

  @override
  Future<void> add(String productId) =>
      _send(() => client.dio.post(ApiConstants.wishlistItem(productId)));

  @override
  Future<void> remove(String productId) =>
      _send(() => client.dio.delete(ApiConstants.wishlistItem(productId)));

  Future<void> _send(Future<Response> Function() request) async {
    try {
      final res = await request();
      final data = res.data;
      if (data is Map && data['success'] == false) {
        throw ServerException(_messageFrom(data.cast<String, dynamic>()));
      }
    } on DioException catch (e) {
      throw _asServerException(e);
    }
  }

  ServerException _asServerException(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      return ServerException(_messageFrom(data.cast<String, dynamic>()));
    }
    return ServerException(e.message ?? 'Network error. Please try again.');
  }

  String _messageFrom(Map<String, dynamic> map) {
    final msg = map['message'] ?? map['error'];
    if (msg is String) return msg;
    return 'Could not update your wishlist.';
  }
}
