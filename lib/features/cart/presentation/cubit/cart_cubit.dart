import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../product/domain/entities/product.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';

part 'cart_state.dart';

/// Holds the user's cart, synced with the server ([CartRepository]).
///
/// Registered as a singleton so the same instance is shared across tabs, the
/// product detail screen and checkout. Mutations update local state optimistically
/// for a snappy UI, then reconcile with the server (reloading on failure).
class CartCubit extends Cubit<CartState> {
  final CartRepository repository;
  CartCubit({required this.repository}) : super(const CartState());

  /// Fetches the cart from the server and replaces local state.
  Future<void> load() async {
    final result = await repository.getCart();
    result.fold(
      (failure) => debugPrint('CartCubit.load failed: ${failure.message}'),
      (items) => emit(state.copyWith(items: items)),
    );
  }

  /// Adds a product (or increments its quantity) and syncs with the server.
  Future<void> add(Product product) async {
    final previous = state.items;
    final items = [...previous];
    final index = items.indexWhere((i) => i.product.id == product.id);
    if (index >= 0) {
      items[index] = items[index].copyWith(quantity: items[index].quantity + 1);
    } else {
      items.add(CartItem(product: product));
    }
    emit(state.copyWith(items: items)); // optimistic

    // POST /cart/items is add/increment, so send +1 (not the new total).
    final result = await repository.addItem(product.id, 1);
    result.fold((_) => _rollbackAndReload(previous), (_) {});
  }

  /// Sets the quantity of a line (removes it when [quantity] <= 0).
  Future<void> updateQuantity(String productId, int quantity) async {
    if (quantity <= 0) return remove(productId);
    final previous = state.items;
    final items = [
      for (final i in previous)
        if (i.product.id == productId) i.copyWith(quantity: quantity) else i,
    ];
    emit(state.copyWith(items: items)); // optimistic

    final result = await repository.updateItem(productId, quantity);
    result.fold((_) => _rollbackAndReload(previous), (_) {});
  }

  /// Removes a line and syncs with the server.
  Future<void> remove(String productId) async {
    final previous = state.items;
    emit(state.copyWith(
      items: previous.where((i) => i.product.id != productId).toList(),
    )); // optimistic

    final result = await repository.removeItem(productId);
    result.fold((_) => _rollbackAndReload(previous), (_) {});
  }

  /// Clears the whole cart and syncs with the server.
  Future<void> clear() async {
    final previous = state.items;
    emit(const CartState()); // optimistic

    final result = await repository.clearCart();
    result.fold((_) => _rollbackAndReload(previous), (_) {});
  }

  bool contains(String productId) =>
      state.items.any((i) => i.product.id == productId);

  /// Restores [previous] items then refreshes from the server to be safe.
  void _rollbackAndReload(List<CartItem> previous) {
    emit(state.copyWith(items: previous));
    load();
  }
}
