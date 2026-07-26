import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../product/domain/entities/category.dart';
import '../../../product/domain/entities/product_sort.dart';
import '../../../product/presentation/widgets/product_list_card.dart';
import '../../../wishlist/presentation/cubit/wishlist_cubit.dart';
import '../cubit/search_cubit.dart';
import '../widgets/filter_chips.dart';

class SearchPage extends StatelessWidget {
  /// When arriving from a home category pill, the search opens filtered to it.
  final ShopCategory? initialCategory;
  const SearchPage({super.key, this.initialCategory});

  @override
  Widget build(BuildContext context) {
    // Start with an empty query so the field shows the placeholder, not text.
    const initialQuery = '';
    return BlocProvider(
      create: (_) => SearchCubit(repository: sl(), categoryRepository: sl())
        ..init(initialQuery, initialCategory),
      child: _SearchView(initialQuery: initialQuery),
    );
  }
}

class _SearchView extends StatefulWidget {
  final String initialQuery;
  const _SearchView({required this.initialQuery});

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SearchCubit>();
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<SearchCubit, SearchState>(
          builder: (context, state) {
            return Column(
              children: [
                // Search bar
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: const BoxDecoration(
                    border:
                        Border(bottom: BorderSide(color: AppColors.border)),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border:
                          Border.all(color: AppColors.primary, width: 1.5),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search,
                            size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            onSubmitted: cubit.search,
                            onChanged: (v) => cubit.search(v),
                            style: AppTextStyles.body.copyWith(fontSize: 14),
                            decoration: const InputDecoration(
                              hintText: 'Search listings…',
                              isDense: true,
                              filled: false,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _controller.clear();
                            cubit.clear();
                          },
                          child: const Icon(Icons.close,
                              size: 18, color: AppColors.light),
                        ),
                      ],
                    ),
                  ),
                ),
                // Category filters
                FilterChips(
                  labels: state.filterLabels,
                  activeIndex: state.activeFilterIndex,
                  onSelected: cubit.selectFilter,
                ),
                // Results header
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${state.filtered.length} results'
                        '${state.query.isEmpty ? '' : ' for "${state.query}"'}',
                        style: AppTextStyles.body.copyWith(
                            fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      GestureDetector(
                        onTap: () => cubit.togglePriceSort(),
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
                // Results
                Expanded(
                  child: state.status == SearchStatus.loading
                      ? const ProductListSkeleton()
                      : BlocBuilder<WishlistCubit, WishlistState>(
                          builder: (context, wl) {
                            WidgetsBinding.instance.addPostFrameCallback(
                              (_) => context
                                  .read<WishlistCubit>()
                                  .seedFrom(state.filtered),
                            );
                            return ListView.builder(
                              itemCount: state.filtered.length,
                              itemBuilder: (context, i) {
                                final p = state.filtered[i];
                                return ProductListCard(
                                  product: p.copyWith(
                                      isWishlisted: wl.ids.contains(p.id)),
                                  imageGradient: AppColors.productGradientAt(i),
                                  onTap: () => context.push(
                                      AppRoute.product.path,
                                      extra: p),
                                  onWishlistTap: () => context
                                      .read<WishlistCubit>()
                                      .toggle(p),
                                );
                              },
                            );
                          },
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
