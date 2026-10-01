import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../constants/api_constants.dart';
import '../network/dio_client.dart';

/// Registers this device's FCM token with the backend
/// (`POST /me/device-tokens`) while signed in, and removes it on logout
/// (`DELETE /me/device-tokens`).
///
/// Everything is best-effort: if Firebase isn't configured for a platform
/// (no google-services.json / GoogleService-Info.plist yet) [init] logs and
/// the app runs without push.
class PushService {
  final DioClient client;
  PushService({required this.client});

  bool _ready = false;
  String? _token;
  StreamSubscription<String>? _refreshSub;

  Future<void> init() async {
    if (kIsWeb) return;
    try {
      await Firebase.initializeApp();
      _ready = true;
    } catch (e) {
      debugPrint('Push disabled — Firebase not configured: $e');
    }
  }

  /// Call after sign-in (and on app start when already signed in).
  Future<void> register() async {
    if (!_ready) return;
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();
      final token = await messaging.getToken();
      if (token == null) return;
      await _send(token);
      _refreshSub ??= messaging.onTokenRefresh.listen(_send);
    } catch (e) {
      // iOS simulator / no APNs token yet, network, etc.
      debugPrint('Push registration failed: $e');
    }
  }

  /// Call BEFORE the session is revoked (the endpoint needs auth).
  Future<void> unregister() async {
    await _refreshSub?.cancel();
    _refreshSub = null;
    final token = _token;
    _token = null;
    if (!_ready || token == null) return;
    try {
      await client.dio.delete(ApiConstants.deviceTokens, data: {'token': token});
    } catch (e) {
      debugPrint('Push unregister failed: $e');
    }
  }

  Future<void> _send(String token) async {
    _token = token;
    try {
      await client.dio.post(ApiConstants.deviceTokens, data: {
        'token': token,
        'platform': Platform.isIOS ? 'ios' : 'android',
      });
    } catch (e) {
      debugPrint('Push token upload failed: $e');
    }
  }
}
