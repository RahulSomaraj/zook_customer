/// Live courier tracking for one sub-order (one parcel), from
/// `GET /customers/orders/{orderId}/sub-orders/{subOrderId}/tracking`.
class ShipmentTracking {
  final String subOrderId;
  final String? courierName;
  final String awbNumber;

  /// Courier's latest status, snake_case (e.g. `out_for_delivery`).
  final String lastStatus;

  /// Most recent first.
  final List<TrackingEvent> events;

  const ShipmentTracking({
    required this.subOrderId,
    required this.courierName,
    required this.awbNumber,
    required this.lastStatus,
    required this.events,
  });

  factory ShipmentTracking.fromJson(Map<String, dynamic> json) {
    final raw = (json['events'] as List?) ?? const [];
    return ShipmentTracking(
      subOrderId: (json['subOrderId'] ?? '').toString(),
      courierName: json['courierName']?.toString(),
      awbNumber: (json['awbNumber'] ?? '').toString(),
      lastStatus: (json['lastStatus'] ?? '').toString(),
      events: [
        for (final e in raw)
          if (e is Map) TrackingEvent.fromJson(e.cast<String, dynamic>()),
      ],
    );
  }
}

class TrackingEvent {
  final String status;
  final String label;
  final String? description;
  final String? hubName;
  final DateTime? occurredAt;

  const TrackingEvent({
    required this.status,
    required this.label,
    this.description,
    this.hubName,
    this.occurredAt,
  });

  factory TrackingEvent.fromJson(Map<String, dynamic> json) => TrackingEvent(
        status: (json['status'] ?? '').toString(),
        label: (json['label'] ?? json['status'] ?? '').toString(),
        description: json['description']?.toString(),
        hubName: json['hubName']?.toString(),
        occurredAt: json['occurredAt'] == null
            ? null
            : DateTime.tryParse(json['occurredAt'].toString())?.toLocal(),
      );
}
