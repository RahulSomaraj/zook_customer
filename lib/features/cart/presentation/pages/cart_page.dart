import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../cubit/cart_cubit.dart';
import '../widgets/cart_item_tile.dart';
import '../widgets/order_summary.dart';
import '../../../../core/widgets/z_icon.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    // Sync the cart from the server whenever it's opened.
    context.read<CartCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<CartCubit, CartState>(
          builder: (context, state) {
            final header = Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('My Cart',
                      style: AppTextStyles.title.copyWith(fontSize: 20)),
                  Text('${state.itemCount} items',
                      style: AppTextStyles.caption.copyWith(fontSize: 13)),
                ],
              ),
            );

            return Column(
              children: [
                Expanded(
                  child: ColoredBox(
                    color: AppColors.surface,
                    child: state.isEmpty
                      ? Column(
                          children: [
                            header,
                            Expanded(
                              child: _EmptyCart(
                                  onShop: () =>
                                      context.go(AppRoute.home.path)),
                            ),
                          ],
                        )
                      : ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            header,
                            for (final item in state.items) ...[
                              CartItemTile(
                                item: item,
                                onTap: () => context.push(
                                    AppRoute.product.path,
                                    extra: item.product),
                                onRemove: () => context
                                    .read<CartCubit>()
                                    .remove(item.product.id),
                              ),
                              const Divider(
                                  height: 1, color: AppColors.border),
                            ],
                            OrderSummary(
                              itemCount: state.itemCount,
                              subtotal: state.subtotal,
                              deliveryFee: state.deliveryFee,
                              total: state.total,
                            ),
                            _TabbyNote(instalment: state.tabbyInstalment),
                            const SizedBox(height: 8),
                          ],
                        ),
                  ),
                ),
                if (!state.isEmpty)
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
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => context.push(AppRoute.checkout.path),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              elevation: 0,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(9999)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Proceed to Checkout',
                                    style: AppTextStyles.button),
                                const SizedBox(width: 6),
                                const ZIcon('chev-r',
                                    size: 16, color: AppColors.white),
                              ],
                            ),
                          ),
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
}

class _TabbyNote extends StatelessWidget {
  final int instalment;
  const _TabbyNote({required this.instalment});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text.rich(TextSpan(
              style: AppTextStyles.body.copyWith(
                  fontSize: 13, color: AppColors.charcoal, height: 1.5),
              children: [
                const TextSpan(text: 'As low as '),
                TextSpan(
                    text: 'AED ${formatAmount(instalment)}/month',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, color: AppColors.black)),
                const TextSpan(text: '\nor 4 interest-free payments.'),
              ],
            )),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF3EEDBF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text('tabby',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F1F1A),
                    letterSpacing: -0.2)),
          ),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  final VoidCallback onShop;
  const _EmptyCart({required this.onShop});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🛒', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 12),
          Text('Your cart is empty', style: AppTextStyles.title.copyWith(fontSize: 16)),
          const SizedBox(height: 6),
          Text('Browse listings and add items here',
              style: AppTextStyles.subtitle),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onShop,
            child: Text('Start shopping →',
                style: AppTextStyles.label.copyWith(
                    letterSpacing: 0, color: AppColors.primary, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
