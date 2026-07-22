import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/address_model.dart';

abstract class AddressRemoteDataSource {
  /// Creates a new customer address. `POST /customers/addresses`.
  Future<AddressModel> create(AddressModel address);

  /// Lists the customer's saved addresses. `GET /customers/addresses`.
  Future<List<AddressModel>> getAddresses();

  /// Removes an address. `DELETE /customers/addresses/{id}`.
  Future<void> delete(String id);
}

class AddressRemoteDataSourceImpl implements AddressRemoteDataSource {
  final DioClient client;
  AddressRemoteDataSourceImpl({required this.client});

  @override
  Future<AddressModel> create(AddressModel address) async {
    try {
      final res = await client.dio.post(
        ApiConstants.addresses,
        data: address.toJson(),
      );
      final map = (res.data as Map).cast<String, dynamic>();
      final data = _unwrap(map);
      // Prefer the server echo (has the new id); fall back to what we sent.
      if (data != null) return AddressModel.fromJson(data);
      return address;
    } on DioException catch (e) {
      throw _asServerException(e);
    }
  }

  @override
  Future<List<AddressModel>> getAddresses() async {
    try {
      final res = await client.dio.get(ApiConstants.addresses);

      // Dio usually decodes JSON, but tolerate a raw string body too.
      final decoded =
          res.data is String ? jsonDecode(res.data as String) : res.data;
      if (decoded is! Map) return const [];
      final map = decoded.cast<String, dynamic>();

      // Find the items list across the shapes we might get:
      //   { data: { items: [...] } }  |  { data: [...] }  |  { items: [...] }
      final data = map['data'];
      List rawItems = const [];
      if (data is Map && data['items'] is List) {
        rawItems = data['items'] as List;
      } else if (data is List) {
        rawItems = data;
      } else if (map['items'] is List) {
        rawItems = map['items'] as List;
      }

      final out = <AddressModel>[];
      for (final e in rawItems) {
        if (e is Map) {
          try {
            out.add(AddressModel.fromJson(e.cast<String, dynamic>()));
          } catch (err) {
            debugPrint('Skipping unparsable address: $err');
          }
        }
      }
      debugPrint(
          'getAddresses: status=${res.statusCode} rawItems=${rawItems.length} '
          'parsed=${out.length} authHeader='
          '${res.requestOptions.headers['Authorization'] != null}');
      return out;
    } on DioException catch (e) {
      throw _asServerException(e);
    } catch (e, st) {
      // Surface parse errors instead of silently returning nothing.
      debugPrint('getAddresses parse error: $e\n$st');
      throw ServerException('Could not read addresses: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      final res = await client.dio.delete(ApiConstants.addressItem(id));
      final data = res.data;
      if (data is Map && data['success'] == false) {
        throw ServerException(_messageFrom(data.cast<String, dynamic>()));
      }
    } on DioException catch (e) {
      throw _asServerException(e);
    }
  }

  /// Returns the `data` object for a `{success, data}` envelope, or the map
  /// itself when the API returns the address directly.
  Map<String, dynamic>? _unwrap(Map<String, dynamic> map) {
    if (map['success'] == false) throw ServerException(_messageFrom(map));
    final data = map['data'];
    if (data is Map) return data.cast<String, dynamic>();
    if (map.containsKey('id') || map.containsKey('line1')) return map;
    return null;
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
    return 'Could not save the address.';
  }
}
