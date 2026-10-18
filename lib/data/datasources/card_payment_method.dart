import '../../domain/entities/payment_status.dart';
import '../../domain/entities/payment_type.dart';
import '../../domain/repositories/payment_method.dart';

// Simulated for the capstone demo: no card data is collected and nothing is
// charged. A real gateway would replace this class without touching checkout.
class CardPaymentMethod implements PaymentMethod {
  const CardPaymentMethod({this.delay = const Duration(milliseconds: 600)});

  final Duration delay;

  @override
  PaymentType get type => PaymentType.card;

  @override
  Future<PaymentStatus> pay(int amountCents) async {
    await Future<void>.delayed(delay);
    return PaymentStatus.paid;
  }
}
