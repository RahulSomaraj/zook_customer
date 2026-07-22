import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../product/domain/entities/category.dart';
import '../../../product/domain/entities/product.dart';
import '../../../product/domain/repositories/category_repository.dart';
import '../../../product/domain/repositories/product_repository.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final ProductRepository repository;
  final CategoryRepository categoryRepository;

  HomeCubit({
    required this.repository,
    required this.categoryRepository,
  }) : super(const HomeState());

  Future<void> load() async {
    emit(state.copyWith(status: HomeStatus.loading));

    // Categories from the live API (fall back to the static list on failure).
    final categoriesResult = await categoryRepository.getCategories();
    final categories = categoriesResult.fold(
      (_) => kCategories,
      (list) => list.isEmpty ? kCategories : list,
    );

    final recent = await repository.getRecentlyListed();
    final picks = await repository.getTopPicks();

    recent.fold(
      (f) => emit(state.copyWith(
          status: HomeStatus.failure, errorMessage: f.message)),
      (recentList) => picks.fold(
        (f) => emit(state.copyWith(
            status: HomeStatus.failure, errorMessage: f.message)),
        (picksList) => emit(state.copyWith(
          status: HomeStatus.loaded,
          categories: categories,
          recentlyListed: recentList,
          topPicks: picksList,
        )),
      ),
    );
  }

  void selectCategory(int index) =>
      emit(state.copyWith(selectedCategoryIndex: index));
}
