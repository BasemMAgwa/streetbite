import '../../domain/entities/order.dart';

class OrdersState {
  const OrdersState({
    this.orders = const [],
    this.isLoading = true,
    this.message,
  });

  final List<Order> orders;
  final bool isLoading;
  final String? message;
}
