import '../entities/cart_item.dart';
import '../entities/order.dart';
import '../entities/order_failure.dart';
import '../repositories/order_repository.dart';
import '../repositories/payment_method.dart';

class PlaceOrder {
  const PlaceOrder(this._repository);

  final OrderRepository _repository;

  Future<Order> call({
    required String userId,
    required List<CartItem> items,
    required PaymentMethod payment,
  }) async {
    if (items.isEmpty) throw const OrderFailure(OrderFailureType.emptyCart);
    final total = items.fold<int>(0, (sum, item) => sum + item.totalCents);
    final status = await payment.pay(total);
    final order = Order(
      userId: userId,
      items: items,
      totalCents: total,
      paymentType: payment.type,
      paymentStatus: status,
      createdAt: DateTime.now(),
    );
    final id = await _repository.placeOrder(order);
    return Order(
      id: id,
      userId: order.userId,
      items: order.items,
      totalCents: order.totalCents,
      paymentType: order.paymentType,
      paymentStatus: order.paymentStatus,
      createdAt: order.createdAt,
    );
  }
}
