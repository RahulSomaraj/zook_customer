import 'package:intl/intl.dart';

import '../../../product/data/models/product_mappers.dart';
import '../../domain/entities/customer_order.dart';

/// Maps the backend order payload (`POST /customers/orders/checkout`,
/// `GET /customers/orders/{id}`) to [CustomerOrder].
///
/// Shape: `{ id, orderNumber, paymentMethod, paymentStatus, subtotal,
/// deliveryFee, totalAmount, estimatedDeliveryAt, createdAt,
/// subOrders: [{ id, subOrderNumber, status, quantity, salePrice,
/// courierName?, awbNumber?, product: {id, brand, model, thumbnailUrl, …},
/// vendor: {storeName}? }] }`.
class OrderModel {
  OrderModel._();

  static CustomerOrder fromJson(Map<String, dynamic> json) {
    final rawSubs = (json['subOrders'] as List?) ?? const [];
    final subs = [
      for (final s in rawSubs)
        if (s is Map) s.cast<String, dynamic>(),
    ];

    final lines = <OrderLine>[];
    for (var i = 0; i < subs.length; i++) {
      lines.add(_line(subs[i], i, subs.length));
    }

    final createdAt = _date(json['createdAt']);
    final firstWithAwb = lines.where((l) => (l.awb ?? '').isNotEmpty);

    return CustomerOrder(
      id: (json['orderNumber'] ?? json['id'] ?? '').toString(),
      orderId: (json['id'] ?? '').toString(),
      dateLabel: createdAt == null ? '' : DateFormat('d MMM y').format(createdAt),
      status: _overallStatus(lines),
      items: lines,
      paymentMethod: (json['paymentMethod'] ?? 'prepaid').toString(),
      paymentStatus: (json['paymentStatus'] ?? 'pending').toString(),
      subtotalAed: ProductMappers.price(json['subtotal']),
      deliveryFeeAed: ProductMappers.price(json['deliveryFee']),
      totalAmountAed: ProductMappers.price(json['totalAmount']),
      estimatedDeliveryAt: _date(json['estimatedDeliveryAt']),
      createdAt: createdAt,
      courierName: firstWithAwb.isNotEmpty
          ? (firstWithAwb.first.courierName ?? 'Courier')
          : 'Courier',
      courierMeta: '',
      awb: firstWithAwb.isNotEmpty ? firstWithAwb.first.awb! : '',
      etaLabel: '',
    );
  }

  static OrderLine _line(Map<String, dynamic> s, int index, int count) {
    final product =
        (s['product'] as Map?)?.cast<String, dynamic>() ?? const {};
    final vendor = (s['vendor'] as Map?)?.cast<String, dynamic>();
    final productId = (product['id'] ?? s['id'] ?? '').toString();
    final name = [product['brand'], product['model']]
        .where((v) => v != null && v.toString().isNotEmpty)
        .join(' ');
    final variant = [product['storageVariant'], product['color']]
        .where((v) => v != null && v.toString().isNotEmpty)
        .join(' · ');

    return OrderLine(
      name: variant.isEmpty ? (name.isEmpty ? 'Item' : name) : '$name · $variant',
      emoji: '📦',
      priceAed: ProductMappers.price(s['salePrice']),
      gradient: ProductMappers.gradientFor(productId),
      packageLabel:
          count > 1 ? 'Package ${index + 1} of $count' : 'Package 1',
      subOrderId: (s['id'] ?? '').toString(),
      subOrderNumber: (s['subOrderNumber'] ?? '').toString(),
      status: status(s['status']?.toString()),
      quantity: (s['quantity'] as num?)?.toInt() ?? 1,
      imageUrl: ProductMappers.imageUrl(product['thumbnailUrl']?.toString()),
      storeName: vendor?['storeName']?.toString(),
      courierName: s['courierName']?.toString(),
      awb: s['awbNumber']?.toString(),
    );
  }

  /// Backend sub-order status → app status. `ready` (photos verified,
  /// awaiting pickup) is still "preparing" from the customer's view.
  static OrderStatus status(String? raw) {
    switch (raw) {
      case 'preparing':
      case 'ready':
        return OrderStatus.preparing;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'confirmed':
      default:
        return OrderStatus.confirmed;
    }
  }

  /// An order is as far along as its slowest non-cancelled parcel; it's
  /// cancelled only when every parcel is.
  static OrderStatus _overallStatus(List<OrderLine> lines) {
    const rank = [
      OrderStatus.confirmed,
      OrderStatus.preparing,
      OrderStatus.shipped,
      OrderStatus.delivered,
    ];
    final live = lines
        .map((l) => l.status ?? OrderStatus.confirmed)
        .where((s) => s != OrderStatus.cancelled)
        .toList();
    if (lines.isNotEmpty && live.isEmpty) return OrderStatus.cancelled;
    if (live.isEmpty) return OrderStatus.confirmed;
    return live.reduce((a, b) => rank.indexOf(a) <= rank.indexOf(b) ? a : b);
  }

  static DateTime? _date(dynamic raw) =>
      raw == null ? null : DateTime.tryParse(raw.toString())?.toLocal();
}
