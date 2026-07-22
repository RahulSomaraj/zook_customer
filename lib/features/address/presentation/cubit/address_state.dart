part of 'address_cubit.dart';

enum AddressStatus { idle, loading, submitting, failure }

class AddressState extends Equatable {
  final AddressStatus status;
  final List<Address> addresses;
  final String? selectedId;
  final String? errorMessage;

  const AddressState({
    this.status = AddressStatus.idle,
    this.addresses = const [],
    this.selectedId,
    this.errorMessage,
  });

  /// The address currently chosen for delivery (or null when none exist).
  Address? get selected {
    for (final a in addresses) {
      if (a.id == selectedId) return a;
    }
    return addresses.isEmpty ? null : addresses.first;
  }

  AddressState copyWith({
    AddressStatus? status,
    List<Address>? addresses,
    String? selectedId,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AddressState(
      status: status ?? this.status,
      addresses: addresses ?? this.addresses,
      selectedId: selectedId ?? this.selectedId,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, addresses, selectedId, errorMessage];
}
