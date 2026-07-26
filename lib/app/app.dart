import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/constants/app_strings.dart';
import '../core/di/injection.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/cart/presentation/cubit/cart_cubit.dart';
import '../features/wishlist/presentation/cubit/wishlist_cubit.dart';
import 'app_router.dart';

/// Root widget. Registers app-wide BLoCs and wires the router + theme.
class ZookApp extends StatelessWidget {
  const ZookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>()..add(const AppStarted()),
        ),
        BlocProvider<CartCubit>.value(value: sl<CartCubit>()),
        BlocProvider<WishlistCubit>.value(value: sl<WishlistCubit>()),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        // Keep cart & wishlist in sync with the session: prime their counts the
        // moment we become authenticated (login OR cold start with a saved
        // session), and fully reset them on logout so the next login reloads
        // fresh instead of showing stale/empty counts until a manual refresh.
        listenWhen: (prev, curr) => prev.status != curr.status,
        listener: (context, state) {
          final cart = context.read<CartCubit>();
          final wishlist = context.read<WishlistCubit>();
          if (state.status == AuthStatus.authenticated) {
            cart.load();
            wishlist.loadServer();
          } else if (state.status == AuthStatus.initial) {
            cart.reset();
            wishlist.reset();
          }
        },
        child: MaterialApp.router(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          routerConfig: AppRouter.router,
        ),
      ),
    );
  }
}
