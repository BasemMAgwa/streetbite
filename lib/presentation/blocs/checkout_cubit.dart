import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_strings.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/order_failure.dart';
import '../../domain/entities/payment_status.dart';
import '../../domain/entities/payment_type.dart';
import '../../domain/repositories/payment_method.dart';
import '../../domain/usecases/place_order.dart';
import 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit(this._placeOrder, this._userId, this._payments)
    : super(CheckoutState(payment: _payments.first.type));

  final PlaceOrder _placeOrder;
  final String _userId;
  final List<PaymentMethod> _payments;

  List<PaymentType> get paymentTypes =>
      _payments.map((payment) => payment.type).toList();

  void selectPayment(PaymentType type) {
    if (state.isPlacing) return;
    emit(CheckoutState(payment: type));
  }

  Future<void> placeOrder(List<CartItem> items) async {
    if (state.isPlacing) return;
    final payment = state.payment;
    emit(CheckoutState(payment: payment, isPlacing: true));
    try {
      final order = await _placeOrder(
        userId: _userId,
        items: items,
        payment: _payments.firstWhere((method) => method.type == payment),
      );
      if (isClosed) return;
      emit(
        CheckoutState(
          payment: payment,
          orderPlaced: true,
          message: switch (order.paymentStatus) {
            PaymentStatus.paid => AppStrings.orderPlacedPaid,
            PaymentStatus.dueOnDelivery => AppStrings.orderPlacedCash,
            PaymentStatus.pending => AppStrings.orderPlacedCardPending,
          },
        ),
      );
    } catch (error) {
      if (isClosed) return;
      emit(CheckoutState(payment: payment, message: _errorMessage(error)));
    }
  }

  String _errorMessage(Object error) {
    if (error is! OrderFailure) return AppStrings.orderSaveError;
    return switch (error.type) {
      OrderFailureType.emptyCart => AppStrings.emptyCart,
      OrderFailureType.network => AppStrings.networkError,
      OrderFailureType.payment => AppStrings.paymentError,
      OrderFailureType.service => AppStrings.orderSaveError,
    };
  }
}
