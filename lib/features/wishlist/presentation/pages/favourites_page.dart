import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../product/domain/entities/product.dart';
import '../../../product/domain/entities/product_grade.dart';

class _Fav {
  final Product product;
  final bool soldOut;
  const _Fav(this.product, {this.soldOut = false});
}

const _favourites = <_Fav>[
  _Fav(Product(
    id: 'fav-1',
    brand: 'Apple',
    name: 'iPhone 13 Pro 256GB',
    priceAed: 2150,
    grade: ProductGrade.a,
    emoji: '📱',
    imageGradient: [Color(0xFFEFF6FF), Color(0xFFBFDBFE)],
  )),
  _Fav(Product(
    id: 'fav-2',
    brand: 'Sony',
    name: 'WH-1000XM5',
    priceAed: 680,
    grade: ProductGrade.a,
    emoji: '🎧',
    imageGradient: [Color(0xFFFDF4FF), Color(0xFFF0ABFC)],
  )),
  _Fav(Product(
    id: 'fav-3',
    brand: 'Samsung',
    name: 'Galaxy Tab S9 128GB',
    priceAed: 890,
    grade: ProductGrade.b,
    emoji: '📟',
    imageGradient: [Color(0xFFF0FDF4), Color(0xFFBBF7D0)],
  )),
  _Fav(
    Product(
      id: 'fav-4',
      brand: 'Sony',
      name: 'PlayStation 5 Slim',
      priceAed: 1480,
      grade: ProductGrade.a,
      emoji: '🎮',
      imageGradient: [Color(0xFFFFF7ED), Color(0xFFFED7AA)],
    ),
    soldOut: true,
  ),
];

/// Saved / favourite listings grid (reached from Profile → Saved Items).
class FavouritesPage extends StatelessWidget {
  const FavouritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    behavior: HitTestBehavior.opaque,
                    child: const Icon(Icons.arrow_back,
                        size: 20, color: AppColors.mid),
                  ),
                  const SizedBox(width: 12),
                  Text('Favourites',
                      style: AppTextStyles.title
                          .copyWith(fontSize: 17, color: AppColors.black)),
                  const Spacer(),
                  Text('${_favourites.length} items',
                      style: AppTextStyles.label.copyWith(
                          fontSize: 12,
                          letterSpacing: 0,
                          color: AppColors.light)),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _favourites.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.62,
                ),
                itemBuilder: (context, i) => _FavCard(fav: _favourites[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavCard extends StatelessWidget {
  final _Fav fav;
  const _FavCard({required this.fav});

  @override
  Widget build(BuildContext context) {
    final p = fav.product;
    return Container(
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
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: p.imageGradient,
                      ),
                    ),
                    child: Center(
                      child: Text(p.emoji,
                          style: const TextStyle(fontSize: 34)),
                    ),
                  ),
                ),
                const Positioned(
                  top: 7,
                  right: 7,
                  child: Icon(Icons.favorite,
                      size: 18, color: AppColors.primary),
                ),
                const Positioned(
                  left: 8,
                  bottom: 7,
                  child: _VerifiedStrip(),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: _GradeTab(grade: p.grade),
                ),
                if (fav.soldOut)
                  Positioned.fill(
                    child: Container(
                      color: AppColors.white.withValues(alpha: 0.7),
                      alignment: Alignment.center,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.black,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text('SOLD OUT',
                            style: AppTextStyles.caption.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                color: AppColors.white)),
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
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: fav.soldOut
                ? _OutlineButton(
                    label: 'Notify me',
                    icon: Icons.notifications_outlined,
                    muted: true,
                    onTap: () => _snack(context, 'We’ll notify you'),
                  )
                : _OutlineButton(
                    label: 'Add to cart',
                    icon: Icons.shopping_cart_outlined,
                    onTap: () {
                      context.read<CartCubit>().add(p);
                      _snack(context, 'Added to cart');
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _snack(BuildContext context, String msg) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool muted;
  final VoidCallback onTap;
  const _OutlineButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = muted ? AppColors.light : AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
              color: muted ? AppColors.border : AppColors.primary, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
            Text(label,
                style: AppTextStyles.caption.copyWith(
                    fontSize: 11, fontWeight: FontWeight.w800, color: color)),
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
