import '../constants/api_constants.dart';
import '../network/dio_client.dart';

/// `GET/PATCH /customers/me/settings` — currently just the app language, which
/// the backend uses for localized push notifications and emails.
class SettingsRemoteDataSource {
  final DioClient client;
  SettingsRemoteDataSource({required this.client});

  Future<void> updateLanguage(String languageCode) async {
    await client.dio.patch(
      ApiConstants.customerSettings,
      data: {'language': languageCode},
    );
  }
}
