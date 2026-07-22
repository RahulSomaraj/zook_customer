import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../wishlist/presentation/widgets/wishlist_product_grid.dart';
import '../cubit/category_cubit.dart';
import '../widgets/grade_filter_row.dart';
import '../widgets/subcategory_grid.dart';

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
      create: (_) => CategoryCubit(repository: sl())..load(categoryId),
      child: _CategoryView(title: categoryName),
    );
  }
}

class _CategoryView extends StatelessWidget {
  final String title;
  const _CategoryView({required this.title});

  String get _title => title;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CategoryCubit>();
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<CategoryCubit, CategoryState>(
          builder: (context, state) {
            return Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  color: AppColors.white,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.canPop()
                            ? context.pop()
                            : null,
                        behavior: HitTestBehavior.opaque,
                        child: const Icon(Icons.arrow_back,
                            size: 22, color: AppColors.mid),
                      ),
                      const SizedBox(width: 10),
                      Text(_title,
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
                        // Top grid — always visible
                        SubCategoryGrid(
                          selectedIndex: state.selectedSubCategoryIndex,
                          onSelected: cubit.selectSubCategory,
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
                                '$_title · ${state.filtered.length} items',
                                style:
                                    AppTextStyles.title.copyWith(fontSize: 16),
                              ),
                              Text('Sort ↕',
                                  style: AppTextStyles.label.copyWith(
                                      fontSize: 12,
                                      letterSpacing: 0,
                                      color: AppColors.primary)),
                            ],
                          ),
                        ),
                        // Products area — loader / empty / grid
                        if (state.status == CategoryStatus.loading ||
                            state.status == CategoryStatus.initial)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 48),
                            child: Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.primary),
                            ),
                          )
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
