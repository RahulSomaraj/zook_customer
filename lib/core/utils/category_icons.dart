import 'package:flutter/material.dart';

/// Maps a category / sub-category id or label to a Material line icon so the
/// browse UI shows crisp vector glyphs instead of emoji.
IconData categoryIconFor(String key) {
  switch (key.toLowerCase()) {
    case 'electronics':
    case 'smartphones':
    case 'smartphone':
      return Icons.smartphone;
    case 'gaming':
      return Icons.sports_esports;
    case 'laptops':
      return Icons.laptop_mac;
    case 'tablets':
      return Icons.tablet_mac;
    case 'tvs':
    case 'tv':
      return Icons.tv;
    case 'furniture':
      return Icons.chair_alt;
    case 'clothing':
      return Icons.checkroom;
    case 'cameras':
      return Icons.photo_camera;
    case 'audio':
      return Icons.headphones;
    case 'wearables':
      return Icons.watch;
    default:
      return Icons.category_outlined;
  }
}
