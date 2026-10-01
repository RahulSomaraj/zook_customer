import '../constants/api_constants.dart';
import '../network/dio_client.dart';
import 'country.dart';

/// Public `GET /countries` — active countries, default first.
class CountriesRemoteDataSource {
  final DioClient client;
  CountriesRemoteDataSource({required this.client});

  Future<List<Country>> getCountries() async {
    final res = await client.dio.get(ApiConstants.countries);
    final body = res.data;
    final data = body is Map ? body['data'] : body;
    final list = data is List
        ? data
        : (data is Map && data['items'] is List ? data['items'] as List : const []);
    return [
      for (final e in list)
        if (e is Map) Country.fromJson(e.cast<String, dynamic>()),
    ].where((c) => c.iso2.isNotEmpty).toList();
  }
}
