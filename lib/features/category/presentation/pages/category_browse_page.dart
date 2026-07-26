import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../product/domain/entities/product_sort.dart';
import '../widgets/subcategory_grid.dart';
import '../../../wishlist/presentation/widgets/wishlist_product_grid.dart';
import '../cubit/category_cubit.dart';
import '../widgets/grade_filter_row.dart';

class CategoryBrowsePage extends StatelessWidget {
  final String categoryId;
  final String categoryName;
  const CategoryBrowsePage({
    super.key,
    this.categoryId = '',
    this.categoryName = 'Products',
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CategoryCubit(
        productRepository: sl(),
        categoryRepository: sl(),
      )..load(categoryId, categoryName),
      child: const _CategoryView(),
    );
  }
}

class _CategoryView extends StatelessWidget {
  const _CategoryView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CategoryCubit>();
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<CategoryCubit, CategoryState>(
          builder: (context, state) {
            final title = state.selectedCategoryName;
            return Column(
              children: [
                // Header
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  color: AppColors.white,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.canPop() ? context.pop() : null,
                        behavior: HitTestBehavior.opaque,
                        child: const Icon(Icons.arrow_back,
                            size: 22, color: AppColors.mid),
                      ),
                      const SizedBox(width: 10),
                      Text(title,
                          style: AppTextStyles.title.copyWith(fontSize: 17)),
                      const Spacer(),
                      Text('${state.products.length} items',
                          style: AppTextStyles.caption.copyWith(fontSize: 12)),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category blocks — same list as home (old grid design),
                        // with the tapped category highlighted.
                        if (state.categories.isNotEmpty)
                          SubCategoryGrid(
                            categories: state.categories,
                            selectedId: state.selectedCategoryId,
                            onSelected: cubit.selectCategory,
                          ),
                        GradeFilterRow(
                          selected: state.gradeFilter,
                          onSelected: cubit.selectGrade,
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$title · ${state.filtered.length} items',
                                style:
                                    AppTextStyles.title.copyWith(fontSize: 16),
                              ),
                              GestureDetector(
                                onTap: () => cubit.selectSort(
                                    state.sort == ProductSort.priceHigh
                                        ? ProductSort.priceLow
                                        : ProductSort.priceHigh),
                                behavior: HitTestBehavior.opaque,
                                child: Text(
                                  'Sort: Price '
                                  '${state.sort == ProductSort.priceHigh ? '↓' : '↑'}',
                                  style: AppTextStyles.label.copyWith(
                                      fontSize: 12,
                                      letterSpacing: 0,
                                      color: AppColors.primary),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (state.status == CategoryStatus.loading ||
                            state.status == CategoryStatus.initial)
                          const ProductGridSkeleton()
                        else if (state.filtered.isEmpty)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 40, 16, 40),
                            child: Center(
                              child: Column(
                                children: [
                                  const Icon(Icons.inventory_2_outlined,
                                      size: 44, color: AppColors.light),
                                  const SizedBox(height: 12),
                                  Text('No listings here yet',
                                      style: AppTextStyles.title
                                          .copyWith(fontSize: 15)),
                                  const SizedBox(height: 4),
                                  Text(
                                      'Check back soon for items in this category',
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.subtitle),
                                ],
                              ),
                            ),
                          )
                        else
                          WishlistProductGrid(
                            products: state.filtered,
                            onTap: (p) => context.push(AppRoute.product.path,
                                extra: p),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
