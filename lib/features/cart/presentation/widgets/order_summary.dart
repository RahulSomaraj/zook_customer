import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';

class OrderSummary extends StatelessWidget {
  final int itemCount;
  final int subtotal;
  final int deliveryFee;
  final int total;
  const OrderSummary({
    super.key,
    required this.itemCount,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order summary',
              style: AppTextStyles.title.copyWith(fontSize: 14)),
          const SizedBox(height: 14),
          _row('Subtotal ($itemCount items)', 'AED ${formatAmount(subtotal)}'),
          const Divider(height: 1, color: AppColors.border),
          _row('Delivery fee', deliveryFee == 0 ? 'Free' : 'AED $deliveryFee',
              valueColor: deliveryFee == 0 ? AppColors.success : null),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total',
                  style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w800, color: AppColors.black)),
              Text('AED ${formatAmount(total)}',
                  style: AppTextStyles.title.copyWith(fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String key, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key,
              style: AppTextStyles.caption.copyWith(
                  fontSize: 13, color: AppColors.mid)),
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
