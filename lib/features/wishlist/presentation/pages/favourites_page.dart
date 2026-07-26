import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../../core/widgets/z_icon.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../product/domain/entities/product.dart';
import '../../../product/domain/entities/product_grade.dart';
import '../cubit/favourites_cubit.dart';
import '../cubit/wishlist_cubit.dart';

/// Saved / favourite listings, backed by `GET /wishlist`.
class FavouritesPage extends StatelessWidget {
  const FavouritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FavouritesCubit(repository: sl())..load(),
      child: const _FavView(),
    );
  }
}

class _FavView extends StatelessWidget {
  const _FavView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<FavouritesCubit, FavouritesState>(
          builder: (context, state) {
            // Keep membership in sync so hearts show filled + un-hearting works.
            if (state.status == FavStatus.loaded &&
                state.products.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => context
                    .read<WishlistCubit>()
                    .seedIds(state.products.map((p) => p.id)),
              );
            }
            return Column(
              children: [
                // Header
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    border: Border(bottom: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        behavior: HitTestBehavior.opaque,
                        child: const ZIcon('arrow-left',
                            size: 20, color: AppColors.mid),
                      ),
                      const SizedBox(width: 12),
                      Text('Favourites',
                          style: AppTextStyles.title
                              .copyWith(fontSize: 17, color: AppColors.black)),
                      const Spacer(),
                      if (state.status == FavStatus.loaded)
                        Text('${state.products.length} items',
                            style: AppTextStyles.label.copyWith(
                                fontSize: 12,
                                letterSpacing: 0,
                                color: AppColors.light)),
                    ],
                  ),
                ),
                Expanded(child: _body(context, state)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _body(BuildContext context, FavouritesState state) {
    switch (state.status) {
      case FavStatus.initial:
      case FavStatus.loading:
        return const ProductGridSkeleton();
      case FavStatus.failure:
        return _Empty(
          title: "Couldn't load favourites",
          subtitle: state.errorMessage ?? 'Please try again.',
        );
      case FavStatus.loaded:
        if (state.products.isEmpty) {
          return const _Empty(
            title: 'No saved items yet',
            subtitle: 'Tap the heart on any listing to save it here.',
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: state.products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.62,
          ),
          itemBuilder: (context, i) =>
              _FavCard(product: state.products[i]),
        );
    }
  }
}

class _Empty extends StatelessWidget {
  final String title;
  final String subtitle;
  const _Empty({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ZIcon('heart', size: 44, color: AppColors.light),
            const SizedBox(height: 12),
            Text(title,
                style: AppTextStyles.title
                    .copyWith(fontSize: 16, color: AppColors.black)),
            const SizedBox(height: 4),
            Text(subtitle,
                textAlign: TextAlign.center, style: AppTextStyles.subtitle),
          ],
        ),
      ),
    );
  }
}

class _FavCard extends StatelessWidget {
  final Product product;
  const _FavCard({required this.product});

  void _snack(BuildContext context, String msg) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    final p = product;
    final inCart = context.watch<CartCubit>().contains(p.id);
    return GestureDetector(
      onTap: () => context.push(AppRoute.product.path, extra: p),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(18),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Stack(
                children: [
                  Positioned.fill(child: _image(p)),
                  if (p.isVerified)
                    const Positioned(
                        left: 8, bottom: 7, child: _VerifiedStrip()),
                  Positioned(
                      right: 0, bottom: 0, child: _GradeTab(grade: p.grade)),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        context.read<WishlistCubit>().toggle(p);
                        context.read<FavouritesCubit>().removeLocal(p.id);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: const ZIcon('heart-fill',
                            size: 18, color: AppColors.primary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.brand.toUpperCase(),
                      style: AppTextStyles.caption.copyWith(
                          fontSize: 9,
                          color: AppColors.light,
                          letterSpacing: 0.5)),
                  const SizedBox(height: 2),
                  Text(p.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black)),
                  const SizedBox(height: 6),
                  Text.rich(TextSpan(children: [
                    TextSpan(
                        text: 'AED ',
                        style: AppTextStyles.caption
                            .copyWith(fontSize: 10, color: AppColors.mid)),
                    TextSpan(
                        text: formatAmount(p.priceAed),
                        style: AppTextStyles.title.copyWith(fontSize: 15)),
                  ])),
                  const SizedBox(height: 6),
                  _TabbyLine(monthly: p.tabbyInstalment),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: inCart
                  ? _OutlineButton(
                      label: 'Go to cart',
                      icon: 'cart',
                      onTap: () => context.go(AppRoute.cart.path),
                    )
                  : _OutlineButton(
                      label: 'Add to cart',
                      icon: 'cart',
                      onTap: () {
                        context.read<CartCubit>().add(p);
                        _snack(context, 'Added to cart');
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _image(Product p) {
    final img = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: p.imageGradient,
        ),
      ),
      child: p.imageUrl.isEmpty
          ? Center(child: Text(p.emoji, style: const TextStyle(fontSize: 34)))
          : Image.network(
              p.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (_, __, ___) => Center(
                  child: Text(p.emoji, style: const TextStyle(fontSize: 34))),
              loadingBuilder: (c, child, prog) => prog == null
                  ? child
                  : Center(
                      child: Text(p.emoji,
                          style: const TextStyle(fontSize: 34))),
            ),
    );
    return SizedBox.expand(child: img);
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final String icon;
  final VoidCallback onTap;
  const _OutlineButton(
      {required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(color: AppColors.primary, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ZIcon(icon, size: 13, color: AppColors.primary),
            const SizedBox(width: 5),
            Text(label,
                style: AppTextStyles.caption.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
}

class _VerifiedStrip extends StatelessWidget {
  const _VerifiedStrip();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.verified, size: 13, color: Color(0xFF1D9BF0)),
        const SizedBox(width: 3),
        Text('Verified',
            style: AppTextStyles.caption.copyWith(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF334B3A))),
      ],
    );
  }
}

class _GradeTab extends StatelessWidget {
  final ProductGrade grade;
  const _GradeTab({required this.grade});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(10)),
      ),
      child: Container(
        padding: const EdgeInsets.only(bottom: 3),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: grade.color, width: 2)),
        ),
        child: Text(
          '${grade.label} · ${grade.shortLabel.toUpperCase()}',
          style: AppTextStyles.caption.copyWith(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: AppColors.black,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}

class _TabbyLine extends StatelessWidget {
  final int monthly;
  const _TabbyLine({required this.monthly});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
          decoration: BoxDecoration(
            color: const Color(0xFF3EEDBF),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text('tabby',
              style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F1F1A),
                  letterSpacing: -0.2)),
        ),
        const SizedBox(width: 5),
        Flexible(
          child: Text('As low as AED $monthly/mo',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                  fontSize: 9,
                  color: AppColors.mid,
                  fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
