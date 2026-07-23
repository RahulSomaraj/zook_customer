import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Persists auth tokens and the signed-in user's profile locally.
abstract class AuthLocalDataSource {
  Future<void> saveTokens({required String accessToken, String? refreshToken});
  String? get accessToken;
  String? get refreshToken;
  bool get isLoggedIn;

  /// Caches the signed-in user's profile (name, phone, id, …) as JSON.
  Future<void> saveUser(Map<String, dynamic> userJson);

  /// The cached user profile, or null if none is stored.
  Map<String, dynamic>? get cachedUser;

  Future<void> clear();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences prefs;
  AuthLocalDataSourceImpl({required this.prefs});

  static const _kAccess = 'auth_access_token';
  static const _kRefresh = 'auth_refresh_token';
  static const _kUser = 'auth_user';

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
  Future<void> saveUser(Map<String, dynamic> userJson) async {
    await prefs.setString(_kUser, jsonEncode(userJson));
  }

  @override
  Map<String, dynamic>? get cachedUser {
    final raw = prefs.getString(_kUser);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) return decoded.cast<String, dynamic>();
    } catch (_) {
      // Corrupt cache — ignore and treat as no cached user.
    }
    return null;
  }

  @override
  Future<void> clear() async {
    await prefs.remove(_kAccess);
    await prefs.remove(_kRefresh);
    await prefs.remove(_kUser);
  }
}
