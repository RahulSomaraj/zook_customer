import '../../domain/entities/product.dart';
import 'product_mappers.dart';

/// Data-layer model. Maps a listing from the products API to [Product].
class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.brand,
    required super.name,
    required super.priceAed,
    required super.grade,
    required super.emoji,
    required super.imageGradient,
    super.store,
    super.categoryId,
    super.imageUrl,
    super.isWishlisted,
  });

  factory ProductModel.fromJson(
    Map<String, dynamic> json, {
    int? gradientIndex,
  }) {
    final category = (json['category'] as Map?)?.cast<String, dynamic>() ?? {};
    final vendor = (json['vendor'] as Map?)?.cast<String, dynamic>() ?? {};
    final slug = (category['slug'] ?? '').toString();
    final id = json['id']?.toString() ?? '';

    return ProductModel(
      id: id,
      brand: (json['brand'] ?? '').toString(),
      name: (json['model'] ?? '').toString(),
      priceAed: ProductMappers.price(json['price']),
      grade: ProductMappers.grade((json['conditionGrade'] ?? '').toString()),
      emoji: ProductMappers.emojiForSlug(slug),
      imageGradient: gradientIndex != null
          ? ProductMappers.gradientAt(gradientIndex)
          : ProductMappers.gradientFor(id),
      store: vendor['storeName'] as String?,
      categoryId: category['id']?.toString() ?? 'electronics',
      imageUrl: ProductMappers.imageUrl(json['thumbnailUrl']?.toString()),
      isWishlisted:
          (json['isWishlisted'] ?? json['is_wishlisted']) == true,
    );
  }
}
