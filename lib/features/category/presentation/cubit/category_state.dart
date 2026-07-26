part of 'category_cubit.dart';

enum CategoryStatus { initial, loading, loaded, failure }

/// Grade filter options on the category screen.
enum GradeFilter { all, a, b, c }

class CategoryState extends Equatable {
  final CategoryStatus status;
  final List<ShopCategory> categories;
  final String selectedCategoryId;
  final String selectedCategoryName;
  final GradeFilter gradeFilter;
  final ProductSort sort;
  final List<Product> products;
  final String? errorMessage;

  const CategoryState({
    this.status = CategoryStatus.initial,
    this.categories = const [],
    this.selectedCategoryId = '',
    this.selectedCategoryName = 'Products',
    this.gradeFilter = GradeFilter.all,
    this.sort = ProductSort.priceLow,
    this.products = const [],
    this.errorMessage,
  });

  /// Index of the selected category within [categories] (-1 if not present).
  int get selectedIndex =>
      categories.indexWhere((c) => c.id == selectedCategoryId);

  /// Products after applying the active grade filter.
  List<Product> get filtered {
    switch (gradeFilter) {
      case GradeFilter.all:
        return products;
      case GradeFilter.a:
        return products.where((p) => p.grade == ProductGrade.a).toList();
      case GradeFilter.b:
        return products.where((p) => p.grade == ProductGrade.b).toList();
      case GradeFilter.c:
        return products.where((p) => p.grade == ProductGrade.c).toList();
    }
  }

  CategoryState copyWith({
    CategoryStatus? status,
    List<ShopCategory>? categories,
    String? selectedCategoryId,
    String? selectedCategoryName,
    GradeFilter? gradeFilter,
    ProductSort? sort,
    List<Product>? products,
    String? errorMessage,
  }) {
    return CategoryState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      selectedCategoryName: selectedCategoryName ?? this.selectedCategoryName,
      gradeFilter: gradeFilter ?? this.gradeFilter,
      sort: sort ?? this.sort,
      products: products ?? this.products,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        categories,
        selectedCategoryId,
        selectedCategoryName,
        gradeFilter,
        sort,
        products,
        errorMessage,
      ];
}
