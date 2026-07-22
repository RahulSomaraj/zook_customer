part of 'home_cubit.dart';

enum HomeStatus { initial, loading, loaded, failure }

class HomeState extends Equatable {
  final HomeStatus status;
  final List<ShopCategory> categories;
  final List<Product> recentlyListed;
  final List<Product> topPicks;
  final int selectedCategoryIndex;
  final String? errorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.categories = const [],
    this.recentlyListed = const [],
    this.topPicks = const [],
    this.selectedCategoryIndex = 0,
    this.errorMessage,
  });

  HomeState copyWith({
    HomeStatus? status,
    List<ShopCategory>? categories,
    List<Product>? recentlyListed,
    List<Product>? topPicks,
    int? selectedCategoryIndex,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      recentlyListed: recentlyListed ?? this.recentlyListed,
      topPicks: topPicks ?? this.topPicks,
      selectedCategoryIndex:
          selectedCategoryIndex ?? this.selectedCategoryIndex,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        categories,
        recentlyListed,
        topPicks,
        selectedCategoryIndex,
        errorMessage,
      ];
}
