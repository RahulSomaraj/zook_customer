import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/customer_order.dart';
import '../../domain/entities/orders_page_result.dart';
import '../../domain/repositories/orders_repository.dart';

class OrdersState extends Equatable {
  final OrderFilter filter;
  final List<CustomerOrder> items;
  final Map<OrderFilter, int> counts;
  final int page;
  final bool hasMore;
  final bool loading;
  final bool loadingMore;
  final bool loaded;
  final String? error;

  const OrdersState({
    this.filter = OrderFilter.all,
    this.items = const [],
    this.counts = const {},
    this.page = 0,
    this.hasMore = false,
    this.loading = false,
    this.loadingMore = false,
    this.loaded = false,
    this.error,
  });

  int count(OrderFilter f) => counts[f] ?? 0;

  OrdersState copyWith({
    OrderFilter? filter,
    List<CustomerOrder>? items,
    Map<OrderFilter, int>? counts,
    int? page,
    bool? hasMore,
    bool? loading,
    bool? loadingMore,
    bool? loaded,
    String? error,
    bool clearError = false,
  }) =>
      OrdersState(
        filter: filter ?? this.filter,
        items: items ?? this.items,
        counts: counts ?? this.counts,
        page: page ?? this.page,
        hasMore: hasMore ?? this.hasMore,
        loading: loading ?? this.loading,
        loadingMore: loadingMore ?? this.loadingMore,
        loaded: loaded ?? this.loaded,
        error: clearError ? null : (error ?? this.error),
      );

  @override
  List<Object?> get props => [
        filter,
        items.map((o) => '${o.orderId}:${o.status}').join(','),
        counts,
        page,
        hasMore,
        loading,
        loadingMore,
        loaded,
        error,
      ];
}

/// The customer's order history (Orders tab + profile stats). App-wide
/// singleton: loaded on sign-in, refreshed after checkout, reset on logout.
class OrdersCubit extends Cubit<OrdersState> {
  final OrdersRepository repository;
  OrdersCubit({required this.repository}) : super(const OrdersState());

  int _requestId = 0;

  /// First page for [filter] (defaults to the current one).
  Future<void> load({OrderFilter? filter}) async {
    final f = filter ?? state.filter;
    final id = ++_requestId;
    emit(state.copyWith(
      filter: f,
      loading: true,
      clearError: true,
      // Switching tabs: don't show the previous tab's list under the spinner.
      items: f == state.filter ? null : const [],
    ));
    final result = await repository.getOrders(filter: f);
    if (id != _requestId) return; // a newer tab/refresh won
    result.fold(
      (failure) => emit(state.copyWith(
          loading: false, loaded: true, error: failure.message)),
      (page) => emit(state.copyWith(
        items: page.items,
        counts: page.counts,
        page: page.page,
        hasMore: page.hasMore,
        loading: false,
        loaded: true,
      )),
    );
  }

  Future<void> refresh() => load();

  Future<void> loadMore() async {
    if (!state.hasMore || state.loading || state.loadingMore) return;
    final id = _requestId;
    emit(state.copyWith(loadingMore: true));
    final result =
        await repository.getOrders(filter: state.filter, page: state.page + 1);
    if (id != _requestId) return;
    result.fold(
      (failure) =>
          emit(state.copyWith(loadingMore: false, error: failure.message)),
      (page) => emit(state.copyWith(
        items: [...state.items, ...page.items],
        counts: page.counts,
        page: page.page,
        hasMore: page.hasMore,
        loadingMore: false,
      )),
    );
  }

  void reset() {
    _requestId++;
    emit(const OrdersState());
  }
}
