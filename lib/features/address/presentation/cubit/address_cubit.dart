import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/address.dart';
import '../../domain/repositories/address_repository.dart';

part 'address_state.dart';

/// Holds the customer's delivery addresses and the one selected for checkout.
///
/// Starts empty; [load] fetches saved addresses from the API and [add] creates
/// a new one. Checkout shows an "add address" prompt until one exists.
class AddressCubit extends Cubit<AddressState> {
  final AddressRepository repository;
  AddressCubit({required this.repository}) : super(const AddressState());

  /// Loads saved addresses from the API. Leaves the list empty on failure or
  /// when the customer has none yet.
  Future<void> load() async {
    emit(state.copyWith(status: AddressStatus.loading));
    final result = await repository.getAddresses();
    result.fold(
      (failure) {
        debugPrint('AddressCubit.load failed: ${failure.message}');
        emit(state.copyWith(
          status: AddressStatus.idle,
          errorMessage: failure.message,
        ));
      },
      (list) {
        debugPrint('AddressCubit.load fetched ${list.length} address(es)');
        if (list.isEmpty) {
          emit(state.copyWith(status: AddressStatus.idle, clearError: true));
          return;
        }
        // Pick the default address, else the first one.
        Address selected = list.first;
        for (final a in list) {
          if (a.isDefault) {
            selected = a;
            break;
          }
        }
        emit(state.copyWith(
          status: AddressStatus.idle,
          addresses: list,
          selectedId: selected.id,
          clearError: true,
        ));
      },
    );
  }

  void select(Address address) => emit(state.copyWith(selectedId: address.id));

  /// Removes [address] via the API and drops it from the list. Returns true on
  /// success. Re-selects the default (or first) remaining address.
  Future<bool> remove(Address address) async {
    final id = address.id;
    if (id == null) return false;

    final result = await repository.delete(id);
    return result.fold(
      (failure) {
        emit(state.copyWith(errorMessage: failure.message));
        return false;
      },
      (_) {
        final remaining =
            state.addresses.where((a) => a.id != id).toList();
        String? selectedId = state.selectedId;
        if (selectedId == id) {
          Address? next;
          for (final a in remaining) {
            if (a.isDefault) {
              next = a;
              break;
            }
          }
          next ??= remaining.isNotEmpty ? remaining.first : null;
          selectedId = next?.id;
        }
        emit(AddressState(
          status: AddressStatus.idle,
          addresses: remaining,
          selectedId: selectedId,
        ));
        return true;
      },
    );
  }

  /// Creates [address] via the API. Returns true on success.
  ///
  /// After a successful create we re-fetch the full list from the server so the
  /// new address (with its real id) is always listed, regardless of the POST
  /// response shape. Falls back to appending the created address if the refresh
  /// fails.
  Future<bool> add(Address address) async {
    emit(state.copyWith(status: AddressStatus.submitting, clearError: true));
    final result = await repository.create(address);

    return result.fold(
      (failure) async {
        emit(state.copyWith(
          status: AddressStatus.failure,
          errorMessage: failure.message,
        ));
        return false;
      },
      (created) async {
        final listResult = await repository.getAddresses();
        final list = listResult.fold(
          // Refresh failed — keep what we have plus the created address.
          (_) => [
            if (created.isDefault)
              for (final a in state.addresses) a.copyWith(isDefault: false)
            else
              ...state.addresses,
            created,
          ],
          (fetched) => fetched.isEmpty ? [created] : fetched,
        );

        // Prefer selecting the just-created address; else the default; else last.
        String? selectedId;
        if (created.id != null && list.any((a) => a.id == created.id)) {
          selectedId = created.id;
        } else {
          final defaults = list.where((a) => a.isDefault);
          selectedId = defaults.isNotEmpty
              ? defaults.first.id
              : (list.isNotEmpty ? list.last.id : null);
        }

        emit(state.copyWith(
          status: AddressStatus.idle,
          addresses: list,
          selectedId: selectedId,
        ));
        return true;
      },
    );
  }
}
