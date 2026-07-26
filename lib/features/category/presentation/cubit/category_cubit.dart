import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../product/domain/entities/category.dart';
import '../../../product/domain/entities/product.dart';
import '../../../product/domain/entities/product_grade.dart';
import '../../../product/domain/entities/product_sort.dart';
import '../../../product/domain/repositories/category_repository.dart';
import '../../../product/domain/repositories/product_repository.dart';

part 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final ProductRepository productRepository;
  final CategoryRepository categoryRepository;
  CategoryCubit({
    required this.productRepository,
    required this.categoryRepository,
  }) : super(const CategoryState());

  /// Loads the shared category list (same source as the home pills), selects
  /// the category the user tapped, and fetches its listings.
  Future<void> load(String categoryId, String categoryName) async {
    emit(state.copyWith(
      status: CategoryStatus.loading,
      selectedCategoryId: categoryId,
      selectedCategoryName: categoryName,
    ));

    final catResult = await categoryRepository.getCategories();
    final categories = catResult.fold(
      (_) => kCategories,
      (list) => list.isEmpty ? kCategories : list,
    );

    var selId = categoryId;
    var selName = categoryName;
    if (categories.isNotEmpty && !categories.any((c) => c.id == selId)) {
      selId = categories.first.id;
      selName = categories.first.label;
    }

    emit(state.copyWith(
      categories: categories,
      selectedCategoryId: selId,
      selectedCategoryName: selName,
    ));

    await _loadProducts(selId);
  }

  /// Switches the active category (tapping a different block up top).
  Future<void> selectCategory(ShopCategory category) async {
    if (category.id == state.selectedCategoryId) return;
    emit(state.copyWith(
      status: CategoryStatus.loading,
      selectedCategoryId: category.id,
      selectedCategoryName: category.label,
      gradeFilter: GradeFilter.all,
    ));
    await _loadProducts(category.id);
  }

  /// Changes the sort order and re-queries the current category.
  Future<void> selectSort(ProductSort sort) async {
    if (sort == state.sort) return;
    emit(state.copyWith(status: CategoryStatus.loading, sort: sort));
    await _loadProducts(state.selectedCategoryId);
  }

  Future<void> _loadProducts(String categoryId) async {
    final result = await productRepository.getByCategory(
      categoryId,
      sort: state.sort.apiValue,
    );
    result.fold(
      (f) => emit(state.copyWith(
          status: CategoryStatus.failure, errorMessage: f.message)),
      (items) =>
          emit(state.copyWith(status: CategoryStatus.loaded, products: items)),
    );
  }

  void selectGrade(GradeFilter grade) =>
      emit(state.copyWith(gradeFilter: grade));
}
