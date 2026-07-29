import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/auth_user_model.dart';

abstract class AuthRemoteDataSource {
  /// Registers a new customer. Throws [ServerException] on failure.
  Future<void> register({
    required String fullName,
    required String email,
    required String countryCode,
    required String phone,
  });

  /// Requests an OTP for [phone]. Returns the dev code when the API includes
  /// one (UAT convenience), otherwise null.
  Future<String?> sendOtp(String phone);

  Future<AuthUserModel> verifyOtp({
    required String phone,
    required String code,
  });

  /// Exchanges a Supabase access token (from native Google sign-in via the
  /// Supabase SDK) for our own session tokens.
  Future<AuthUserModel> socialGoogle(String supabaseAccessToken);

  /// Sends an OTP to attach [phone] to the CURRENT authenticated user.
  /// Returns the dev code when provided (UAT), otherwise null.
  Future<String?> sendPhoneAttachOtp(String phone);

  /// Verifies the attach OTP; on success the API sets phone + phoneVerified
  /// on the current user.
  Future<void> verifyPhoneAttach({
    required String phone,
    required String code,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient client;
  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<void> register({
    required String fullName,
    required String email,
    required String countryCode,
    required String phone,
  }) async {
    try {
      final res = await client.dio.post(ApiConstants.register, data: {
        'fullName': fullName,
        'email': email,
        'countryCode': countryCode,
        'phone': phone,
      });
      final map = (res.data as Map).cast<String, dynamic>();
      if (map['success'] == true) return;
      throw ServerException(_messageFrom(map));
    } on DioException catch (e) {
      final resData = e.response?.data;
      if (resData is Map) {
        throw ServerException(_messageFrom(resData.cast<String, dynamic>()));
      }
      throw ServerException(e.message ?? 'Network error. Please try again.');
    }
  }

  @override
  Future<String?> sendOtp(String phone) async {
    final data = await _post(ApiConstants.sendOtp, {'phone': phone});
    return data['devCode'] as String?;
  }

  @override
  Future<AuthUserModel> verifyOtp({
    required String phone,
    required String code,
  }) async {
    final data = await _post(
      ApiConstants.verifyOtp,
      {'phone': phone, 'code': code},
    );
    return AuthUserModel.fromVerifyData(data, phone: phone);
  }

  @override
  Future<AuthUserModel> socialGoogle(String supabaseAccessToken) async {
    final data = await _post(
      ApiConstants.socialGoogle,
      {'supabaseAccessToken': supabaseAccessToken},
    );
    // Same `{ tokens: { ..., user } }` shape as verifyOtp. Social users may
    // have no phone yet — checkout will prompt for one.
    return AuthUserModel.fromVerifyData(data, phone: '');
  }

  @override
  Future<String?> sendPhoneAttachOtp(String phone) async {
    final data = await _post(ApiConstants.phoneAttachSend, {'phone': phone});
    return data['devCode'] as String?;
  }

  @override
  Future<void> verifyPhoneAttach({
    required String phone,
    required String code,
  }) async {
    await _post(ApiConstants.phoneAttachVerify, {'phone': phone, 'code': code});
  }

  /// POSTs [body] and returns the unwrapped `data` object, throwing a
  /// [ServerException] on transport errors or `success: false` responses.
  Future<Map<String, dynamic>> _post(
      String path, Map<String, dynamic> body) async {
    try {
      final res = await client.dio.post(path, data: body);
      final map = (res.data as Map).cast<String, dynamic>();
      if (map['success'] == true && map['data'] != null) {
        return (map['data'] as Map).cast<String, dynamic>();
      }
      throw ServerException(_messageFrom(map), _retryAfterFrom(map));
    } on DioException catch (e) {
      final resData = e.response?.data;
      if (resData is Map) {
        final map = resData.cast<String, dynamic>();
        throw ServerException(_messageFrom(map), _retryAfterFrom(map));
      }
      throw ServerException(e.message ?? 'Network error. Please try again.');
    }
  }

  /// Reads the API's 429 `retryAfterSeconds` hint when present.
  int? _retryAfterFrom(Map<String, dynamic> map) {
    final v = map['retryAfterSeconds'];
    if (v is int) return v;
    if (v is num) return v.toInt();
    return null;
  }

  String _messageFrom(Map<String, dynamic> map) {
    final msg = map['message'] ?? map['error'];
    if (msg is String) return msg;
    if (msg is List && msg.isNotEmpty) return msg.first.toString();
    return 'Something went wrong. Please try again.';
  }
}
