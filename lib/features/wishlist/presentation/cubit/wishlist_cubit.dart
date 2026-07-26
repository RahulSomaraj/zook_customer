import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../product/domain/entities/product.dart';
import '../../domain/repositories/wishlist_repository.dart';

part 'wishlist_state.dart';

/// App-wide wishlist state. Registered as a singleton (like [CartCubit]) so
/// every screen sees the same set of wishlisted products.
///
/// Toggles are optimistic: the heart flips immediately, the API call runs in
/// the background, and the change is reverted if the request fails.
class WishlistCubit extends Cubit<WishlistState> {
  final WishlistRepository repository;
  WishlistCubit({required this.repository}) : super(const WishlistState());

  bool isWishlisted(String productId) => state.ids.contains(productId);

  bool _serverLoaded = false;

  /// Fetches the real wishlist from the server once and replaces membership,
  /// so counts (e.g. the profile "Saved" stat) are accurate.
  Future<void> loadServer() async {
    if (_serverLoaded) return;
    _serverLoaded = true;
    final res = await repository.getWishlist();
    res.fold(
      (_) {},
      (items) => emit(state.copyWith(ids: items.map((p) => p.id).toSet())),
    );
  }

  /// Clears all local wishlist state and re-arms the one-shot server fetch,
  /// so the next login reloads the correct wishlist (e.g. on logout).
  void reset() {
    _serverLoaded = false;
    emit(const WishlistState());
  }

  /// Seeds membership from product flags coming off the catalog API
  /// (`is_wishlisted`). Never removes ids already known locally.
  void seedFrom(Iterable<Product> products) {
    final add = products.where((p) => p.isWishlisted).map((p) => p.id).toSet();
    if (add.isEmpty || add.every(state.ids.contains)) return;
    emit(state.copyWith(ids: {...state.ids, ...add}));
  }

  /// Seeds membership from a set of ids known to be wishlisted (e.g. the
  /// Favourites page fetched from the API), so hearts show as filled.
  void seedIds(Iterable<String> ids) {
    final add = ids.toSet();
    if (add.isEmpty || add.every(state.ids.contains)) return;
    emit(state.copyWith(ids: {...state.ids, ...add}));
  }

  /// Flips wishlist membership for [product] and syncs with the server.
  Future<void> toggle(Product product) async {
    final id = product.id;
    if (state.pending.contains(id)) return; // ignore rapid double taps

    final wasWishlisted = state.ids.contains(id);
    final optimistic = {...state.ids};
    wasWishlisted ? optimistic.remove(id) : optimistic.add(id);

    emit(state.copyWith(
      ids: optimistic,
      pending: {...state.pending, id},
      clearError: true,
    ));

    final result = wasWishlisted
        ? await repository.remove(id)
        : await repository.add(id);

    result.fold(
      (failure) {
        // Revert the optimistic change on failure.
        final reverted = {...state.ids};
        wasWishlisted ? reverted.add(id) : reverted.remove(id);
        emit(state.copyWith(
          ids: reverted,
          pending: {...state.pending}..remove(id),
          errorMessage: failure.message,
        ));
      },
      (_) => emit(state.copyWith(
        pending: {...state.pending}..remove(id),
      )),
    );
  }
}
