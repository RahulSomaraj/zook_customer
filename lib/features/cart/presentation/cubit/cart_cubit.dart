import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../product/domain/entities/product.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';

part 'cart_state.dart';

/// Holds the user's cart. The cart is **local-first**: mutations update local
/// state immediately and are authoritative, while the server endpoints (still
/// "proposed" per the API spec) are called best-effort in the background and
/// never roll the UI back. The initial server cart is fetched once.
class CartCubit extends Cubit<CartState> {
  final CartRepository repository;
  CartCubit({required this.repository}) : super(const CartState());

  /// True once we've either fetched the cart or the user has mutated it — after
  /// that we never overwrite the local cart from the server.
  bool _loaded = false;

  /// Fetches the cart from the server the first time only. Subsequent opens
  /// (or any mutation) keep the local cart so removals/edits stick.
  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    final result = await repository.getCart();
    result.fold(
      (failure) => debugPrint('CartCubit.load failed: ${failure.message}'),
      (items) => emit(state.copyWith(items: items)),
    );
  }

  /// Adds a product (or increments its quantity).
  Future<void> add(Product product) async {
    _loaded = true;
    final items = [...state.items];
    final index = items.indexWhere((i) => i.product.id == product.id);
    if (index >= 0) {
      items[index] = items[index].copyWith(quantity: items[index].quantity + 1);
    } else {
      items.add(CartItem(product: product));
    }
    emit(state.copyWith(items: items));
    final result = await repository.addItem(product.id, 1);
    result.fold(
        (f) => debugPrint('cart add sync failed: ${f.message}'), (_) {});
  }

  /// Sets the quantity of a line (removes it when [quantity] <= 0).
  Future<void> updateQuantity(String productId, int quantity) async {
    if (quantity <= 0) return remove(productId);
    _loaded = true;
    final items = [
      for (final i in state.items)
        if (i.product.id == productId) i.copyWith(quantity: quantity) else i,
    ];
    emit(state.copyWith(items: items));
    final result = await repository.updateItem(productId, quantity);
    result.fold(
        (f) => debugPrint('cart update sync failed: ${f.message}'), (_) {});
  }

  /// Removes a line from the cart.
  Future<void> remove(String productId) async {
    _loaded = true;
    emit(state.copyWith(
      items: state.items.where((i) => i.product.id != productId).toList(),
    ));
    final result = await repository.removeItem(productId);
    result.fold(
        (f) => debugPrint('cart remove sync failed: ${f.message}'), (_) {});
  }

  /// Clears the whole cart.
  Future<void> clear() async {
    _loaded = true;
    emit(const CartState());
    final result = await repository.clearCart();
    result.fold(
        (f) => debugPrint('cart clear sync failed: ${f.message}'), (_) {});
  }

  /// Clears the cart and re-arms the one-shot fetch so the next login
  /// (or app start) reloads a fresh cart. Called on logout.
  void reset() {
    _loaded = false;
    emit(const CartState());
  }

  bool contains(String productId) =>
      state.items.any((i) => i.product.id == productId);
}
