import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/auth_config.dart';
import '../../../../core/error/exceptions.dart';

/// Native Google sign-in, brokered through Supabase:
///   1. google_sign_in obtains a Google ID token (native sheet, no browser).
///   2. supabase.auth.signInWithIdToken validates it and returns a Supabase
///      session.
///   3. The Supabase access token is returned to the caller, which exchanges
///      it at our backend (/auth/customer/social/google) for Zook tokens.
abstract class GoogleAuthDataSource {
  /// Runs the native Google flow and returns a Supabase access token.
  /// Returns null when the user cancels the account picker.
  Future<String?> signIn();
}

class GoogleAuthDataSourceImpl implements GoogleAuthDataSource {
  GoogleSignIn? _googleSignIn;

  GoogleSignIn get _google {
    _googleSignIn ??= GoogleSignIn(
      // The WEB client ID — required so Google mints an ID token whose
      // audience Supabase accepts.
      serverClientId: AuthConfig.googleWebClientId,
      // iOS additionally needs its own client ID.
      clientId: !kIsWeb && Platform.isIOS && AuthConfig.googleIosClientId.isNotEmpty
          ? AuthConfig.googleIosClientId
          : null,
      scopes: const ['email', 'profile'],
    );
    return _googleSignIn!;
  }

  @override
  Future<String?> signIn() async {
    if (!AuthConfig.googleConfigured) {
      throw ServerException(
        'Google sign-in is not configured yet. Please use phone login.',
      );
    }

    final account = await _google.signIn();
    if (account == null) return null; // user closed the picker

    final auth = await account.authentication;
    final idToken = auth.idToken;
    if (idToken == null) {
      throw ServerException('Google did not return an ID token. Try again.');
    }

    final res = await Supabase.instance.client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: auth.accessToken,
    );

    final supabaseAccessToken = res.session?.accessToken;
    if (supabaseAccessToken == null) {
      throw ServerException('Google sign-in failed. Please try again.');
    }
    return supabaseAccessToken;
  }
}
