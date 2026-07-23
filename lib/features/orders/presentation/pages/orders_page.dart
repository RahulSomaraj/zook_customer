import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/orders_mock.dart';
import '../../domain/entities/customer_order.dart';

enum _OrderFilter { all, active, shipped, delivered }

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  _OrderFilter _filter = _OrderFilter.all;

  List<CustomerOrder> get _orders => kMockOrders;

  int _count(_OrderFilter f) {
    switch (f) {
      case _OrderFilter.all:
        return _orders.length;
      case _OrderFilter.active:
        return _orders.where((o) => o.status.isActive).length;
      case _OrderFilter.shipped:
        return _orders.where((o) => o.status == OrderStatus.shipped).length;
      case _OrderFilter.delivered:
        return _orders.where((o) => o.status == OrderStatus.delivered).length;
    }
  }

  List<CustomerOrder> get _filtered {
    switch (_filter) {
      case _OrderFilter.all:
        return _orders;
      case _OrderFilter.active:
        return _orders.where((o) => o.status.isActive).toList();
      case _OrderFilter.shipped:
        return _orders.where((o) => o.status == OrderStatus.shipped).toList();
      case _OrderFilter.delivered:
        return _orders.where((o) => o.status == OrderStatus.delivered).toList();
    }
  }

  String _label(_OrderFilter f) {
    final n = _count(f);
    switch (f) {
      case _OrderFilter.all:
        return 'All ($n)';
      case _OrderFilter.active:
        return 'Active ($n)';
      case _OrderFilter.shipped:
        return 'Shipped ($n)';
      case _OrderFilter.delivered:
        return 'Delivered ($n)';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Text('My Orders',
                  style: AppTextStyles.title
                      .copyWith(fontSize: 20, color: AppColors.black)),
            ),
            // Filter tabs
            Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    for (final f in _OrderFilter.values) ...[
                      _FilterPill(
                        label: _label(f),
                        active: f == _filter,
                        onTap: () => setState(() => _filter = f),
                      ),
                      if (f != _OrderFilter.values.last)
                        const SizedBox(width: 6),
                    ],
                  ],
                ),
              ),
            ),
            Expanded(
              child: _filtered.isEmpty
                  ? Center(
                      child: Text('No orders here yet.',
                          style: AppTextStyles.body
                              .copyWith(color: AppColors.mid)),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 12),
                      itemCount: _filtered.length,
                      itemBuilder: (context, i) =>
                          _OrderCard(order: _filtered[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _FilterPill(
      {required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.white,
          border: Border.all(
              color: active ? AppColors.primary : AppColors.border,
              width: 1.5),
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Text(
          label,
          style: AppTextStyles.label.copyWith(
            fontSize: 12,
            letterSpacing: 0,
            color: active ? AppColors.white : AppColors.mid,
          ),
        ),
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  final OrderStatus status;
  const StatusPill({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: status.pillBg,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration:
                BoxDecoration(color: status.dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: AppTextStyles.caption.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: status.pillFg,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final CustomerOrder order;
  const _OrderCard({required this.order});

  void _track(BuildContext context) =>
      context.push(AppRoute.orderTrack.path, extra: order);

  void _snack(BuildContext context, String msg) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Text('#${order.id}',
                    style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.mid)),
                const SizedBox(width: 10),
                Text(order.dateLabel,
                    style: AppTextStyles.caption.copyWith(fontSize: 11)),
                const Spacer(),
                StatusPill(status: order.status),
              ],
            ),
          ),
          // Items
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              children: [
                for (var i = 0; i < order.items.length; i++) ...[
                  _ItemRow(line: order.items[i]),
                  if (i != order.items.length - 1) const SizedBox(height: 8),
                ],
              ],
            ),
          ),
          // Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Text.rich(
                  TextSpan(
                    text: 'Total: ',
                    style: AppTextStyles.caption
                        .copyWith(fontSize: 12, color: AppColors.mid),
                    children: [
                      TextSpan(
                        text: 'AED ${formatAmount(order.totalAed)}',
                        style: AppTextStyles.label.copyWith(
                            fontSize: 12,
                            letterSpacing: 0,
                            color: AppColors.black,
                            fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                _action(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _action(BuildContext context) {
    if (order.status == OrderStatus.delivered) {
      return _ActionButton(
        label: 'Reorder',
        bg: AppColors.surface,
        fg: AppColors.mid,
        border: true,
        onTap: () => _snack(context, 'Reorder coming soon'),
      );
    }
    if (order.status == OrderStatus.cancelled) {
      return const SizedBox.shrink();
    }
    final shipped = order.status == OrderStatus.shipped;
    return _ActionButton(
      label: shipped ? 'Track' : 'View details',
      icon: shipped ? Icons.location_on_outlined : null,
      bg: AppColors.black,
      fg: AppColors.white,
      onTap: () => _track(context),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final OrderLine line;
  const _ItemRow({required this.line});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: line.gradient,
            ),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(line.emoji, style: const TextStyle(fontSize: 20)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(line.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black)),
              const SizedBox(height: 1),
              Text(line.packageLabel,
                  style: AppTextStyles.caption.copyWith(fontSize: 10)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text('AED ${formatAmount(line.priceAed)}',
            style: AppTextStyles.label.copyWith(
                fontSize: 13,
                letterSpacing: 0,
                color: AppColors.black,
                fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color bg;
  final Color fg;
  final bool border;
  final VoidCallback onTap;
  const _ActionButton({
    required this.label,
    required this.bg,
    required this.fg,
    required this.onTap,
    this.icon,
    this.border = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(9999),
          border: border ? Border.all(color: AppColors.border) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13, color: fg),
              const SizedBox(width: 4),
            ],
            Text(label,
                style: AppTextStyles.label.copyWith(
                    fontSize: 11, letterSpacing: 0, color: fg)),
          ],
        ),
      ),
    );
  }
}
