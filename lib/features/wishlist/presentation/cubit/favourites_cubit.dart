import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../product/domain/entities/product.dart';
import '../../domain/repositories/wishlist_repository.dart';

part 'favourites_state.dart';

/// Loads the signed-in user's saved products from `GET /wishlist`.
class FavouritesCubit extends Cubit<FavouritesState> {
  final WishlistRepository repository;
  FavouritesCubit({required this.repository}) : super(const FavouritesState());

  Future<void> load() async {
    emit(state.copyWith(status: FavStatus.loading));
    final res = await repository.getWishlist();
    res.fold(
      (f) => emit(
          state.copyWith(status: FavStatus.failure, errorMessage: f.message)),
      (items) =>
          emit(state.copyWith(status: FavStatus.loaded, products: items)),
    );
  }

  /// Drops a product from the list after it's been un-hearted.
  void removeLocal(String id) => emit(state.copyWith(
      products: state.products.where((p) => p.id != id).toList()));
}
