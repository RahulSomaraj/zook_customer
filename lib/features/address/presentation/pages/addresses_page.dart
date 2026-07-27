import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/address.dart';
import '../cubit/address_cubit.dart';
import '../widgets/add_address_sheet.dart';

/// Full "Delivery Addresses" manager reached from the Profile tab. Lists the
/// customer's saved addresses (same [AddressCubit] used at checkout), lets them
/// add a new one, remove one, or pick the address used by default for delivery.
class AddressesPage extends StatelessWidget {
  const AddressesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AddressCubit>(
      create: (_) => sl<AddressCubit>()..load(),
      child: const _AddressesView(),
    );
  }
}

class _AddressesView extends StatelessWidget {
  const _AddressesView();

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
    if (confirmed != true || !context.mounted) return;
    final ok = await cubit.remove(address);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not remove address')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AddressCubit>();
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              color: AppColors.white,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.canPop() ? context.pop() : null,
                    behavior: HitTestBehavior.opaque,
                    child: const Icon(Icons.arrow_back,
                        size: 22, color: AppColors.mid),
                  ),
                  const SizedBox(width: 10),
                  Text('Delivery Addresses',
                      style: AppTextStyles.title.copyWith(fontSize: 17)),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<AddressCubit, AddressState>(
                builder: (context, state) {
                  if (state.status == AddressStatus.loading &&
                      state.addresses.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary),
                    );
                  }
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    children: [
                      if (state.addresses.isEmpty)
                        _EmptyState(onAdd: () => AddAddressSheet.show(context, cubit))
                      else ...[
                        Text(
                          '${state.addresses.length} saved address${state.addresses.length == 1 ? '' : 'es'}',
                          style: AppTextStyles.caption.copyWith(fontSize: 12),
                        ),
                        const SizedBox(height: 12),
                        for (final a in state.addresses)
                          _AddressCard(
                            address: a,
                            selected: a.id == state.selectedId,
                            onTap: () => cubit.select(a),
                            onRemove: () => _confirmRemove(context, cubit, a),
                          ),
                        const SizedBox(height: 6),
                        _AddButton(
                            onTap: () => AddAddressSheet.show(context, cubit)),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Column(
        children: [
          const Icon(Icons.location_on_outlined,
              size: 48, color: AppColors.light),
          const SizedBox(height: 12),
          Text('No saved addresses yet',
              style: AppTextStyles.title.copyWith(fontSize: 15)),
          const SizedBox(height: 4),
          Text('Add a delivery address to speed up checkout',
              textAlign: TextAlign.center, style: AppTextStyles.subtitle),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _AddButton(onTap: onAdd),
          ),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text('+ Add a delivery address',
            style: AppTextStyles.body.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.primary)),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final Address address;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  const _AddressCard({
    required this.address,
    required this.selected,
    required this.onTap,
    required this.onRemove,
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
          color: selected ? AppColors.successPale : AppColors.white,
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
                      Flexible(
                        child: Text(address.fullName,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.black)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
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
