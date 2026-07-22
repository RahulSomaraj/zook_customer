import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Semantic style of a [ZookAlert].
enum ZookAlertType { success, warning, error, info, neutral }

/// Inline status banner: a tinted, bordered card with a status icon, a bold
/// title and a supporting message. Used for success/warning/error/info/neutral
/// feedback across the app.
class ZookAlert extends StatelessWidget {
  final ZookAlertType type;
  final String title;
  final String message;

  /// Optional icon override; defaults to the type's semantic icon.
  final IconData? icon;

  const ZookAlert({
    super.key,
    required this.type,
    required this.title,
    required this.message,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final s = _styleFor(type);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: s.bg,
        border: Border.all(color: s.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon ?? s.icon, size: 20, color: s.iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: s.titleColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: s.bodyColor,
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

/// Shows a [ZookAlert] as a floating, transient banner (replaces plain
/// Material SnackBars). Any currently visible banner is dismissed first.
void showZookAlert(
  BuildContext context, {
  required ZookAlertType type,
  required String title,
  required String message,
  Duration duration = const Duration(seconds: 3),
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        padding: EdgeInsets.zero,
        duration: duration,
        content: ZookAlert(type: type, title: title, message: message),
      ),
    );
}

class _AlertStyle {
  final Color bg;
  final Color border;
  final Color iconColor;
  final Color titleColor;
  final Color bodyColor;
  final IconData icon;
  const _AlertStyle({
    required this.bg,
    required this.border,
    required this.iconColor,
    required this.titleColor,
    required this.bodyColor,
    required this.icon,
  });
}

_AlertStyle _styleFor(ZookAlertType type) {
  switch (type) {
    case ZookAlertType.success:
      return const _AlertStyle(
        bg: Color(0xFFF0FDF4),
        border: Color(0xFFBBF7D0),
        iconColor: Color(0xFF16A34A),
        titleColor: Color(0xFF15803D),
        bodyColor: Color(0xFF15803D),
        icon: Icons.check_circle,
      );
    case ZookAlertType.warning:
      return const _AlertStyle(
        bg: Color(0xFFFFFBEB),
        border: Color(0xFFFDE68A),
        iconColor: Color(0xFFF59E0B),
        titleColor: Color(0xFFB45309),
        bodyColor: Color(0xFFB45309),
        icon: Icons.warning_amber_rounded,
      );
    case ZookAlertType.error:
      return const _AlertStyle(
        bg: Color(0xFFFEF2F2),
        border: Color(0xFFFECACA),
        iconColor: Color(0xFFEF4444),
        titleColor: Color(0xFFDC2626),
        bodyColor: Color(0xFFDC2626),
        icon: Icons.cancel,
      );
    case ZookAlertType.info:
      return const _AlertStyle(
        bg: Color(0xFFEFF6FF),
        border: Color(0xFFBFDBFE),
        iconColor: Color(0xFF2563EB),
        titleColor: Color(0xFF1D4ED8),
        bodyColor: Color(0xFF1D4ED8),
        icon: Icons.info,
      );
    case ZookAlertType.neutral:
      return _AlertStyle(
        bg: AppColors.surface,
        border: AppColors.border,
        iconColor: const Color(0xFF92400E),
        titleColor: AppColors.black,
        bodyColor: AppColors.mid,
        icon: Icons.inventory_2,
      );
  }
}
