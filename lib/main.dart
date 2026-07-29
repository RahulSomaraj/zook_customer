import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'core/constants/auth_config.dart';
import 'core/di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase brokers Google sign-in (native ID-token flow). Skipped when not
  // configured — phone-OTP login works without it.
  if (AuthConfig.supabaseConfigured) {
    await Supabase.initialize(
      url: AuthConfig.supabaseUrl,
      anonKey: AuthConfig.supabaseAnonKey,
    );
  }

  // Some product images (user uploads on Supabase) return corrupt/undecodable
  // bytes. Every Image.network already falls back to a placeholder via its
  // errorBuilder, so these decode failures are harmless — swallow just those
  // to keep the console readable. All other errors flow through as normal.
  final previousOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    final summary = details.exceptionAsString();
    final isImageDecodeError = details.library == 'image resource service' ||
        summary.contains('Invalid image data') ||
        summary.contains('image codec');
    if (isImageDecodeError) return;
    previousOnError?.call(details);
  };

  await initDependencies();
  runApp(const ZookApp());
}
