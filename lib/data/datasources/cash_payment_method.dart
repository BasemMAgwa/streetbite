import '../../domain/entities/payment_status.dart';
import '../../domain/entities/payment_type.dart';
import '../../domain/repositories/payment_method.dart';

class CashPaymentMethod implements PaymentMethod {
  const CashPaymentMethod();

  @override
  PaymentType get type => PaymentType.cash;

  @override
  Future<PaymentStatus> pay(int amountCents) async =>
      PaymentStatus.dueOnDelivery;
}
