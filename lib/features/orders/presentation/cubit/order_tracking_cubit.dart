import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/customer_order.dart';
import '../../domain/entities/shipment_tracking.dart';
import '../../domain/repositories/orders_repository.dart';

class OrderTrackingState extends Equatable {
  final CustomerOrder order;

  /// Index into [order.items] — each line is one parcel (sub-order).
  final int selected;

  /// subOrderId → tracking (null value = not with the courier yet).
  final Map<String, ShipmentTracking?> tracking;
  final bool loading;
  final String? error;

  const OrderTrackingState({
    required this.order,
    this.selected = 0,
    this.tracking = const {},
    this.loading = false,
    this.error,
  });

  OrderLine? get line =>
      order.items.isEmpty ? null : order.items[selected.clamp(0, order.items.length - 1)];

  ShipmentTracking? get currentTracking =>
      line == null ? null : tracking[line!.subOrderId];

  OrderStatus get currentStatus => line?.status ?? order.status;

  OrderTrackingState copyWith({
    CustomerOrder? order,
    int? selected,
    Map<String, ShipmentTracking?>? tracking,
    bool? loading,
    String? error,
    bool clearError = false,
  }) =>
      OrderTrackingState(
        order: order ?? this.order,
        selected: selected ?? this.selected,
        tracking: tracking ?? this.tracking,
        loading: loading ?? this.loading,
        error: clearError ? null : (error ?? this.error),
      );

  @override
  List<Object?> get props =>
      [order.orderId, order.status, selected, tracking, loading, error];
}

/// Loads the latest order (`GET /customers/orders/{id}`) and courier
/// tracking for the selected parcel. Mock orders (no [CustomerOrder.orderId])
/// are shown as-is.
class OrderTrackingCubit extends Cubit<OrderTrackingState> {
  final OrdersRepository repository;

  OrderTrackingCubit({required this.repository, required CustomerOrder order})
      : super(OrderTrackingState(order: order));

  bool get _isLive => state.order.orderId.isNotEmpty;

  Future<void> load() async {
    if (!_isLive) return;
    emit(state.copyWith(loading: true, clearError: true));
    final result = await repository.getOrder(state.order.orderId);
    result.fold(
      (f) => emit(state.copyWith(loading: false, error: f.message)),
      (order) => emit(state.copyWith(order: order, loading: false)),
    );
    await _loadTracking();
  }

  Future<void> select(int index) async {
    emit(state.copyWith(selected: index));
    await _loadTracking();
  }

  /// Tracking only exists once a parcel is with the courier.
  Future<void> _loadTracking() async {
    final line = state.line;
    if (!_isLive || line == null || line.subOrderId.isEmpty) return;
    final status = line.status ?? state.order.status;
    if (status != OrderStatus.shipped && status != OrderStatus.delivered) {
      return;
    }
    final result =
        await repository.getTracking(state.order.orderId, line.subOrderId);
    result.fold(
      (_) {}, // Courier API hiccup — keep the status timeline, skip events.
      (t) => emit(state.copyWith(
        tracking: {...state.tracking, line.subOrderId: t},
      )),
    );
  }
}
