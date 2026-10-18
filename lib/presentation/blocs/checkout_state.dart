import '../../domain/entities/payment_type.dart';

class CheckoutState {
  const CheckoutState({
    this.payment = PaymentType.cash,
    this.isPlacing = false,
    this.orderPlaced = false,
    this.message,
  });

  final PaymentType payment;
  final bool isPlacing;
  final bool orderPlaced;
  final String? message;
}
