part of 'category_cubit.dart';

enum CategoryStatus { initial, loading, loaded, failure }

/// Grade filter options on the category screen.
enum GradeFilter { all, a, b, c }

class CategoryState extends Equatable {
  final CategoryStatus status;
  final int selectedSubCategoryIndex;
  final GradeFilter gradeFilter;
  final List<Product> products;
  final String? errorMessage;

  const CategoryState({
    this.status = CategoryStatus.initial,
    this.selectedSubCategoryIndex = 0,
    this.gradeFilter = GradeFilter.all,
    this.products = const [],
    this.errorMessage,
  });

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
    int? selectedSubCategoryIndex,
    GradeFilter? gradeFilter,
    List<Product>? products,
    String? errorMessage,
  }) {
    return CategoryState(
      status: status ?? this.status,
      selectedSubCategoryIndex:
          selectedSubCategoryIndex ?? this.selectedSubCategoryIndex,
      gradeFilter: gradeFilter ?? this.gradeFilter,
      products: products ?? this.products,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, selectedSubCategoryIndex, gradeFilter, products, errorMessage];
}
