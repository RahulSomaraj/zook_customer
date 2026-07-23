import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Dark home header: logo, notifications, avatar, greeting, and a search entry.
class HomeHeader extends StatelessWidget {
  final String greeting;

  /// Two-letter initials shown in the avatar once the user is logged in.
  /// Falls back to a person icon when null/empty.
  final String? avatarInitials;
  final VoidCallback? onSearchTap;
  final VoidCallback? onLogoutTap;
  const HomeHeader({
    super.key,
    required this.greeting,
    this.avatarInitials,
    this.onSearchTap,
    this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasInitials = avatarInitials != null && avatarInitials!.isNotEmpty;
    return ClipRect(
      child: Stack(
        children: [
          const Positioned.fill(child: ColoredBox(color: AppColors.black)),
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.primary.withValues(alpha: 0.2),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppStrings.appName.toUpperCase(),
                          style: AppTextStyles.brand(size: 24)),
                      Row(
                        children: [
                          _CircleIcon(
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Icon(Icons.notifications_outlined,
                                    size: 18,
                                    color: AppColors.white
                                        .withValues(alpha: 0.75)),
                                Positioned(
                                  top: -2,
                                  right: -2,
                                  child: Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: AppColors.black, width: 1.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: hasInitials
                                ? Text(
                                    avatarInitials!,
                                    style: AppTextStyles.title.copyWith(
                                      color: AppColors.white,
                                      fontSize: 13,
                                    ),
                                  )
                                : const Icon(Icons.person,
                                    size: 18, color: AppColors.white),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: onLogoutTap,
                            behavior: HitTestBehavior.opaque,
                            child: _CircleIcon(
                              child: Icon(Icons.logout,
                                  size: 16,
                                  color: AppColors.white
                                      .withValues(alpha: 0.75)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(greeting,
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.white.withValues(alpha: 0.45),
                          fontSize: 13)),
                  const SizedBox(height: 2),
                  Text('Find your next deal',
                      style: AppTextStyles.title.copyWith(
                          color: AppColors.white, fontSize: 20)),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: onSearchTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 11),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search,
                              size: 18,
                              color:
                                  AppColors.white.withValues(alpha: 0.5)),
                          const SizedBox(width: 8),
                          Text('Search listings…',
                              style: AppTextStyles.body.copyWith(
                                  color: AppColors.white
                                      .withValues(alpha: 0.4))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  final Widget child;
  const _CircleIcon({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.08),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}
