/// Payment methods accepted by `POST /customers/orders/checkout`.
enum PaymentMethod {
  /// Cash on delivery — courier collects on handover.
  cod,

  /// Card / Apple Pay / Tabby via Mamo Pay. Not wired yet (Phase 2): the
  /// backend creates the order as `pending` but nothing collects payment.
  prepaid,
}

extension PaymentMethodX on PaymentMethod {
  String get apiValue => name;
}
