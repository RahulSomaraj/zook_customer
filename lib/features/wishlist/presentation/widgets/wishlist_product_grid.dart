import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../product/domain/entities/product.dart';
import '../../../product/presentation/widgets/product_grid.dart';
import '../cubit/wishlist_cubit.dart';

/// [ProductGrid] wired to the global [WishlistCubit]: hearts reflect live
/// membership and tapping one toggles it via the wishlist API (POST/DELETE).
class WishlistProductGrid extends StatelessWidget {
  final List<Product> products;
  final void Function(Product)? onTap;
  final EdgeInsets? padding;

  const WishlistProductGrid({
    super.key,
    required this.products,
    this.onTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WishlistCubit, WishlistState>(
      builder: (context, state) {
        // Seed membership from any API `is_wishlisted` flags after this frame.
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => context.read<WishlistCubit>().seedFrom(products),
        );
        final mapped = products
            .map((p) => p.copyWith(isWishlisted: state.ids.contains(p.id)))
            .toList();
        return ProductGrid(
          products: mapped,
          padding: padding ?? const EdgeInsets.fromLTRB(16, 0, 16, 16),
          onTap: onTap,
          onWishlistTap: (p) => context.read<WishlistCubit>().toggle(p),
        );
      },
    );
  }
}
