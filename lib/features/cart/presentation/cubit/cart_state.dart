part of 'cart_cubit.dart';

class CartState extends Equatable {
  final List<CartItem> items;

  const CartState({this.items = const []});

  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);
  int get subtotal => items.fold(0, (sum, i) => sum + i.lineTotal);
  int get deliveryFee => 0; // Free delivery in the mockup.
  int get total => subtotal + deliveryFee;
  bool get isEmpty => items.isEmpty;

  /// Tabby "pay in 4" monthly instalment for the whole cart.
  int get tabbyInstalment => (total / 4).round();

  CartState copyWith({List<CartItem>? items}) =>
      CartState(items: items ?? this.items);

  @override
  List<Object?> get props => [items];
}
