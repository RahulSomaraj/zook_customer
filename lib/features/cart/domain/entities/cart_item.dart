import 'package:equatable/equatable.dart';

import '../../../product/domain/entities/product.dart';

/// A product plus the quantity the user has added to their cart.
class CartItem extends Equatable {
  final Product product;
  final int quantity;

  const CartItem({required this.product, this.quantity = 1});

  int get lineTotal => product.priceAed * quantity;

  CartItem copyWith({int? quantity}) =>
      CartItem(product: product, quantity: quantity ?? this.quantity);

  @override
  List<Object?> get props => [product.id, quantity];
}
