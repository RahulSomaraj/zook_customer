import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cube_icon.dart';

class TabItemData {
  final IconData? icon;

  /// Optional custom vector icon (takes precedence over [icon]) — used for the
  /// Feather-style isometric "box" on the Orders tab.
  final Widget Function(Color color, double size)? iconBuilder;
  final String label;
  final int? badgeCount;
  const TabItemData({
    this.icon,
    this.iconBuilder,
    required this.label,
    this.badgeCount,
  }) : assert(icon != null || iconBuilder != null);
}

/// Custom bottom tab bar matching the mockup (active indicator + cart badge).
class ZookTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final int cartCount;
  const ZookTabBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.cartCount = 0,
  });

  List<TabItemData> get _items => [
        const TabItemData(icon: Icons.search, label: 'Search'),
        TabItemData(
            icon: Icons.shopping_cart_outlined,
            label: 'Cart',
            badgeCount: cartCount > 0 ? cartCount : null),
        TabItemData(
            iconBuilder: (color, size) => CubeIcon(color: color, size: size),
            label: 'Orders'),
        const TabItemData(icon: Icons.person_outline, label: 'Profile'),
      ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            for (var i = 0; i < _items.length; i++)
              Expanded(
                  child: _Tab(
                data: _items[i],
                active: i == currentIndex,
                onTap: () => onTap(i),
              )),
          ],
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final TabItemData data;
  final bool active;
  final VoidCallback onTap;
  const _Tab({required this.data, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.light;
    final iconWidget = data.iconBuilder != null
        ? data.iconBuilder!(color, 22)
        : Icon(data.icon, size: 22, color: color);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          if (active)
            Container(
              width: 32,
              height: 3,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(9999)),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SizedBox(height: 22, child: Center(child: iconWidget)),
                    if (data.badgeCount != null)
                      Positioned(
                        top: -4,
                        right: -10,
                        child: Container(
                          width: 16,
                          height: 16,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${data.badgeCount}',
                            style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: AppColors.white),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  data.label,
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 11,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
