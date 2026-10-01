import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/cart_item_model.dart';

/// Server-synced cart (zook_backend `customers/cart`):
///   GET    /customers/cart               → cart with items
///   POST   /customers/cart/items         → { productId, quantity } (add/increment)
///   PATCH  /customers/cart/items/{id}    → { quantity }            (set quantity)
///   DELETE /customers/cart/items/{id}    → remove line
///   DELETE /customers/cart               → clear cart
///
/// NOTE: `{id}` is the cart LINE id (`items[].id`), not the product id. Every
/// cart endpoint returns the full cart, so this data source keeps a
/// productId → line id map from the latest response. Callers stay
/// productId-based.
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

  /// productId → cart line id, rebuilt from every cart response.
  final Map<String, String> _lineIds = {};

  @override
  Future<List<CartItemModel>> getCart() async {
    try {
      final res = await client.dio.get(ApiConstants.cart);
      return _parseCart(res.data);
    } on DioException catch (e) {
      throw _asServerException(e);
    } catch (e) {
      throw ServerException('Could not read the cart: $e');
    }
  }

  /// Parses a cart response body and refreshes [_lineIds].
  List<CartItemModel> _parseCart(dynamic body) {
    final decoded = body is String ? jsonDecode(body) : body;
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
    _lineIds.clear();
    for (final e in rawItems) {
      if (e is Map) {
        try {
          final line = e.cast<String, dynamic>();
          final model = CartItemModel.fromJson(line);
          out.add(model);
          final lineId = line['id']?.toString();
          if (lineId != null && lineId.isNotEmpty && line['product'] is Map) {
            _lineIds[model.product.id] = lineId;
          }
        } catch (err) {
          debugPrint('Skipping unparsable cart line: $err');
        }
      }
    }
    return out;
  }

  /// Resolves the cart line id for [productId], re-fetching the cart once if
  /// it isn't known yet (e.g. the add is still in flight or was never synced).
  Future<String?> _lineIdFor(String productId) async {
    final known = _lineIds[productId];
    if (known != null) return known;
    await getCart();
    return _lineIds[productId];
  }

  @override
  Future<void> addItem(String productId, int quantity) => _send(
        () => client.dio.post(
          ApiConstants.cartItems,
          data: {'productId': productId, 'quantity': quantity},
        ),
      );

  @override
  Future<void> updateItem(String productId, int quantity) async {
    final lineId = await _lineIdFor(productId);
    if (lineId == null) {
      // Not in the server cart (e.g. the add failed) — add it with the target
      // quantity instead so the server converges to the local cart.
      return addItem(productId, quantity);
    }
    return _send(
      () => client.dio.patch(
        ApiConstants.cartItem(lineId),
        data: {'quantity': quantity},
      ),
    );
  }

  @override
  Future<void> removeItem(String productId) async {
    final lineId = await _lineIdFor(productId);
    if (lineId == null) return; // already absent server-side
    return _send(() => client.dio.delete(ApiConstants.cartItem(lineId)));
  }

  @override
  Future<void> clearCart() async {
    await _send(() => client.dio.delete(ApiConstants.cart));
    _lineIds.clear();
  }

  /// Runs a mutating request, normalises errors / `success:false`, and
  /// refreshes the line-id map from the returned cart.
  Future<void> _send(Future<Response> Function() request) async {
    try {
      final res = await request();
      final data = res.data;
      if (data is Map && data['success'] == false) {
        final map = data.cast<String, dynamic>();
        throw ServerException(_messageFrom(map), null, map['code']?.toString());
      }
      if (data is Map && data['data'] is Map) _parseCart(data);
    } on DioException catch (e) {
      throw _asServerException(e);
    }
  }

  ServerException _asServerException(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final map = data.cast<String, dynamic>();
      return ServerException(_messageFrom(map), null, map['code']?.toString());
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
