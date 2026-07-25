/// Credentials for Google sign-in via Supabase.
///
/// Fill these in from:
///  - [supabaseUrl] / [supabaseAnonKey]: Supabase Dashboard → Project Settings
///    → API (the anon/publishable key — safe to ship in the app).
///  - [googleWebClientId]: Google Cloud Console → Credentials → the **Web
///    application** OAuth client (also registered in Supabase's Google
///    provider). Used as `serverClientId` so Google returns an ID token that
///    Supabase accepts.
///  - [googleIosClientId]: the **iOS** OAuth client ID. Also add its reversed
///    form as a URL scheme in ios/Runner/Info.plist.
///
/// Google sign-in stays disabled (button shows an error) until these are set.
class AuthConfig {
  AuthConfig._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '', // e.g. https://rknxaeiiawrskyhzyhoq.supabase.co
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  static const String googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: '', // xxxx.apps.googleusercontent.com (Web client)
  );

  static const String googleIosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
    defaultValue: '', // xxxx.apps.googleusercontent.com (iOS client)
  );

  static bool get supabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static bool get googleConfigured =>
      supabaseConfigured && googleWebClientId.isNotEmpty;
}
