import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/category_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final DioClient client;
  CategoryRemoteDataSourceImpl({required this.client});

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final res = await client.dio.get(ApiConstants.categories);
      final map = (res.data as Map).cast<String, dynamic>();
      if (map['success'] == true && map['data'] is List) {
        return (map['data'] as List)
            .map((e) => CategoryModel.fromJson((e as Map).cast<String, dynamic>()))
            .toList();
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
    return 'Failed to load categories.';
  }
}
