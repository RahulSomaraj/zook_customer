import '../../../product/data/models/product_model.dart';
import '../../../product/data/models/product_mappers.dart';
import '../../../product/domain/entities/product.dart';
import '../../../product/domain/entities/product_grade.dart';
import '../../domain/entities/cart_item.dart';

/// Data-layer model mapping a cart line from the cart API to [CartItem].
///
/// Expected shape (per api_spec.md): `{ "product": {Product}, "quantity": 1 }`.
/// Tolerates a flat line (`productId` + price) when the full product is absent.
class CartItemModel extends CartItem {
  const CartItemModel({required super.product, super.quantity});

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final qty = (json['quantity'] as num?)?.toInt() ?? 1;

    final productJson = (json['product'] as Map?)?.cast<String, dynamic>();
    Product product;
    if (productJson != null && productJson.isNotEmpty) {
      product = ProductModel.fromJson(productJson);
    } else {
      // Fallback: build a minimal product from the line item itself.
      final id =
          (json['productId'] ?? json['product_id'] ?? json['id'] ?? '')
              .toString();
      final rawUnit = json['price'] ?? json['priceAed'] ?? json['price_aed'];
      final rawLine = json['line_total_aed'] ?? json['lineTotalAed'];
      final unit = ProductMappers.price(rawUnit) != 0
          ? ProductMappers.price(rawUnit)
          : (qty > 0 ? ProductMappers.price(rawLine) ~/ qty : 0);
      product = Product(
        id: id,
        brand: (json['brand'] ?? '').toString(),
        name: (json['name'] ?? json['model'] ?? 'Item').toString(),
        priceAed: unit,
        grade: ProductGrade.b,
        emoji: '📦',
        imageGradient: ProductMappers.gradientFor(id),
      );
    }

    return CartItemModel(product: product, quantity: qty);
  }
}
