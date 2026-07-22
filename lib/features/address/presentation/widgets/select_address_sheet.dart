import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/address.dart';
import '../cubit/address_cubit.dart';
import 'add_address_sheet.dart';

/// Bottom sheet to pick a saved address or add a new one.
class SelectAddressSheet extends StatelessWidget {
  final AddressCubit cubit;
  const SelectAddressSheet({super.key, required this.cubit});

  static Future<void> show(BuildContext context, AddressCubit cubit) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SelectAddressSheet(cubit: cubit),
    );
  }

  Future<void> _confirmRemove(
    BuildContext context,
    AddressCubit cubit,
    Address address,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove address?'),
        content: Text(
            'Remove "${address.fullName}, ${address.streetLine}" from your saved addresses?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await cubit.remove(address);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: BlocBuilder<AddressCubit, AddressState>(
        bloc: cubit,
        builder: (context, state) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Row(
                  children: [
                    Text('Delivery address',
                        style: AppTextStyles.title.copyWith(fontSize: 17)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Text('✕',
                          style:
                              TextStyle(fontSize: 16, color: AppColors.light)),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  children: [
                    for (final a in state.addresses)
                      _AddressTile(
                        address: a,
                        selected: a.id == state.selectedId,
                        onTap: () {
                          cubit.select(a);
                          Navigator.of(context).pop();
                        },
                        onRemove: () => _confirmRemove(context, cubit, a),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: GestureDetector(
                  onTap: () async {
                    final added = await AddAddressSheet.show(context, cubit);
                    if (added == true && context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary, width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text('+ Add new address',
                        style: AppTextStyles.body.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AddressTile extends StatelessWidget {
  final Address address;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onRemove;
  const _AddressTile({
    required this.address,
    required this.selected,
    required this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.successPale : AppColors.surface,
          border: Border.all(
            color: selected
                ? AppColors.success.withValues(alpha: 0.35)
                : AppColors.border,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.only(top: 2),
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
            Expanded(
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
                      if (address.isDefault) ...[
                        const SizedBox(width: 6),
                        Text('Default',
                            style: AppTextStyles.caption.copyWith(
                                fontSize: 10, color: AppColors.success)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(address.streetLine,
                      style: AppTextStyles.caption.copyWith(
                          fontSize: 12, color: AppColors.mid, height: 1.4)),
                  Text(address.regionLine,
                      style: AppTextStyles.caption
                          .copyWith(fontSize: 12, color: AppColors.mid)),
                  const SizedBox(height: 3),
                  Text(address.phone,
                      style: AppTextStyles.caption
                          .copyWith(fontSize: 12, color: AppColors.light)),
                ],
              ),
            ),
            if (onRemove != null)
              GestureDetector(
                onTap: onRemove,
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.only(left: 8, top: 2),
                  child: Icon(Icons.delete_outline,
                      size: 20, color: AppColors.light),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
