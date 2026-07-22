/// Asset path references. Add files under assets/ and register in pubspec.yaml.
class AppAssets {
  AppAssets._();

  static const String _images = 'assets/images';
  static const String _icons = 'assets/icons';

  // Placeholders — drop real assets in and reference them here.
  static const String logo = '$_images/logo.png';
  static const String appleIcon = '$_icons/apple.png';
  static const String googleIcon = '$_icons/google.png';
}
