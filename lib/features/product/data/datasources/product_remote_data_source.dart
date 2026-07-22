import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/product_detail_model.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getRecentlyListed();
  Future<List<ProductModel>> getTopPicks();
  Future<List<ProductModel>> getByCategory(String categoryId);
  Future<ProductDetailModel> getProductDetail(String id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final DioClient client;
  ProductRemoteDataSourceImpl({required this.client});

  @override
  Future<List<ProductModel>> getRecentlyListed() =>
      _fetchItems(ApiConstants.recentlyListed);

  @override
  Future<List<ProductModel>> getTopPicks() =>
      _fetchItems(ApiConstants.topPicks);

  @override
  Future<List<ProductModel>> getByCategory(String categoryId) => _fetchItems(
        ApiConstants.products,
        query: {'category_id': categoryId},
      );

  @override
  Future<ProductDetailModel> getProductDetail(String id) async {
    try {
      final res = await client.dio.get('${ApiConstants.products}/$id');
      final map = (res.data as Map).cast<String, dynamic>();
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
      final map = (res.data as Map).cast<String, dynamic>();
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

  String _messageFrom(Map<String, dynamic> map) {
    final msg = map['message'] ?? map['error'];
    if (msg is String) return msg;
    return 'Failed to load products.';
  }
}
