import 'package:flutter/material.dart';

/// Maps a category / sub-category id, slug, or label to a Material line icon so
/// the browse UI shows crisp vector glyphs instead of emoji — regardless of
/// whether the value comes from the static fallback list or the live API.
IconData categoryIconFor(String key) {
  final k = key.toLowerCase().trim();
  bool has(String s) => k.contains(s);

  // iPods / media players before the audio + phone checks.
  if (has('ipod') || has('music') || has('media player')) {
    return Icons.music_note;
  }
  // Audio checked before "phone" so "headphones" doesn't match smartphone.
  if (has('audio') ||
      has('headphone') ||
      has('earbud') ||
      has('speaker') ||
      has('sound')) {
    return Icons.headphones;
  }
  if (has('smartphone') ||
      has('phone') ||
      has('mobile') ||
      k == 'electronics') {
    return Icons.smartphone;
  }
  if (has('gaming') || has('game') || has('console')) {
    return Icons.sports_esports;
  }
  if (has('laptop') || has('notebook') || has('macbook')) {
    return Icons.laptop_mac;
  }
  if (has('tablet') || has('ipad')) return Icons.tablet_mac;
  if (has('tv') || has('television')) return Icons.tv;
  if (has('camera') || has('photo')) return Icons.photo_camera;
  if (has('wearable') || has('watch') || has('smartwatch')) return Icons.watch;
  if (has('furniture') || has('chair') || has('sofa') || has('home')) {
    return Icons.chair_alt;
  }
  if (has('cloth') || has('apparel') || has('fashion') || has('wear')) {
    return Icons.checkroom;
  }
  return Icons.devices_other;
}
