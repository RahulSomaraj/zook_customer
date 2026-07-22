import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/cart_item_model.dart';

/// Server-synced cart. Endpoints per api_spec.md §5:
///   GET    /cart                     → cart with items
///   POST   /cart/items               → { productId, quantity }  (add/increment)
///   PATCH  /cart/items/{productId}   → { quantity }             (set quantity)
///   DELETE /cart/items/{productId}   → remove line
///   DELETE /cart                     → clear cart
abstract class CartRemoteDataSource {
  Future<List<CartItemModel>> getCart();
  Future<void> addItem(String productId, int quantity);
  Future<void> updateItem(String productId, int quantity);
  Future<void> removeItem(String productId);
  Future<void> clearCart();
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final DioClient client;
  CartRemoteDataSourceImpl({required this.client});

  @override
  Future<List<CartItemModel>> getCart() async {
    try {
      final res = await client.dio.get(ApiConstants.cart);
      final decoded =
          res.data is String ? jsonDecode(res.data as String) : res.data;
      if (decoded is! Map) return const [];
      final map = decoded.cast<String, dynamic>();

      // items can live at data.items, data (list), or items.
      final data = map['data'];
      List rawItems = const [];
      if (data is Map && data['items'] is List) {
        rawItems = data['items'] as List;
      } else if (data is List) {
        rawItems = data;
      } else if (map['items'] is List) {
        rawItems = map['items'] as List;
      }

      final out = <CartItemModel>[];
      for (final e in rawItems) {
        if (e is Map) {
          try {
            out.add(CartItemModel.fromJson(e.cast<String, dynamic>()));
          } catch (err) {
            debugPrint('Skipping unparsable cart line: $err');
          }
        }
      }
      debugPrint('getCart: status=${res.statusCode} items=${out.length}');
      return out;
    } on DioException catch (e) {
      throw _asServerException(e);
    } catch (e) {
      throw ServerException('Could not read the cart: $e');
    }
  }

  @override
  Future<void> addItem(String productId, int quantity) => _send(
        () => client.dio.post(
          ApiConstants.cartItems,
          data: {'productId': productId, 'quantity': quantity},
        ),
      );

  @override
  Future<void> updateItem(String productId, int quantity) => _send(
        () => client.dio.patch(
          ApiConstants.cartItem(productId),
          data: {'quantity': quantity},
        ),
      );

  @override
  Future<void> removeItem(String productId) =>
      _send(() => client.dio.delete(ApiConstants.cartItem(productId)));

  @override
  Future<void> clearCart() => _send(() => client.dio.delete(ApiConstants.cart));

  /// Runs a mutating request and normalises errors / `success:false`.
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
    if (msg is List && msg.isNotEmpty) return msg.first.toString();
    return 'Could not update your cart.';
  }
}
