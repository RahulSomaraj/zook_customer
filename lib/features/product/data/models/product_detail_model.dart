import '../../domain/entities/product_detail.dart';
import 'product_mappers.dart';

class ProductDetailModel extends ProductDetail {
  const ProductDetailModel({
    required super.id,
    required super.brand,
    required super.model,
    required super.priceAed,
    required super.grade,
    required super.categoryName,
    required super.categorySlug,
    required super.emoji,
    required super.imageGradient,
    super.year,
    super.storageVariant,
    super.color,
    super.description,
    super.whatIsIncluded,
    super.heroImageUrl,
    super.inspectionImages,
    super.vendorName,
    super.vendorAddress,
  });

  factory ProductDetailModel.fromJson(Map<String, dynamic> json) {
    final catalog = (json['catalog'] as Map?)?.cast<String, dynamic>() ?? {};
    final category =
        (catalog['category'] as Map?)?.cast<String, dynamic>() ?? {};
    final vendor = (json['vendor'] as Map?)?.cast<String, dynamic>() ?? {};
    final slug = (category['slug'] ?? '').toString();
    final id = json['id']?.toString() ?? '';

    final inspection = ((json['inspectionImages'] as List?) ?? const [])
        .map((e) => ProductMappers.imageUrl(e?.toString()))
        .where((u) => u.isNotEmpty)
        .toList();

    return ProductDetailModel(
      id: id,
      brand: (catalog['brand'] ?? '').toString(),
      model: (catalog['model'] ?? '').toString(),
      year: catalog['year'] is int
          ? catalog['year'] as int
          : int.tryParse('${catalog['year']}'),
      priceAed: ProductMappers.price(json['price']),
      grade: ProductMappers.grade((json['conditionGrade'] ?? '').toString()),
      storageVariant: json['storageVariant'] as String?,
      color: json['color'] as String?,
      description: json['description'] as String?,
      whatIsIncluded: json['whatIsIncluded'] as String?,
      categoryName: (category['name'] ?? '').toString(),
      categorySlug: slug,
      emoji: ProductMappers.emojiForSlug(slug),
      imageGradient: ProductMappers.gradientFor(id),
      heroImageUrl: ProductMappers.imageUrl(catalog['stockImageUrl']?.toString()),
      inspectionImages: inspection,
      vendorName: (vendor['storeName'] ?? '').toString(),
      vendorAddress: vendor['storeAddress'] as String?,
    );
  }
}
