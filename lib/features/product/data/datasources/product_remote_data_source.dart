import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/product_detail_model.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  /// Single products listing endpoint used everywhere (home feeds, category
  /// browse, search). Callers pass whichever filters apply to their context.
  Future<List<ProductModel>> getProducts({
    int page,
    int limit,
    String? sort, // recent | oldest | price_low | price_high | top_picks
    String? categoryId,
    num? minPrice,
    num? maxPrice,
    String? search,
  });

  Future<ProductDetailModel> getProductDetail(String id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final DioClient client;
  ProductRemoteDataSourceImpl({required this.client});

  @override
  Future<List<ProductModel>> getProducts({
    int page = 1,
    int limit = 20,
    String? sort,
    String? categoryId,
    num? minPrice,
    num? maxPrice,
    String? search,
  }) {
    final query = <String, dynamic>{'page': page, 'limit': limit};
    if (sort != null && sort.isNotEmpty) query['sort'] = sort;
    if (categoryId != null && categoryId.isNotEmpty) {
      query['category_id'] = categoryId;
    }
    if (minPrice != null) query['min_price'] = minPrice;
    if (maxPrice != null) query['max_price'] = maxPrice;
    final q = search?.trim() ?? '';
    if (q.isNotEmpty) query['search'] = q;
    return _fetchItems(ApiConstants.products, query: query);
  }

  @override
  Future<ProductDetailModel> getProductDetail(String id) async {
    try {
      final res = await client.dio.get('${ApiConstants.products}/$id');
      final map = _asMap(res.data);
      if (map['success'] == true && map['data'] != null) {
        return ProductDetailModel.fromJson(
            (map['data'] as Map).cast<String, dynamic>());
      }
      throw ServerException(_messageFrom(map));
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map) {
        throw ServerException(_messageFrom(data.cast<String, dynamic>()));
      }
      throw ServerException(e.message ?? 'Network error. Please try again.');
    }
  }

  /// GETs [path] and parses `data.items` into [ProductModel]s.
  Future<List<ProductModel>> _fetchItems(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    try {
      final res = await client.dio.get(path, queryParameters: query);
      final map = _asMap(res.data);
      if (map['success'] == true && map['data'] != null) {
        final data = (map['data'] as Map).cast<String, dynamic>();
        final items = (data['items'] as List?) ?? const [];
        return [
          for (var i = 0; i < items.length; i++)
            ProductModel.fromJson(
              (items[i] as Map).cast<String, dynamic>(),
              gradientIndex: i,
            ),
        ];
      }
      throw ServerException(_messageFrom(map));
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map) {
        throw ServerException(_messageFrom(data.cast<String, dynamic>()));
      }
      throw ServerException(e.message ?? 'Network error. Please try again.');
    }
  }

  /// Decodes a response body that may arrive as a Map or a raw JSON string.
  Map<String, dynamic> _asMap(dynamic raw) {
    final decoded = raw is String ? jsonDecode(raw) : raw;
    return (decoded as Map).cast<String, dynamic>();
  }

  String _messageFrom(Map<String, dynamic> map) {
    final msg = map['message'] ?? map['error'];
    if (msg is String) return msg;
    return 'Failed to load products.';
  }
}
