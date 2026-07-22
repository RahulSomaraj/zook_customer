import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../constants/api_constants.dart';

/// Thin wrapper around [Dio]. Attaches the auth bearer token (when available)
/// and pretty-prints requests/responses.
class DioClient {
  final Dio dio;

  /// Returns the current access token, or null/empty when signed out.
  /// Injected so the client stays decoupled from the auth layer.
  final String? Function()? tokenProvider;

  /// Called when an authenticated request comes back 401 (expired/invalid
  /// session). Wired to clear the session and route to the sign-in page.
  final void Function()? onUnauthorized;

  DioClient({Dio? dio, this.tokenProvider, this.onUnauthorized})
      : dio = dio ?? Dio() {
    this.dio
      ..options.baseUrl = ApiConstants.baseUrl
      ..options.connectTimeout = const Duration(seconds: 20)
      ..options.receiveTimeout = const Duration(seconds: 20)
      ..options.headers = {'Content-Type': 'application/json'}
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            final token = tokenProvider?.call();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            handler.next(options);
          },
          onError: (e, handler) {
            final status = e.response?.statusCode;
            final isAuthCall = e.requestOptions.path.contains('/auth/');
            if (status == 401 && !isAuthCall) {
              onUnauthorized?.call();
            }
            handler.next(e);
          },
        ),
      )
      ..interceptors.add(
        PrettyDioLogger(requestBody: true, responseBody: true),
      );
  }
}
