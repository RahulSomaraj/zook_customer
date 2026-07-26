import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../product/domain/entities/category.dart';
import '../../../product/domain/entities/product.dart';
import '../../../product/presentation/pages/product_list_page.dart';
import '../../../wishlist/presentation/widgets/wishlist_product_grid.dart';
import '../cubit/home_cubit.dart';
import '../widgets/category_pills.dart';
import '../widgets/home_header.dart';
import '../widgets/promo_banner.dart';
import '../widgets/section_header.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          HomeCubit(repository: sl(), categoryRepository: sl())..load(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  void _openCategory(BuildContext context, ShopCategory category) =>
      context.push(AppRoute.category.path, extra: category);

  void _openProduct(BuildContext context, Product product) =>
      context.push(AppRoute.product.path, extra: product);

  void _openList(BuildContext context, String title, List<Product> products) =>
      context.push(
        AppRoute.productList.path,
        extra: ProductListArgs(title: title, products: products),
      );

  String? _firstName(String? fullName) {
    final n = fullName?.trim() ?? '';
    if (n.isEmpty) return null;
    return n.split(RegExp(r'\s+')).first;
  }

  String? _initials(String? fullName) {
    final n = fullName?.trim() ?? '';
    if (n.isEmpty) return null;
    final parts = n.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return null;
    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final fullName = context.watch<AuthBloc>().state.user?.fullName;
    final firstName = _firstName(fullName);
    final greeting =
        firstName != null ? 'Good morning, $firstName 👋' : 'Good morning 👋';

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeHeader(
              greeting: greeting,
              avatarInitials: _initials(fullName),
              onSearchTap: () => context.push(AppRoute.search.path),
            ),
            BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) {
                if (state.status == HomeStatus.loading ||
                    state.status == HomeStatus.initial) {
                  return const HomeContentSkeleton();
                }
                if (state.status == HomeStatus.failure) {
                  return Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(child: Text(state.errorMessage ?? 'Error')),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CategoryPills(
                      categories: state.categories,
                      selectedIndex: state.selectedCategoryIndex,
                      onSelected: (i) {
                        context.read<HomeCubit>().selectCategory(i);
                        _openCategory(context, state.categories[i]);
                      },
                    ),
                    const PromoBanner(),
                    SectionHeader(
                      title: 'Recently listed',
                      onAction: () => _openList(
                          context, 'Recently listed', state.recentlyListed),
                    ),
                    WishlistProductGrid(
                      products: state.recentlyListed.take(4).toList(),
                      onTap: (p) => _openProduct(context, p),
                    ),
                    SectionHeader(
                      title: 'Top picks',
                      onAction: () =>
                          _openList(context, 'Top picks', state.topPicks),
                    ),
                    WishlistProductGrid(
                      products: state.topPicks.take(4).toList(),
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      onTap: (p) => _openProduct(context, p),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
