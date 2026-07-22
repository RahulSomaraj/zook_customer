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
            initialLocation: index == navigationShell.currentIndex,
          ),
        ),
      ),
    );
  }
}
