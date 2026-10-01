import 'customer_order.dart';

/// Order list filters, matching the API `status` query values.
enum OrderFilter { all, active, shipped, delivered, cancelled }

/// One page of `GET /customers/orders`.
class OrdersPageResult {
  final List<CustomerOrder> items;
  final int page;
  final int totalPages;

  /// Per-filter totals (`all`, `active`, …) for tab badges / profile stats.
  final Map<OrderFilter, int> counts;

  const OrdersPageResult({
    required this.items,
    required this.page,
    required this.totalPages,
    required this.counts,
  });

  bool get hasMore => page < totalPages;
}
