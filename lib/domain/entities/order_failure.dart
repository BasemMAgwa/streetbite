enum OrderFailureType { emptyCart, network, payment, service }

class OrderFailure implements Exception {
  const OrderFailure(this.type);

  final OrderFailureType type;
}
