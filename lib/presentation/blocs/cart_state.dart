import '../../domain/entities/cart_item.dart';
import '../../domain/entities/order_pricing.dart';

class CartState {
  const CartState({this.items = const [], this.checkedOut = false});

  final List<CartItem> items;

  /// True when the cart was emptied by a placed order rather than by the user.
  final bool checkedOut;

  int get count => items.fold(0, (sum, item) => sum + item.quantity);

  bool containsMeal(String mealId) =>
      items.any((item) => item.meal.id == mealId);

  int get totalCents => OrderPricing.subtotalCents(items);

  int get checkoutTotalCents => OrderPricing.totalCents(items);
}
