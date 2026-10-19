import '../../domain/entities/payment_status.dart';
import '../../domain/entities/payment_type.dart';
import '../../domain/repositories/payment_method.dart';

// Strategy pattern: checkout selects this PaymentMethod implementation by type.
// Card is a payment choice only until a real payment gateway is connected.
// Never report a card order as paid without a successful charge.
class CardPaymentMethod implements PaymentMethod {
  const CardPaymentMethod();

  @override
  PaymentType get type => PaymentType.card;

  @override
  Future<PaymentStatus> pay(int amountCents) async => PaymentStatus.pending;
}
