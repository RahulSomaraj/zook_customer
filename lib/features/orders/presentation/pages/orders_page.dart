import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/customer_order.dart';
import '../../domain/entities/orders_page_result.dart';
import '../cubit/orders_cubit.dart';

/// Tabs shown on the Orders screen (cancelled orders appear under All).
const _tabs = [
  OrderFilter.all,
  OrderFilter.active,
  OrderFilter.shipped,
  OrderFilter.delivered,
];

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    // Always refresh when the tab opens — statuses change server-side.
    context.read<OrdersCubit>().refresh();
    _scroll.addListener(() {
      if (_scroll.position.pixels >
          _scroll.position.maxScrollExtent - 300) {
        context.read<OrdersCubit>().loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  String _label(OrderFilter f, OrdersState state) {
    final n = state.count(f);
    switch (f) {
      case OrderFilter.all:
        return 'All ($n)';
      case OrderFilter.active:
        return 'Active ($n)';
      case OrderFilter.shipped:
        return 'Shipped ($n)';
      case OrderFilter.delivered:
        return 'Delivered ($n)';
      case OrderFilter.cancelled:
        return 'Cancelled ($n)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<OrdersCubit>().state;
    final cubit = context.read<OrdersCubit>();
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
                    for (final f in _tabs) ...[
                      _FilterPill(
                        label: _label(f, state),
                        active: f == state.filter,
                        onTap: () => cubit.load(filter: f),
                      ),
                      if (f != _tabs.last) const SizedBox(width: 6),
                    ],
                  ],
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: cubit.refresh,
                child: _body(state),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(OrdersState state) {
    // Scrollable in every state so pull-to-refresh always works.
    Widget message(String text, {bool retry = false}) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 120),
            Center(
              child: Text(text,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(color: AppColors.mid)),
            ),
            if (retry)
              Center(
                child: TextButton(
                  onPressed: context.read<OrdersCubit>().refresh,
                  child: const Text('Retry'),
                ),
              ),
          ],
        );

    if (state.items.isEmpty) {
      if (state.loading || !state.loaded) {
        return const Center(
            child: CircularProgressIndicator(color: AppColors.primary));
      }
      if (state.error != null) return message(state.error!, retry: true);
      return message(state.filter == OrderFilter.all
          ? 'No orders yet.\nItems you buy will show up here.'
          : 'No orders here yet.');
    }

    return ListView.builder(
      controller: _scroll,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 12),
      itemCount: state.items.length + (state.loadingMore ? 1 : 0),
      itemBuilder: (context, i) => i < state.items.length
          ? _OrderCard(order: state.items[i])
          : const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.primary)),
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
    // Whole card opens detail/tracking (also for delivered/cancelled orders).
    return GestureDetector(
      onTap: () => _track(context),
      behavior: HitTestBehavior.opaque,
      child: Container(
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
                Expanded(
                  child: Text('#${order.id}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.mid)),
                ),
                const SizedBox(width: 10),
                Text(order.dateLabel,
                    style: AppTextStyles.caption.copyWith(fontSize: 11)),
                const SizedBox(width: 8),
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
          clipBehavior: Clip.antiAlias,
          child: line.imageUrl.isEmpty
              ? Text(line.emoji, style: const TextStyle(fontSize: 20))
              : Image.network(line.imageUrl,
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Text(line.emoji, style: const TextStyle(fontSize: 20))),
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
