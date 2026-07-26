part of 'favourites_cubit.dart';

enum FavStatus { initial, loading, loaded, failure }

class FavouritesState extends Equatable {
  final FavStatus status;
  final List<Product> products;
  final String? errorMessage;

  const FavouritesState({
    this.status = FavStatus.initial,
    this.products = const [],
    this.errorMessage,
  });

  FavouritesState copyWith({
    FavStatus? status,
    List<Product>? products,
    String? errorMessage,
  }) {
    return FavouritesState(
      status: status ?? this.status,
      products: products ?? this.products,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, products, errorMessage];
}
