import 'package:shared_preferences/shared_preferences.dart';

/// Persists auth tokens locally.
abstract class AuthLocalDataSource {
  Future<void> saveTokens({required String accessToken, String? refreshToken});
  String? get accessToken;
  String? get refreshToken;
  bool get isLoggedIn;
  Future<void> clear();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences prefs;
  AuthLocalDataSourceImpl({required this.prefs});

  static const _kAccess = 'auth_access_token';
  static const _kRefresh = 'auth_refresh_token';

  @override
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await prefs.setString(_kAccess, accessToken);
    if (refreshToken != null) await prefs.setString(_kRefresh, refreshToken);
  }

  @override
  String? get accessToken => prefs.getString(_kAccess);

  @override
  String? get refreshToken => prefs.getString(_kRefresh);

  @override
  bool get isLoggedIn => (accessToken ?? '').isNotEmpty;

  @override
  Future<void> clear() async {
    await prefs.remove(_kAccess);
    await prefs.remove(_kRefresh);
  }
}
