part of 'wishlist_cubit.dart';

class WishlistState extends Equatable {
  /// Product ids currently in the wishlist.
  final Set<String> ids;

  /// Ids with an in-flight add/remove request (used to disable re-taps).
  final Set<String> pending;

  /// Last failure message, if a toggle failed. Null when healthy.
  final String? errorMessage;

  const WishlistState({
    this.ids = const {},
    this.pending = const {},
    this.errorMessage,
  });

  WishlistState copyWith({
    Set<String>? ids,
    Set<String>? pending,
    String? errorMessage,
    bool clearError = false,
  }) {
    return WishlistState(
      ids: ids ?? this.ids,
      pending: pending ?? this.pending,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [ids, pending, errorMessage];
}
