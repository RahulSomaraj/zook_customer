import 'package:flutter/material.dart';

/// Fulfilment status of a customer order.
enum OrderStatus { confirmed, preparing, shipped, delivered, cancelled }

extension OrderStatusX on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// "Active" = still being prepared (not yet shipped, delivered or cancelled).
  bool get isActive =>
      this == OrderStatus.confirmed || this == OrderStatus.preparing;

  bool get isTrackable =>
      this == OrderStatus.confirmed ||
      this == OrderStatus.preparing ||
      this == OrderStatus.shipped;

  Color get dotColor {
    switch (this) {
      case OrderStatus.confirmed:
        return const Color(0xFF3B82F6);
      case OrderStatus.preparing:
        return const Color(0xFFF59E0B);
      case OrderStatus.shipped:
        return const Color(0xFF7C3AED);
      case OrderStatus.delivered:
        return const Color(0xFF22C55E);
      case OrderStatus.cancelled:
        return const Color(0xFFEF4444);
    }
  }

  Color get pillBg {
    switch (this) {
      case OrderStatus.confirmed:
        return const Color(0xFFEFF6FF);
      case OrderStatus.preparing:
        return const Color(0xFFFFFBEB);
      case OrderStatus.shipped:
        return const Color(0xFFF5F3FF);
      case OrderStatus.delivered:
        return const Color(0xFFF0FDF4);
      case OrderStatus.cancelled:
        return const Color(0xFFFEF2F2);
    }
  }

  Color get pillFg {
    switch (this) {
      case OrderStatus.confirmed:
        return const Color(0xFF1D4ED8);
      case OrderStatus.preparing:
        return const Color(0xFFB45309);
      case OrderStatus.shipped:
        return const Color(0xFF6D28D9);
      case OrderStatus.delivered:
        return const Color(0xFF15803D);
      case OrderStatus.cancelled:
        return const Color(0xFFB91C1C);
    }
  }
}

/// A single line item within an order.
class OrderLine {
  final String name;
  final String emoji;
  final int priceAed;
  final List<Color> gradient;
  final String packageLabel;
  const OrderLine({
    required this.name,
    required this.emoji,
    required this.priceAed,
    required this.gradient,
    required this.packageLabel,
  });
}

/// A customer order shown on the Orders tab and the tracking screen.
class CustomerOrder {
  final String id; // e.g. ORD-041
  final String dateLabel; // e.g. 7 Jun 2026
  final OrderStatus status;
  final List<OrderLine> items;
  final String courierName;
  final String courierMeta;
  final String awb;
  final String etaLabel;

  const CustomerOrder({
    required this.id,
    required this.dateLabel,
    required this.status,
    required this.items,
    this.courierName = 'Porter.ae',
    this.courierMeta = 'Express delivery · Dubai',
    this.awb = '',
    this.etaLabel = '~45 min',
  });

  int get totalAed =>
      items.fold(0, (sum, line) => sum + line.priceAed);
}
