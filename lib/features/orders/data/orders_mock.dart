import 'package:flutter/material.dart';

import '../domain/entities/customer_order.dart';

// Image-area gradients mirroring the mockup swatches.
const _gOrange = [Color(0xFFFFF0EB), Color(0xFFFFD4C2)];
const _gPurple = [Color(0xFFF5F3FF), Color(0xFFDDD6FE)];
const _gGreen = [Color(0xFFF0FDF4), Color(0xFFBBF7D0)];
const _gYellow = [Color(0xFFFFFBEB), Color(0xFFFDE68A)];
const _gBlue = [Color(0xFFEFF6FF), Color(0xFFBFDBFE)];

/// Sample orders used to render the Orders/Tracking UI until a real orders
/// API is wired up.
const List<CustomerOrder> kMockOrders = [
  CustomerOrder(
    id: 'ORD-041',
    dateLabel: '7 Jun 2026',
    status: OrderStatus.shipped,
    awb: 'PRT-00193842',
    etaLabel: '~45 min',
    items: [
      OrderLine(
          name: 'iPhone 14 Pro 256GB',
          emoji: '📱',
          priceAed: 2100,
          gradient: _gOrange,
          packageLabel: 'Package 1 of 2'),
      OrderLine(
          name: 'PlayStation 5 Console',
          emoji: '🎮',
          priceAed: 1800,
          gradient: _gPurple,
          packageLabel: 'Package 2 of 2'),
    ],
  ),
  CustomerOrder(
    id: 'ORD-040',
    dateLabel: '5 Jun 2026',
    status: OrderStatus.preparing,
    items: [
      OrderLine(
          name: 'Apple Watch Series 9',
          emoji: '⌚',
          priceAed: 750,
          gradient: _gGreen,
          packageLabel: 'Package 1'),
    ],
  ),
  CustomerOrder(
    id: 'ORD-039',
    dateLabel: '4 Jun 2026',
    status: OrderStatus.confirmed,
    items: [
      OrderLine(
          name: 'iPad Air 11" 128GB',
          emoji: '📱',
          priceAed: 1500,
          gradient: _gBlue,
          packageLabel: 'Package 1'),
    ],
  ),
  CustomerOrder(
    id: 'ORD-038',
    dateLabel: '1 Jun 2026',
    status: OrderStatus.delivered,
    items: [
      OrderLine(
          name: 'Sony WH-1000XM5',
          emoji: '🎧',
          priceAed: 680,
          gradient: _gYellow,
          packageLabel: 'Package 1'),
    ],
  ),
  CustomerOrder(
    id: 'ORD-035',
    dateLabel: '22 May 2026',
    status: OrderStatus.delivered,
    items: [
      OrderLine(
          name: 'MacBook Air M2 256GB',
          emoji: '💻',
          priceAed: 3200,
          gradient: _gGreen,
          packageLabel: 'Package 1'),
    ],
  ),
  CustomerOrder(
    id: 'ORD-030',
    dateLabel: '14 May 2026',
    status: OrderStatus.delivered,
    items: [
      OrderLine(
          name: 'Galaxy S24 Ultra',
          emoji: '📱',
          priceAed: 2800,
          gradient: _gPurple,
          packageLabel: 'Package 1'),
    ],
  ),
];
