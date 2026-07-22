import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../wishlist/presentation/widgets/wishlist_product_grid.dart';
import '../../domain/entities/product.dart';

/// Route arguments for [ProductListPage].
class ProductListArgs {
  final String title;
  final List<Product> products;
  const ProductListArgs({required this.title, required this.products});
}

/// Full-screen "view all" listing for a section (Recently listed / Top picks).
class ProductListPage extends StatelessWidget {
  final String title;
  final List<Product> products;
  const ProductListPage({
    super.key,
    required this.title,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Text('←',
                        style: TextStyle(fontSize: 20, color: AppColors.mid)),
                  ),
                  const SizedBox(width: 10),
                  Text(title,
                      style: AppTextStyles.title.copyWith(fontSize: 17)),
                  const Spacer(),
                  Text('${products.length} items',
                      style: AppTextStyles.caption.copyWith(fontSize: 12)),
                ],
              ),
            ),
            Expanded(
              child: ColoredBox(
                color: AppColors.surface,
                child: products.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🗂️', style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 12),
                            Text('Nothing here yet',
                                style:
                                    AppTextStyles.title.copyWith(fontSize: 15)),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: WishlistProductGrid(
                            products: products,
                            onTap: (p) => context.push(
                                AppRoute.product.path,
                                extra: p),
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
