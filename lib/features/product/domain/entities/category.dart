import 'package:equatable/equatable.dart';

/// A top-level browse category (the home pills / category header).
class ShopCategory extends Equatable {
  final String id;
  final String label;
  final String icon;
  final String? slug;
  const ShopCategory({
    required this.id,
    required this.label,
    required this.icon,
    this.slug,
  });

  @override
  List<Object?> get props => [id, label, icon, slug];
}

/// Static category lists. Move to the repository/API later if they become dynamic.
const List<ShopCategory> kCategories = [
  ShopCategory(id: 'electronics', label: 'Electronics', icon: '📱'),
  ShopCategory(id: 'gaming', label: 'Gaming', icon: '🎮'),
  ShopCategory(id: 'laptops', label: 'Laptops', icon: '💻'),
  ShopCategory(id: 'tablets', label: 'Tablets', icon: '📱'),
  ShopCategory(id: 'tvs', label: 'TVs', icon: '📺'),
];

const List<ShopCategory> kSubCategories = [
  ShopCategory(id: 'smartphones', label: 'Smartphones', icon: '📱'),
  ShopCategory(id: 'laptops', label: 'Laptops', icon: '💻'),
  ShopCategory(id: 'gaming', label: 'Gaming', icon: '🎮'),
  ShopCategory(id: 'cameras', label: 'Cameras', icon: '📷'),
  ShopCategory(id: 'audio', label: 'Audio', icon: '🎧'),
  ShopCategory(id: 'wearables', label: 'Wearables', icon: '⌚'),
];
