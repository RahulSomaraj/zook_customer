import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';

/// Backend `PolicyType` values.
enum PolicyType { termsAndConditions, privacyPolicy }

extension PolicyTypeX on PolicyType {
  String get apiValue => switch (this) {
        PolicyType.termsAndConditions => 'terms_and_conditions',
        PolicyType.privacyPolicy => 'privacy_policy',
      };

  String get title => switch (this) {
        PolicyType.termsAndConditions => 'Terms & Conditions',
        PolicyType.privacyPolicy => 'Privacy Policy',
      };

  static PolicyType? fromApi(String value) {
    for (final t in PolicyType.values) {
      if (t.apiValue == value) return t;
    }
    return null;
  }
}

class Policy {
  final String body;
  final DateTime? updatedAt;
  const Policy({required this.body, this.updatedAt});
}

/// Public `GET /policies/{type}` — the active legal document of that type.
class PoliciesRemoteDataSource {
  final DioClient client;
  PoliciesRemoteDataSource({required this.client});

  Future<Policy> get(PolicyType type) async {
    final res = await client.dio.get(ApiConstants.policy(type.apiValue));
    final body = res.data;
    final data = (body is Map && body['data'] is Map ? body['data'] : body) as Map;
    return Policy(
      body: (data['body'] ?? '').toString(),
      updatedAt: DateTime.tryParse(data['updatedAt']?.toString() ?? '')?.toLocal(),
    );
  }
}
