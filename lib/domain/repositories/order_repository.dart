import '../entities/order.dart';

abstract class OrderRepository {
  /// Saves the order and returns its generated id.
  Future<String> placeOrder(Order order);
}
