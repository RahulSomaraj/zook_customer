import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/di/injection.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/otp_page.dart';
import '../features/auth/presentation/pages/signup_page.dart';
import '../features/auth/presentation/pages/verify_phone_page.dart';
import '../features/cart/presentation/pages/cart_page.dart';
import '../features/category/presentation/pages/category_browse_page.dart';
import '../features/checkout/presentation/pages/checkout_page.dart';
import '../features/checkout/presentation/pages/order_confirmed_page.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/onboarding/presentation/pages/locale_page.dart';
import '../features/onboarding/presentation/pages/onboarding_page.dart';
import '../features/orders/domain/entities/customer_order.dart';
import '../features/orders/presentation/pages/order_tracking_page.dart';
import '../features/orders/presentation/pages/orders_page.dart';
import '../features/product/domain/entities/category.dart';
import '../features/product/domain/entities/product.dart';
import '../features/product/presentation/pages/product_detail_page.dart';
import '../features/product/presentation/pages/product_list_page.dart';
import '../features/address/presentation/pages/addresses_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/search/presentation/pages/search_page.dart';
import '../features/shell/presentation/pages/main_shell.dart';
import '../features/splash/presentation/pages/splash_page.dart';
import '../features/wishlist/presentation/pages/favourites_page.dart';

/// Named routes for the app. Keep paths in one place so navigation calls
/// reference [AppRoute.<x>.path] rather than magic strings.
enum AppRoute {
  splash('/'),
  locale('/locale'),
  onboarding('/onboarding'),
  login('/login'),
  signup('/signup'),
  otp('/otp'),
  home('/home'),
  category('/home/category'),
  productList('/home/products'),
  search('/home/search'),
  cart('/cart'),
  orders('/orders'),
  profile('/profile'),
  favourites('/profile/favourites'),
  addresses('/profile/addresses'),
  product('/product'),
  orderTrack('/order-track'),
  checkout('/checkout'),
  orderConfirmed('/order-confirmed'),
  verifyPhone('/verify-phone');

  const AppRoute(this.path);
  final String path;
}

class AppRouter {
  AppRouter._();

  static final _rootKey = GlobalKey<NavigatorState>();

  /// Routes reachable without a session.
  static const _publicPaths = {
    '/', // splash
    '/locale',
    '/onboarding',
    '/login',
    '/signup',
    '/otp',
  };

  static final GoRouter router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoute.splash.path,
    redirect: (context, state) {
      final loggedIn = sl<AuthRepository>().isLoggedIn;
      final isPublic = _publicPaths.contains(state.matchedLocation);
      // Unauthenticated users can only be on public routes; send them to login.
      if (!loggedIn && !isPublic) return AppRoute.login.path;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoute.splash.path,
        name: AppRoute.splash.name,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoute.locale.path,
        name: AppRoute.locale.name,
        builder: (context, state) => const LocalePage(),
      ),
      GoRoute(
        path: AppRoute.onboarding.path,
        name: AppRoute.onboarding.name,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoute.login.path,
        name: AppRoute.login.name,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoute.signup.path,
        name: AppRoute.signup.name,
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(
        path: AppRoute.otp.path,
        name: AppRoute.otp.name,
        builder: (context, state) {
          final phone = state.extra as String? ?? '';
          return OtpPage(phoneNumber: phone);
        },
      ),
      // ── Main app: bottom-tab shell ──
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          // Tab 0 — Search (the home/browse feed, with nested browse + search)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.home.path,
                name: AppRoute.home.name,
                builder: (context, state) => const HomePage(),
                routes: [
                  GoRoute(
                    path: 'category',
                    name: AppRoute.category.name,
                    builder: (context, state) {
                      final cat = state.extra;
                      if (cat is ShopCategory) {
                        return CategoryBrowsePage(
                          categoryId: cat.id,
                          categoryName: cat.label,
                        );
                      }
                      return const CategoryBrowsePage();
                    },
                  ),
                  GoRoute(
                    path: 'products',
                    name: AppRoute.productList.name,
                    builder: (context, state) {
                      final args = state.extra as ProductListArgs?;
                      return ProductListPage(
                        title: args?.title ?? 'Products',
                        products: args?.products ?? const [],
                      );
                    },
                  ),
                  GoRoute(
                    path: 'search',
                    name: AppRoute.search.name,
                    builder: (context, state) => SearchPage(
                      initialCategory: state.extra is ShopCategory
                          ? state.extra as ShopCategory
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Tab 1 — Cart
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.cart.path,
                name: AppRoute.cart.name,
                builder: (context, state) => const CartPage(),
              ),
            ],
          ),
          // Tab 2 — Orders
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.orders.path,
                name: AppRoute.orders.name,
                builder: (context, state) => const OrdersPage(),
              ),
            ],
          ),
          // Tab 3 — Profile (with nested Favourites)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.profile.path,
                name: AppRoute.profile.name,
                builder: (context, state) => const ProfilePage(),
                routes: [
                  GoRoute(
                    path: 'favourites',
                    name: AppRoute.favourites.name,
                    builder: (context, state) => const FavouritesPage(),
                  ),
                  GoRoute(
                    path: 'addresses',
                    name: AppRoute.addresses.name,
                    builder: (context, state) => const AddressesPage(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      // ── Full-screen routes (above the tab shell) ──
      GoRoute(
        path: AppRoute.product.path,
        name: AppRoute.product.name,
        parentNavigatorKey: _rootKey,
        builder: (context, state) =>
            ProductDetailPage(product: state.extra as Product),
      ),
      GoRoute(
        path: AppRoute.orderTrack.path,
        name: AppRoute.orderTrack.name,
        parentNavigatorKey: _rootKey,
        builder: (context, state) =>
            OrderTrackingPage(order: state.extra as CustomerOrder),
      ),
      GoRoute(
        path: AppRoute.checkout.path,
        name: AppRoute.checkout.name,
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const CheckoutPage(),
      ),
      GoRoute(
        path: AppRoute.orderConfirmed.path,
        name: AppRoute.orderConfirmed.name,
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const OrderConfirmedPage(),
      ),
      GoRoute(
        path: AppRoute.verifyPhone.path,
        name: AppRoute.verifyPhone.name,
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const VerifyPhonePage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Route not found: ${state.uri}')),
    ),
  );
}
