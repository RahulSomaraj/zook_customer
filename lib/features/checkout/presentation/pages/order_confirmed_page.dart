import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../../core/widgets/z_icon.dart';

/// Order confirmation. Snapshots the cart, then clears it.
class OrderConfirmedPage extends StatefulWidget {
  const OrderConfirmedPage({super.key});

  @override
  State<OrderConfirmedPage> createState() => _OrderConfirmedPageState();
}

class _OrderConfirmedPageState extends State<OrderConfirmedPage> {
  late final List<CartItem> _items;
  late final int _total;

  @override
  void initState() {
    super.initState();
    final cart = context.read<CartCubit>();
    _items = List.of(cart.state.items);
    _total = cart.state.total;
    // Clear the cart after capturing the order snapshot.
    WidgetsBinding.instance.addPostFrameCallback((_) => cart.clear());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 20, bottom: 24),
          child: Column(
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.success.withValues(alpha: 0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 8)),
                  ],
                ),
                alignment: Alignment.center,
                child: const Text('🎉', style: TextStyle(fontSize: 40)),
              ),
              const SizedBox(height: 16),
              Text('Order placed!',
                  style: AppTextStyles.title.copyWith(fontSize: 24)),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Your order is confirmed and payment received. Vendors are packing your items now.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.subtitle,
                ),
              ),
              const SizedBox(height: 24),
              // Order card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ORDER #ORD-041',
                        style: AppTextStyles.caption.copyWith(
                            fontSize: 11,
                            color: AppColors.light,
                            letterSpacing: 0.7)),
                    const SizedBox(height: 10),
                    for (final item in _items) _OrderItem(item: item),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.only(top: 10),
                      decoration: const BoxDecoration(
                        border: Border(
                            top: BorderSide(color: AppColors.border)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total paid',
                              style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.black)),
                          Text('AED ${formatAmount(_total)}',
                              style: AppTextStyles.body.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.black)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Delivery estimate
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primaryPale,
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.15)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const ZIcon('truck', size: 26, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Estimated delivery: Wed 10 Jun',
                              style: AppTextStyles.body.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryDark)),
                          Text("Porter.ae · You'll get a tracking link by SMS",
                              style: AppTextStyles.caption.copyWith(
                                  fontSize: 11, color: AppColors.primaryLight)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.go(AppRoute.orders.path),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.black,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9999)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const ZIcon('box',
                                size: 14, color: AppColors.white),
                            const SizedBox(width: 6),
                            Text('Track my order',
                                style: AppTextStyles.button
                                    .copyWith(fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => context.go(AppRoute.home.path),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: AppColors.border, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9999)),
                        ),
                        child: Text('Continue shopping',
                            style: AppTextStyles.body.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.mid)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderItem extends StatelessWidget {
  final CartItem item;
  const _OrderItem({required this.item});

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
                          .copyWith(fontSize: 11, color: AppColors.light)),
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
