import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../orders/domain/entities/customer_order.dart';
import '../../../../core/widgets/z_icon.dart';

/// Order confirmation for the order returned by checkout. (The server has
/// already emptied the cart; CheckoutCubit reset the local one.)
class OrderConfirmedPage extends StatelessWidget {
  final CustomerOrder order;
  const OrderConfirmedPage({super.key, required this.order});

  String get _eta {
    final at = order.estimatedDeliveryAt;
    return at == null
        ? 'Estimated delivery in 2–4 days'
        : 'Estimated delivery: ${DateFormat('EEE d MMM').format(at)}';
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
                  order.isCod
                      ? 'Your order is confirmed. Pay AED ${formatAmount(order.totalAed)} in cash when it arrives — vendors are packing your items now.'
                      : 'Your order is confirmed and payment received. Vendors are packing your items now.',
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
                    Text('ORDER #${order.id}',
                        style: AppTextStyles.caption.copyWith(
                            fontSize: 11,
                            color: AppColors.light,
                            letterSpacing: 0.7)),
                    const SizedBox(height: 10),
                    for (final item in order.items) _OrderItem(item: item),
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
                          Text(order.isCod ? 'Total to pay' : 'Total paid',
                              style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.black)),
                          Text('AED ${formatAmount(order.totalAed)}',
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
                          Text(_eta,
                              style: AppTextStyles.body.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryDark)),
                          Text("You'll get a tracking update once it ships",
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
                        onPressed: () {
                          // Orders tab underneath, tracking on top.
                          context.go(AppRoute.orders.path);
                          context.push(AppRoute.orderTrack.path, extra: order);
                        },
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
  final OrderLine item;
  const _OrderItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: item.gradient),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            alignment: Alignment.center,
            child: item.imageUrl.isEmpty
                ? Text(item.emoji, style: const TextStyle(fontSize: 20))
                : Image.network(item.imageUrl,
                    fit: BoxFit.cover,
                    width: 44,
                    height: 44,
                    errorBuilder: (_, __, ___) => Text(item.emoji,
                        style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.quantity > 1 ? '${item.name} ×${item.quantity}' : item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body.copyWith(
                        fontSize: 12, fontWeight: FontWeight.w700)),
                if (item.storeName != null)
                  Text(item.storeName!,
                      style: AppTextStyles.caption
                          .copyWith(fontSize: 11, color: AppColors.light)),
              ],
            ),
          ),
          Text('AED ${formatAmount(item.priceAed)}',
              style: AppTextStyles.body.copyWith(
                  fontSize: 13, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
