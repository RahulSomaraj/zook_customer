import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../address/presentation/cubit/address_cubit.dart';
import '../../../address/presentation/widgets/add_address_sheet.dart';
import '../../../address/presentation/widgets/select_address_sheet.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  int _payIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AddressCubit>(
      create: (_) => sl<AddressCubit>(),
      child: _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<CartCubit, CartState>(
          builder: (context, state) {
            return Column(
              children: [
                // Header
                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    border: Border(bottom: BorderSide(color: AppColors.border)),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: const Text('←',
                            style:
                                TextStyle(fontSize: 20, color: AppColors.mid)),
                      ),
                      const SizedBox(width: 10),
                      Text('Checkout',
                          style: AppTextStyles.title.copyWith(fontSize: 17)),
                    ],
                  ),
                ),
                Expanded(
                  child: ColoredBox(
                    color: AppColors.surface,
                    child: ListView(
                    padding: const EdgeInsets.only(bottom: 16),
                    children: [
                      const _DeliveryAddressSection(),
                      _Section(
                        title: '💳 Payment method',
                        action: 'Add card',
                        child: Column(
                          children: [
                            _PayOption(
                              icon: '💳',
                              name: 'Visa ending ×××× 4821',
                              meta: 'Expires 09/27',
                              selected: _payIndex == 0,
                              onTap: () => setState(() => _payIndex = 0),
                            ),
                            const Divider(height: 1, color: AppColors.border),
                            _PayOption(
                              icon: '🍎',
                              name: 'Apple Pay',
                              meta: 'Touch ID to pay',
                              selected: _payIndex == 1,
                              onTap: () => setState(() => _payIndex = 1),
                            ),
                            const Divider(height: 1, color: AppColors.border),
                            _PayOption(
                              icon: '🛍️',
                              name: 'Tabby — Pay in 4',
                              meta:
                                  'AED ${formatAmount(state.tabbyInstalment)} × 4 · 0% interest',
                              selected: _payIndex == 2,
                              onTap: () => setState(() => _payIndex = 2),
                            ),
                          ],
                        ),
                      ),
                      _Section(
                        title: '🛒 Items (${state.itemCount})',
                        child: Column(
                          children: [
                            for (final item in state.items)
                              _MiniItem(item: item),
                            Container(
                              margin: const EdgeInsets.only(top: 10),
                              padding: const EdgeInsets.only(top: 10),
                              decoration: const BoxDecoration(
                                border: Border(
                                    top: BorderSide(color: AppColors.border)),
                              ),
                              child: Column(
                                children: [
                                  _sumRow('Subtotal',
                                      'AED ${formatAmount(state.subtotal)}'),
                                  _sumRow(
                                      'Delivery',
                                      state.deliveryFee == 0
                                          ? 'Free'
                                          : 'AED ${state.deliveryFee}',
                                      valueColor: state.deliveryFee == 0
                                          ? AppColors.success
                                          : null),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Total',
                                          style: AppTextStyles.body.copyWith(
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.black)),
                                      Text(
                                          'AED ${formatAmount(state.total)}',
                                          style: AppTextStyles.title
                                              .copyWith(fontSize: 15)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  ),
                ),
                // CTA
                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    border: Border(top: BorderSide(color: AppColors.border)),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () =>
                                  context.go(AppRoute.orderConfirmed.path),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                elevation: 0,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(9999)),
                              ),
                              child: Text(
                                  'Pay AED ${formatAmount(state.total)} →',
                                  style: AppTextStyles.button),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('🔒 Secured by Mamo Pay',
                              style: AppTextStyles.caption
                                  .copyWith(fontSize: 11, color: AppColors.light)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _sumRow(String key, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key,
              style: AppTextStyles.caption
                  .copyWith(fontSize: 13, color: AppColors.mid)),
          Text(value,
              style: AppTextStyles.body.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppColors.charcoal)),
        ],
      ),
    );
  }
}

/// Delivery-address card backed by [AddressCubit]. Shows the selected address
/// (or an empty prompt) with a Change / Add action that opens the sheets.
class _DeliveryAddressSection extends StatefulWidget {
  const _DeliveryAddressSection();

  @override
  State<_DeliveryAddressSection> createState() =>
      _DeliveryAddressSectionState();
}

class _DeliveryAddressSectionState extends State<_DeliveryAddressSection> {
  @override
  void initState() {
    super.initState();
    // Fetch saved addresses once this section is mounted and subscribed.
    context.read<AddressCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AddressCubit>();
    return BlocBuilder<AddressCubit, AddressState>(
      builder: (context, state) {
        final address = state.selected;
        return _Section(
          title: '📍 Delivery address',
          action: address == null ? 'Add' : 'Change',
          onAction: () => address == null
              ? AddAddressSheet.show(context, cubit)
              : SelectAddressSheet.show(context, cubit),
          child: address == null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GestureDetector(
                      onTap: () => AddAddressSheet.show(context, cubit),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          border: Border.all(
                              color: AppColors.primary, width: 1.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text('+ Add a delivery address',
                            style: AppTextStyles.body.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary)),
                      ),
                    ),
                    if (state.errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(state.errorMessage!,
                          style: AppTextStyles.caption.copyWith(
                              fontSize: 11, color: AppColors.primary)),
                    ],
                  ],
                )
              : Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.successPale,
                    border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.25),
                        width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(address.fullName,
                              style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.black)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: Text(address.label,
                                style: AppTextStyles.caption.copyWith(
                                    fontSize: 10, color: AppColors.mid)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                          '${address.streetLine}\n${address.regionLine}',
                          style: AppTextStyles.caption.copyWith(
                              fontSize: 12,
                              color: AppColors.mid,
                              height: 1.5)),
                      const SizedBox(height: 3),
                      Text(address.phone,
                          style: AppTextStyles.caption.copyWith(
                              fontSize: 12, color: AppColors.mid)),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  final Widget child;
  const _Section({
    required this.title,
    this.action,
    this.onAction,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: AppTextStyles.body.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.black)),
                if (action != null)
                  GestureDetector(
                    onTap: onAction,
                    behavior: HitTestBehavior.opaque,
                    child: Text(action!,
                        style: AppTextStyles.label.copyWith(
                            fontSize: 12,
                            letterSpacing: 0,
                            color: AppColors.primary)),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _PayOption extends StatelessWidget {
  final String icon;
  final String name;
  final String meta;
  final bool selected;
  final VoidCallback onTap;
  const _PayOption({
    required this.icon,
    required this.name,
    required this.meta,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                    color: selected ? AppColors.primary : AppColors.border,
                    width: 2),
              ),
              child: selected
                  ? const Icon(Icons.check, size: 12, color: AppColors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: AppTextStyles.body.copyWith(
                          fontSize: 13, fontWeight: FontWeight.w700)),
                  Text(meta,
                      style: AppTextStyles.caption
                          .copyWith(fontSize: 11, color: AppColors.light)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniItem extends StatelessWidget {
  final CartItem item;
  const _MiniItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final p = item.product;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: p.imageGradient),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.border),
            ),
            alignment: Alignment.center,
            child: Text(p.emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body.copyWith(
                        fontSize: 12, fontWeight: FontWeight.w700)),
                if (p.store != null)
                  Text(p.store!,
                      style: AppTextStyles.caption
                          .copyWith(fontSize: 10, color: AppColors.light)),
              ],
            ),
          ),
          Text('AED ${formatAmount(p.priceAed)}',
              style: AppTextStyles.body.copyWith(
                  fontSize: 13, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
