import 'cart_item.dart';

class OrderPricing {
  const OrderPricing._();

  static const deliveryFeeCents = 399;
  static const taxesFeeCents = 245;

  static int subtotalCents(List<CartItem> items) =>
      items.fold(0, (sum, item) => sum + item.totalCents);

  static int totalCents(List<CartItem> items) => items.isEmpty
      ? 0
      : subtotalCents(items) + deliveryFeeCents + taxesFeeCents;
}
