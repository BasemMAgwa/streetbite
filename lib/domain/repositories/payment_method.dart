import '../entities/payment_status.dart';
import '../entities/payment_type.dart';

// Each payment option implements this contract, so checkout depends on the
// abstraction and new methods can be added without changing it (SOLID: OCP, DIP).
abstract class PaymentMethod {
  PaymentType get type;

  Future<PaymentStatus> pay(int amountCents);
}
