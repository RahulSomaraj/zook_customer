import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../constants/api_constants.dart';

/// Thin wrapper around [Dio].
///
/// - Attaches the bearer token and `Accept-Language` to every request.
/// - On a 401 from a protected endpoint, exchanges the refresh token at
///   `POST /auth/refresh` (single-flight — concurrent 401s share one refresh,
///   which matters because the backend ROTATES refresh tokens) and replays
///   the original request once. If the refresh fails, [onUnauthorized] runs.
class DioClient {
  final Dio dio;

  /// Returns the current access token, or null/empty when signed out.
  final String? Function()? tokenProvider;

  /// Returns the current refresh token, or null/empty when signed out.
  final String? Function()? refreshTokenProvider;

  /// Persists a freshly issued token pair.
  final Future<void> Function(String accessToken, String refreshToken)?
      onTokensRefreshed;

  /// Returns the current UI language code ('en' / 'ar'). Sent as
  /// Accept-Language so the API localizes error messages.
  final String Function()? languageProvider;

  /// Called when the session can't be recovered (refresh failed/revoked).
  /// Wired to clear the session and route to the sign-in page.
  final void Function()? onUnauthorized;

  /// Public auth endpoints: a 401 there is a business error (bad OTP, bad
  /// refresh token), never a reason to refresh or sign out.
  static const _noRefreshPaths = {
    ApiConstants.refresh,
    // A refresh here would rotate the token we're about to revoke and leave
    // the new one alive; a 401 on logout is harmless (local clear still runs).
    ApiConstants.logout,
    ApiConstants.register,
    ApiConstants.sendOtp,
    ApiConstants.verifyOtp,
    ApiConstants.socialGoogle,
  };

  static const _kRetried = 'auth_retried';

  /// In-flight refresh shared by concurrent 401s.
  Future<bool>? _refreshing;

  DioClient({
    Dio? dio,
    this.tokenProvider,
    this.refreshTokenProvider,
    this.onTokensRefreshed,
    this.languageProvider,
    this.onUnauthorized,
  }) : dio = dio ?? Dio() {
    this.dio
      ..options.baseUrl = ApiConstants.baseUrl
      ..options.connectTimeout = const Duration(seconds: 20)
      ..options.receiveTimeout = const Duration(seconds: 20)
      ..options.headers = {'Content-Type': 'application/json'}
      ..interceptors.add(
        InterceptorsWrapper(onRequest: _onRequest, onError: _onError),
      );
    if (kDebugMode) {
      this.dio.interceptors.add(
            PrettyDioLogger(requestBody: true, responseBody: true),
          );
    }
  }

  void _onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = tokenProvider?.call();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    } else {
      options.headers.remove('Authorization');
    }
    final lang = languageProvider?.call();
    if (lang != null && lang.isNotEmpty) {
      options.headers['Accept-Language'] = lang;
    }
    handler.next(options);
  }

  Future<void> _onError(
    DioException e,
    ErrorInterceptorHandler handler,
  ) async {
    final opts = e.requestOptions;
    if (e.response?.statusCode != 401 || _noRefreshPaths.contains(opts.path)) {
      return handler.next(e);
    }

    // Already replayed once and still 401 → session is really gone.
    if (opts.extra[_kRetried] == true) {
      onUnauthorized?.call();
      return handler.next(e);
    }

    // If another request refreshed while this one was in flight, the token
    // it was sent with is stale — just replay with the current one.
    final sent = (opts.headers['Authorization'] as String?)
        ?.replaceFirst('Bearer ', '');
    final current = tokenProvider?.call();
    final alreadyRefreshed =
        current != null && current.isNotEmpty && sent != current;

    if (!alreadyRefreshed && !await _refresh()) {
      onUnauthorized?.call();
      return handler.next(e);
    }

    try {
      opts.extra[_kRetried] = true;
      final res = await dio.fetch<dynamic>(opts);
      handler.resolve(res);
    } on DioException catch (err) {
      handler.next(err);
    }
  }

  /// Single-flight wrapper around [_doRefresh].
  Future<bool> _refresh() =>
      _refreshing ??= _doRefresh().whenComplete(() => _refreshing = null);

  Future<bool> _doRefresh() async {
    final refreshToken = refreshTokenProvider?.call();
    if (refreshToken == null || refreshToken.isEmpty) return false;
    try {
      // Bare Dio: no interceptors, so a failing refresh can't recurse.
      final res = await Dio(BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {'Content-Type': 'application/json'},
      )).post<dynamic>(
        ApiConstants.refresh,
        data: {'refreshToken': refreshToken},
      );
      final body = res.data;
      final data = body is Map ? (body['data'] ?? body) : null;
      if (data is Map) {
        final access = data['accessToken'];
        final refresh = data['refreshToken'];
        if (access is String && access.isNotEmpty) {
          await onTokensRefreshed?.call(
            access,
            refresh is String && refresh.isNotEmpty ? refresh : refreshToken,
          );
          return true;
        }
      }
    } catch (err) {
      debugPrint('Token refresh failed: $err');
    }
    return false;
  }
}
