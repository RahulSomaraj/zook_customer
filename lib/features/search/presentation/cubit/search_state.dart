part of 'search_cubit.dart';

enum SearchStatus { initial, loading, loaded, failure }

class SearchState extends Equatable {
  final SearchStatus status;
  final String query;
  final int activeFilterIndex;
  final List<ShopCategory> categories;
  final ProductSort sort;
  final List<Product> results;
  final String? errorMessage;

  const SearchState({
    this.status = SearchStatus.initial,
    this.query = '',
    this.activeFilterIndex = 0,
    this.categories = const [],
    this.sort = ProductSort.priceLow,
    this.results = const [],
    this.errorMessage,
  });

  /// Results after applying the selected category chip (index 0 = "All").
  List<Product> get filtered {
    if (activeFilterIndex <= 0 || activeFilterIndex > categories.length) {
      return results;
    }
    final categoryId = categories[activeFilterIndex - 1].id;
    return results.where((p) => p.categoryId == categoryId).toList();
  }

  /// Chip labels: "All" followed by each category name.
  List<String> get filterLabels =>
      ['All', ...categories.map((c) => c.label)];

  SearchState copyWith({
    SearchStatus? status,
    String? query,
    int? activeFilterIndex,
    List<ShopCategory>? categories,
    ProductSort? sort,
    List<Product>? results,
    String? errorMessage,
  }) {
    return SearchState(
      status: status ?? this.status,
      query: query ?? this.query,
      activeFilterIndex: activeFilterIndex ?? this.activeFilterIndex,
      categories: categories ?? this.categories,
      sort: sort ?? this.sort,
      results: results ?? this.results,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        query,
        activeFilterIndex,
        categories,
        sort,
        results,
        errorMessage,
      ];
}
