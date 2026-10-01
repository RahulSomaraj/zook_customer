import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../orders/domain/entities/customer_order.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/repositories/checkout_repository.dart';

enum CheckoutStatus { idle, submitting, phoneRequired, success, failure }

class CheckoutState extends Equatable {
  final CheckoutStatus status;
  final CustomerOrder? order;
  final String? errorMessage;
  final String? errorCode;

  const CheckoutState({
    this.status = CheckoutStatus.idle,
    this.order,
    this.errorMessage,
    this.errorCode,
  });

  bool get isSubmitting => status == CheckoutStatus.submitting;

  @override
  List<Object?> get props => [status, order?.orderId, errorMessage, errorCode];
}

/// Places the order: syncs the local cart to the server cart, then calls
/// `POST /customers/orders/checkout` (which converts the server cart).
class CheckoutCubit extends Cubit<CheckoutState> {
  final CheckoutRepository repository;
  final CartCubit cart;

  CheckoutCubit({required this.repository, required this.cart})
      : super(const CheckoutState());

  Future<void> placeOrder({
    required String addressId,
    required PaymentMethod paymentMethod,
  }) async {
    if (state.isSubmitting) return;
    emit(const CheckoutState(status: CheckoutStatus.submitting));

    final syncFailure = await cart.syncToServer();
    if (syncFailure != null) return _fail(syncFailure);

    final result = await repository.checkout(
      addressId: addressId,
      paymentMethod: paymentMethod,
    );
    result.fold(
      _fail,
      (order) {
        // The server emptied + deactivated the cart during checkout.
        cart.reset();
        emit(CheckoutState(status: CheckoutStatus.success, order: order));
      },
    );
  }

  void _fail(Failure failure) {
    final code = failure is ServerFailure ? failure.code : null;
    if (code == 'PHONE_VERIFICATION_REQUIRED') {
      return emit(const CheckoutState(status: CheckoutStatus.phoneRequired));
    }
    emit(CheckoutState(
      status: CheckoutStatus.failure,
      errorMessage: code == null && failure.message.isEmpty
          ? "We couldn't reach Zook. Check your connection and try again."
          : failure.message,
      errorCode: code,
    ));
    // Stock / availability changed server-side — pull the real cart.
    if (code == 'INSUFFICIENT_STOCK' ||
        code == 'PRODUCT_UNAVAILABLE' ||
        code == 'PRODUCT_NOT_FOUND' ||
        code == 'CART_EMPTY') {
      cart.reload();
    }
  }

  /// Back to idle (e.g. after handling phoneRequired / showing an error).
  void acknowledge() => emit(const CheckoutState());
}
