import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/constants/app_strings.dart';
import '../core/di/injection.dart';
import '../core/locale/locale_cubit.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/cart/presentation/cubit/cart_cubit.dart';
import '../features/wishlist/presentation/cubit/wishlist_cubit.dart';
import '../l10n/gen/app_localizations.dart';
import 'app_router.dart';

/// Root widget. Registers app-wide BLoCs and wires the router + theme +
/// language. Rebuilds on locale change so the whole tree flips text, fonts
/// and direction (Arabic renders RTL automatically).
class ZookApp extends StatelessWidget {
  const ZookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocaleCubit>.value(value: sl<LocaleCubit>()),
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>()..add(const AppStarted()),
        ),
        BlocProvider<CartCubit>.value(value: sl<CartCubit>()),
        BlocProvider<WishlistCubit>.value(value: sl<WishlistCubit>()),
      ],
      child: BlocListener<AuthBloc, AuthState>(
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
        child: BlocBuilder<LocaleCubit, Locale>(
          builder: (context, locale) {
            return MaterialApp.router(
              title: AppStrings.appName,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.build(arabic: locale.languageCode == 'ar'),
              locale: locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              routerConfig: AppRouter.router,
              // Screens read static AppStrings.x, which don't register an
              // InheritedWidget dependency — so a locale change alone won't
              // rebuild them. Force a full-tree rebuild when it changes.
              builder: (context, child) => BlocListener<LocaleCubit, Locale>(
                listenWhen: (prev, curr) => prev != curr,
                listener: (ctx, _) => _rebuildAll(ctx as Element),
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Marks every element below [el] dirty so static AppStrings/AppTextStyles
/// reads pick up the new language. Only runs on a language switch.
void _rebuildAll(Element el) {
  void visit(Element e) {
    e.markNeedsBuild();
    e.visitChildren(visit);
  }

  el.visitChildren(visit);
}
