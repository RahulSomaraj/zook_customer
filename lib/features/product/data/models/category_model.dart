import '../../domain/entities/category.dart';

/// Data-layer model for a category returned by `/categories`.
class CategoryModel extends ShopCategory {
  const CategoryModel({
    required super.id,
    required super.label,
    required super.icon,
    super.slug,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json['id']?.toString() ?? '',
        label: (json['name'] ?? '').toString(),
        icon: (json['icon'] ?? '📦').toString(),
        slug: json['slug'] as String?,
      );
}
