import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../address/presentation/cubit/address_cubit.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../orders/data/orders_mock.dart';
import '../../../orders/domain/entities/customer_order.dart';
import '../../../wishlist/presentation/cubit/wishlist_cubit.dart';

/// Profile tab — header, stats, sectioned menu, and logout.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  String _initials(String? name) {
    final n = (name ?? '').trim();
    if (n.isEmpty) return 'Z';
    final parts = n.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  void _soon(BuildContext context) => ScaffoldMessenger.of(context)
      .showSnackBar(const SnackBar(content: Text('Coming soon')));

  void _logout(BuildContext context) {
    context.read<AuthBloc>().add(const LogoutRequested());
    context.read<WishlistCubit>().reset();
    context.go(AppRoute.login.path);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthBloc>().state.user;
    final hasName = (user?.fullName?.trim().isNotEmpty ?? false);
    final name = hasName ? user!.fullName!.trim() : 'Zook User';
    final phone = user?.phoneNumber ?? '';
    final savedCount = context.watch<WishlistCubit>().state.ids.length;
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<WishlistCubit>().loadServer());
    final orderCount = kMockOrders.length;
    final activeCount = kMockOrders.where((o) => o.status.isActive).length;

    return BlocProvider<AddressCubit>(
      create: (_) => sl<AddressCubit>()..load(),
      child: Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          // Dark header
          _Header(
            initials: _initials(user?.fullName),
            name: name,
            phone: phone.isEmpty ? 'Signed in' : '$phone · Dubai, UAE',
            onSettings: () => _soon(context),
          ),
          // Stats
          Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Stat(value: '$orderCount', label: 'Orders'),
                  _statDivider(),
                  const _Stat(value: '2', label: 'Selling'),
                  _statDivider(),
                  _Stat(value: '$savedCount', label: 'Saved'),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const _SectionLabel('Buying'),
                _MenuItem(
                  icon: Icons.inventory_2_outlined,
                  iconColor: const Color(0xFF1D4ED8),
                  iconBg: const Color(0xFFEFF6FF),
                  label: 'My Orders',
                  sub: '$orderCount orders · $activeCount active',
                  badge: activeCount > 0 ? '$activeCount' : null,
                  onTap: () => context.go(AppRoute.orders.path),
                ),
                _MenuItem(
                  icon: Icons.favorite,
                  iconColor: AppColors.primary,
                  iconBg: const Color(0xFFFDF4FF),
                  label: 'Saved Items',
                  sub: '$savedCount items saved',
                  onTap: () => context.push(AppRoute.favourites.path),
                ),
                Builder(
                  builder: (context) {
                    final count = context
                        .watch<AddressCubit>()
                        .state
                        .addresses
                        .length;
                    return _MenuItem(
                      icon: Icons.location_on_outlined,
                      iconColor: const Color(0xFF15803D),
                      iconBg: AppColors.successPale,
                      label: 'Delivery Addresses',
                      sub: count == 0
                          ? 'Add a delivery address'
                          : '$count saved address${count == 1 ? '' : 'es'}',
                      onTap: () => context.push(AppRoute.addresses.path),
                    );
                  },
                ),
                const _SectionLabel('Selling'),
                _MenuItem(
                  icon: Icons.add,
                  iconColor: AppColors.primaryDark,
                  iconBg: AppColors.primaryPale,
                  label: 'Sell an Item',
                  sub: 'Submit for inspection',
                  onTap: () => _soon(context),
                ),
                _MenuItem(
                  icon: Icons.assignment_outlined,
                  iconColor: const Color(0xFFB45309),
                  iconBg: const Color(0xFFFFFBEB),
                  label: 'My Submissions',
                  sub: '2 items · 1 live',
                  badge: '1',
                  onTap: () => _soon(context),
                ),
                _MenuItem(
                  icon: Icons.account_balance_wallet_outlined,
                  iconColor: const Color(0xFF15803D),
                  iconBg: AppColors.successPale,
                  label: 'Seller Payouts',
                  sub: 'Bank transfer history',
                  onTap: () => _soon(context),
                ),
                const _SectionLabel('Account'),
                _MenuItem(
                  icon: Icons.person_outline,
                  iconColor: AppColors.mid,
                  iconBg: AppColors.surface,
                  label: 'Edit Profile',
                  sub: 'Name, phone, Emirates ID',
                  onTap: () => _soon(context),
                ),
                _MenuItem(
                  icon: Icons.notifications_outlined,
                  iconColor: AppColors.mid,
                  iconBg: AppColors.surface,
                  label: 'Notifications',
                  sub: 'Order alerts, promotions',
                  onTap: () => _soon(context),
                ),
                _MenuItem(
                  icon: Icons.lock_outline,
                  iconColor: AppColors.mid,
                  iconBg: AppColors.surface,
                  label: 'Privacy & Security',
                  sub: 'Password, data, permissions',
                  onTap: () => _soon(context),
                ),
                _MenuItem(
                  icon: Icons.chat_bubble_outline,
                  iconColor: AppColors.mid,
                  iconBg: AppColors.surface,
                  label: 'Help & Support',
                  sub: 'FAQs, live chat, contact',
                  onTap: () => _soon(context),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: GestureDetector(
                    onTap: () => _logout(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.2),
                            width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.logout,
                              size: 16, color: AppColors.error),
                          const SizedBox(width: 8),
                          Text('Log out',
                              style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.error)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  // Full-height divider (matches the mockup's border-right between stats).
  Widget _statDivider() => Container(width: 1, color: AppColors.border);
}

class _Header extends StatelessWidget {
  final String initials;
  final String name;
  final String phone;
  final VoidCallback onSettings;
  const _Header({
    required this.initials,
    required this.name,
    required this.phone,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
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
                  AppColors.primary.withValues(alpha: 0.18),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppStrings.appName.toUpperCase(),
                          style: AppTextStyles.brand(size: 20)),
                      GestureDetector(
                        onTap: onSettings,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 34,
                          height: 34,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.settings_outlined,
                              size: 18,
                              color: AppColors.white.withValues(alpha: 0.7)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: 64,
                    height: 64,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.white.withValues(alpha: 0.15),
                          width: 3),
                    ),
                    child: Text(initials,
                        style: AppTextStyles.title
                            .copyWith(color: AppColors.white, fontSize: 22)),
                  ),
                  const SizedBox(height: 10),
                  Text(name,
                      style: AppTextStyles.title
                          .copyWith(color: AppColors.white, fontSize: 18)),
                  const SizedBox(height: 3),
                  Text(phone,
                      style: TextStyle(
                          fontSize: 13,
                          color: AppColors.white.withValues(alpha: 0.4))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Text(value,
                style: AppTextStyles.title
                    .copyWith(fontSize: 20, color: AppColors.black)),
            const SizedBox(height: 2),
            Text(label.toUpperCase(),
                style: AppTextStyles.caption.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: AppColors.light)),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(text.toUpperCase(),
          style: AppTextStyles.caption.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppColors.light)),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String sub;
  final String? badge;
  final VoidCallback onTap;
  const _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.sub,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: AppTextStyles.body.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.charcoal)),
                  const SizedBox(height: 1),
                  Text(sub,
                      style: AppTextStyles.caption.copyWith(fontSize: 11)),
                ],
              ),
            ),
            if (badge != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(badge!,
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white)),
              )
            else
              const Icon(Icons.chevron_right,
                  size: 18, color: AppColors.light),
          ],
        ),
      ),
    );
  }
}
