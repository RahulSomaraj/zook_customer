import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/customer_order.dart';
import '../../domain/entities/shipment_tracking.dart';
import '../../domain/repositories/orders_repository.dart';
import '../cubit/order_tracking_cubit.dart';

class _Step {
  final String title;
  final String time;
  const _Step(this.title, this.time);
}

/// Order tracking. For API orders it refreshes the order and shows per-parcel
/// status plus live courier events; mock orders render as passed in.
class OrderTrackingPage extends StatelessWidget {
  final CustomerOrder order;
  const OrderTrackingPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrderTrackingCubit(
        repository: sl<OrdersRepository>(),
        order: order,
      )..load(),
      child: const _TrackingView(),
    );
  }
}

class _TrackingView extends StatelessWidget {
  const _TrackingView();

  /// Index of the currently-active step (5 = all done / delivered).
  static int _currentIndex(OrderStatus status) {
    switch (status) {
      case OrderStatus.confirmed:
        return 0;
      case OrderStatus.preparing:
        return 1;
      case OrderStatus.shipped:
        return 3;
      case OrderStatus.delivered:
        return 5;
      case OrderStatus.cancelled:
        return 0;
    }
  }

  static String _headline(OrderStatus status) {
    switch (status) {
      case OrderStatus.confirmed:
        return 'Order confirmed';
      case OrderStatus.preparing:
        return 'Being packed';
      case OrderStatus.shipped:
        return 'On the way to you';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderTrackingCubit, OrderTrackingState>(
      builder: (context, state) {
        final cubit = context.read<OrderTrackingCubit>();
        final order = state.order;
        final line = state.line;
        final status = state.currentStatus;
        final tracking = state.currentTracking;
        final isLive = order.orderId.isNotEmpty;
        final current = _currentIndex(status);

        final eta = order.estimatedDeliveryAt;
        final etaLabel = eta != null
            ? DateFormat('d MMM').format(eta)
            : (order.etaLabel.isEmpty ? '—' : order.etaLabel);
        final courier = tracking?.courierName ?? line?.courierName;
        final awb = tracking?.awbNumber ??
            ((line?.awb ?? '').isNotEmpty ? line!.awb! : order.awb);
        final hasCourier = awb.isNotEmpty;

        final steps = [
          _Step('Order confirmed',
              '${order.dateLabel} · ${order.isCod ? 'Cash on delivery' : 'Payment received'}'),
          const _Step('Packed & ready for pickup', 'Packing photos verified'),
          const _Step('Picked up by courier', 'Collected by courier'),
          _Step('Out for delivery',
              eta != null ? 'Est. delivery ${DateFormat('EEE d MMM').format(eta)}' : 'On its way'),
          const _Step('Delivered', '—'),
        ];

        return Scaffold(
          backgroundColor: AppColors.surface,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    border:
                        Border(bottom: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        behavior: HitTestBehavior.opaque,
                        child: const Icon(Icons.arrow_back,
                            size: 20, color: AppColors.mid),
                      ),
                      const SizedBox(width: 10),
                      Text('Track Order',
                          style: AppTextStyles.title.copyWith(
                              fontSize: 16, color: AppColors.black)),
                      const Spacer(),
                      Flexible(
                        child: Text('#${order.id}',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.light)),
                      ),
                    ],
                  ),
                ),
                if (state.loading)
                  const LinearProgressIndicator(
                      minHeight: 2, color: AppColors.primary),
                const _TrackMap(),
                // Status bar
                Container(
                  width: double.infinity,
                  color: status == OrderStatus.cancelled
                      ? AppColors.mid
                      : AppColors.primary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      const Icon(Icons.local_shipping_outlined,
                          size: 24, color: AppColors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _headline(status),
                              style: AppTextStyles.body.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.white),
                            ),
                            const SizedBox(height: 1),
                            Text(
                                hasCourier
                                    ? '${courier ?? 'Courier'} · AWB: $awb'
                                    : 'Awaiting courier pickup',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.white
                                        .withValues(alpha: 0.65))),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(etaLabel,
                              style: AppTextStyles.body.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.white)),
                          Text('Estimated arrival',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.white
                                      .withValues(alpha: 0.55))),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: cubit.load,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (state.error != null)
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 12, 16, 0),
                              child: Text(state.error!,
                                  style: AppTextStyles.caption.copyWith(
                                      fontSize: 12,
                                      color: AppColors.primary)),
                            ),
                          if (order.items.length > 1)
                            _PackageSelector(
                              items: order.items,
                              selected: state.selected,
                              onSelect: cubit.select,
                            ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                for (var i = 0; i < steps.length; i++)
                                  _TimelineStep(
                                    step: steps[i],
                                    index: i,
                                    isLast: i == steps.length - 1,
                                    state: i < current
                                        ? _StepState.done
                                        : i == current
                                            ? _StepState.active
                                            : _StepState.pending,
                                  ),
                              ],
                            ),
                          ),
                          if (tracking != null && tracking.events.isNotEmpty)
                            _Panel(
                              title: 'Courier updates',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (final e in tracking.events)
                                    _EventRow(event: e),
                                ],
                              ),
                            ),
                          if (hasCourier)
                            _Panel(
                              title: 'Your courier',
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(12),
                                      border:
                                          Border.all(color: AppColors.border),
                                    ),
                                    child: const Icon(
                                        Icons.local_shipping_outlined,
                                        size: 20,
                                        color: AppColors.charcoal),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(courier ?? 'Courier',
                                            style: AppTextStyles.body.copyWith(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.black)),
                                        if (!isLive &&
                                            order.courierMeta.isNotEmpty)
                                          Text(order.courierMeta,
                                              style: AppTextStyles.caption
                                                  .copyWith(fontSize: 11)),
                                        const SizedBox(height: 2),
                                        Text('AWB: $awb',
                                            style: const TextStyle(
                                                fontFamily: 'monospace',
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.primary)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          _Panel(
                            title: 'Items in this order',
                            bottomMargin: 16,
                            child: Column(
                              children: [
                                for (var i = 0; i < order.items.length; i++) ...[
                                  _ItemMini(line: order.items[i]),
                                  if (i != order.items.length - 1)
                                    const SizedBox(height: 10),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Chips to switch between parcels when an order has several vendors.
class _PackageSelector extends StatelessWidget {
  final List<OrderLine> items;
  final int selected;
  final ValueChanged<int> onSelect;
  const _PackageSelector({
    required this.items,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final active = i == selected;
          final status = items[i].status;
          return GestureDetector(
            onTap: () => onSelect(i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? AppColors.black : AppColors.white,
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(
                    color: active ? AppColors.black : AppColors.border),
              ),
              child: Text(
                'Package ${i + 1}${status != null ? ' · ${status.label}' : ''}',
                style: AppTextStyles.caption.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: active ? AppColors.white : AppColors.charcoal),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  final TrackingEvent event;
  const _EventRow({required this.event});

  @override
  Widget build(BuildContext context) {
    final at = event.occurredAt;
    final meta = [
      if (at != null) DateFormat('d MMM · h:mm a').format(at),
      if ((event.hubName ?? '').isNotEmpty) event.hubName!,
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(event.label,
              style: AppTextStyles.body.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black)),
          if ((event.description ?? '').isNotEmpty)
            Text(event.description!,
                style: AppTextStyles.caption.copyWith(fontSize: 11)),
          if (meta.isNotEmpty)
            Text(meta,
                style: AppTextStyles.caption
                    .copyWith(fontSize: 10, color: AppColors.light)),
        ],
      ),
    );
  }
}

enum _StepState { done, active, pending }

class _TimelineStep extends StatelessWidget {
  final _Step step;
  final int index;
  final bool isLast;
  final _StepState state;
  const _TimelineStep({
    required this.step,
    required this.index,
    required this.isLast,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final connectorColor =
        state == _StepState.done ? AppColors.success : AppColors.border;

    Widget dot;
    switch (state) {
      case _StepState.done:
        dot = Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
              color: AppColors.success, shape: BoxShape.circle),
          child: const Icon(Icons.check, size: 15, color: AppColors.white),
        );
        break;
      case _StepState.active:
        dot = Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                  color: AppColors.primaryPale, spreadRadius: 5, blurRadius: 0),
            ],
          ),
          child: Text('${index + 1}',
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white)),
        );
        break;
      case _StepState.pending:
        dot = Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border, width: 2),
          ),
          child: Text('${index + 1}',
              style: AppTextStyles.caption.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.light)),
        );
        break;
    }

    final titleColor = state == _StepState.active
        ? AppColors.primary
        : state == _StepState.pending
            ? AppColors.light
            : AppColors.charcoal;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              dot,
              if (!isLast)
                Expanded(child: Container(width: 2, color: connectorColor)),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step.title,
                      style: AppTextStyles.body.copyWith(
                          fontSize: 14,
                          fontWeight: state == _StepState.active
                              ? FontWeight.w800
                              : FontWeight.w700,
                          color: titleColor)),
                  const SizedBox(height: 2),
                  Text(step.time,
                      style: AppTextStyles.caption.copyWith(
                          fontSize: 11,
                          color: state == _StepState.active
                              ? AppColors.primary.withValues(alpha: 0.6)
                              : AppColors.light)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final String title;
  final Widget child;
  final double bottomMargin;
  const _Panel(
      {required this.title, required this.child, this.bottomMargin = 14});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, bottomMargin),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Text(title,
                style: AppTextStyles.body.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _ItemMini extends StatelessWidget {
  final OrderLine line;
  const _ItemMini({required this.line});

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
              Text(
                  [
                    line.packageLabel,
                    if (line.status != null) line.status!.label,
                    if ((line.storeName ?? '').isNotEmpty) line.storeName!,
                  ].join(' · '),
                  style: AppTextStyles.caption.copyWith(fontSize: 10)),
            ],
          ),
        ),
      ],
    );
  }
}

/// Stylised delivery map (approximation of the mockup — no live map SDK).
class _TrackMap extends StatelessWidget {
  const _TrackMap();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFE8F4F8), Color(0xFFD4EAF0)],
                ),
              ),
            ),
          ),
          Positioned.fill(child: CustomPaint(painter: _MapPainter())),
          Align(
            alignment: const Alignment(0.55, -0.45),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.black,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: const Text('Your address',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white)),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.black,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: const Alignment(-0.25, 0.1),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(9999),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.local_shipping,
                          size: 13, color: AppColors.white),
                      SizedBox(width: 5),
                      Text('On the way',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.white)),
                    ],
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -5),
                  child: Transform.rotate(
                    angle: 0.785398,
                    child: Container(
                        width: 10, height: 10, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = const Color(0x3396B4C8)
      ..strokeWidth = 1;
    const step = 24.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final road = Paint()
      ..color = const Color(0x99FFFFFF)
      ..strokeWidth = 5;
    canvas.drawLine(Offset(0, size.height * 0.4),
        Offset(size.width, size.height * 0.4), road);
    canvas.drawLine(Offset(size.width * 0.3, 0),
        Offset(size.width * 0.3, size.height), road);
    final route = Paint()
      ..color = const Color(0xFFFF4500)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(size.width * 0.38, size.height * 0.55)
      ..quadraticBezierTo(size.width * 0.55, size.height * 0.33,
          size.width * 0.75, size.height * 0.3);
    _drawDashed(canvas, path, route);
  }

  void _drawDashed(Canvas canvas, Path path, Paint paint) {
    const dash = 8.0, gap = 4.0;
    for (final metric in path.computeMetrics()) {
      double dist = 0;
      while (dist < metric.length) {
        final next = dist + dash;
        canvas.drawPath(
          metric.extractPath(dist, next.clamp(0, metric.length).toDouble()),
          paint,
        );
        dist = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
