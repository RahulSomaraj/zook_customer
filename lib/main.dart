import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
