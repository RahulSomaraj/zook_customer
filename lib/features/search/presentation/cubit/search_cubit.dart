import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../product/domain/entities/category.dart';
import '../../../product/domain/entities/product.dart';
import '../../../product/domain/entities/product_sort.dart';
import '../../../product/domain/repositories/category_repository.dart';
import '../../../product/domain/repositories/product_repository.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final ProductRepository repository;
  final CategoryRepository categoryRepository;

  /// Debounces keystrokes so the `/products?search=` API isn't hit on every
  /// character.
  Timer? _debounce;

  SearchCubit({
    required this.repository,
    required this.categoryRepository,
  }) : super(const SearchState());

  /// Loads the category chips, optionally pre-selects [category], then runs an
  /// initial search for [initialQuery].
  Future<void> init(String initialQuery, [ShopCategory? category]) async {
    final categoriesResult = await categoryRepository.getCategories();
    final categories = categoriesResult.fold(
      (_) => kCategories,
      (list) => list.isEmpty ? kCategories : list,
    );

    var filterIndex = 0;
    if (category != null) {
      final i = categories.indexWhere((c) => c.id == category.id);
      if (i >= 0) filterIndex = i + 1; // +1 because index 0 is "All"
    }

    emit(state.copyWith(categories: categories, activeFilterIndex: filterIndex));
    await _run(initialQuery);
  }

  /// Called on each keystroke — updates the text immediately and schedules the
  /// actual search after a short pause.
  void search(String query) {
    _debounce?.cancel();
    emit(state.copyWith(query: query));
    _debounce =
        Timer(const Duration(milliseconds: 350), () => _run(query));
  }

  /// Flips the price sort direction (low↔high) and re-runs the current query.
  Future<void> togglePriceSort() async {
    final next = state.sort == ProductSort.priceLow
        ? ProductSort.priceHigh
        : ProductSort.priceLow;
    emit(state.copyWith(sort: next));
    await _run(state.query);
  }

  Future<void> _run(String query) async {
    emit(state.copyWith(status: SearchStatus.loading, query: query));
    final result = await repository.search(query, sort: state.sort.apiValue);
    result.fold(
      (f) => emit(state.copyWith(
          status: SearchStatus.failure, errorMessage: f.message)),
      (items) =>
          emit(state.copyWith(status: SearchStatus.loaded, results: items)),
    );
  }

  void clear() {
    _debounce?.cancel();
    emit(state.copyWith(query: '', activeFilterIndex: 0));
    _run('');
  }

  void selectFilter(int index) =>
      emit(state.copyWith(activeFilterIndex: index));

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
