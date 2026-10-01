/// API endpoint configuration.
class ApiConstants {
  ApiConstants._();

  /// API root. Defaults to UAT; override per build:
  ///   flutter build apk --dart-define=API_BASE_URL=https://api.zookapp.co/api
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://uatapi.zookapp.co/api',
  );

  // Auth — session (shared across roles)
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';

  // Auth — customer
  static const String register = '/auth/customer/register';
  static const String sendOtp = '/auth/customer/otp/send';
  static const String verifyOtp = '/auth/customer/otp/verify';
  static const String socialGoogle = '/auth/customer/social/google';

  /// Attach/verify a phone on the CURRENT authenticated user (used after a
  /// Google signup when checkout requires a verified phone).
  static const String phoneAttachSend = '/auth/customer/phone/send';
  static const String phoneAttachVerify = '/auth/customer/phone/verify';

  // Catalog
  static const String categories = '/categories';
  static const String products = '/products';
  static const String recentlyListed = '/products/recently-listed';
  static const String topPicks = '/products/top-picks';

  // Orders
  static const String checkout = '/customers/orders/checkout';
  static const String orders = '/customers/orders';
  static String order(String orderId) => '/customers/orders/$orderId';
  static String subOrderTracking(String orderId, String subOrderId) =>
      '/customers/orders/$orderId/sub-orders/$subOrderId/tracking';

  // Settings / reference data
  static const String customerSettings = '/customers/me/settings';
  static const String countries = '/countries';
  static const String deviceTokens = '/me/device-tokens';
  static const String policies = '/policies';
  static String policy(String type) => '/policies/$type';

  // Wishlist
  static const String wishlist = '/wishlist';

  // Addresses
  static const String addresses = '/customers/addresses';

  /// A single address by id, e.g. `/customers/addresses/{id}` (used for DELETE).
  static String addressItem(String id) => '$addresses/$id';

  // Cart (customer-scoped, matching the /customers/* namespace).
  static const String cart = '/customers/cart';
  static const String cartItems = '/customers/cart/items';

  /// A single cart line by its LINE id (`items[].id` from GET /customers/cart,
  /// not the product id), e.g. `/customers/cart/items/{itemId}`
  /// (used for PATCH quantity and DELETE line).
  static String cartItem(String itemId) => '$cartItems/$itemId';

  /// Add/remove a single product to/from the wishlist.
  /// POST adds, DELETE removes. e.g. `/wishlist/{productId}`.
  static String wishlistItem(String productId) => '$wishlist/$productId';

  /// Base URL for product images. Relative `thumbnailUrl` / `inspectionImages`
  /// keys are appended to this (full `http(s)` URLs pass through unchanged).
  static const String mediaBaseUrl =
      'https://rknxaeiiawrskyhzyhoq.supabase.co/storage/v1/object/public/zook_data';
}
