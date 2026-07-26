import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../widgets/zook_tab_bar.dart';

/// Hosts the bottom tab bar and the active branch's navigator.
class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const MainShell({super.key, required this.navigationShell});

  /// Index of the Profile branch (Search=0, Cart=1, Orders=2, Profile=3).
  static const int _profileBranchIndex = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: navigationShell,
      bottomNavigationBar: BlocBuilder<CartCubit, CartState>(
        builder: (context, cart) => ZookTabBar(
          currentIndex: navigationShell.currentIndex,
          cartCount: cart.itemCount,
          onTap: (index) => navigationShell.goBranch(
            index,
            // Re-tapping the active tab resets its stack. The Profile tab is
            // additionally always opened at its root (/profile) so it never
            // lands on a nested page like Favourites.
            initialLocation: index == navigationShell.currentIndex ||
                index == _profileBranchIndex,
          ),
        ),
      ),
    );
  }
}
