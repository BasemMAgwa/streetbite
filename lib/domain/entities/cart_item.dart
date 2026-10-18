import 'meal.dart';

class CartItem {
  const CartItem({
    required this.meal,
    required this.quantity,
    required this.unitPriceCents,
  });

  CartItem.fromMeal(Meal meal)
    : this(meal: meal, quantity: 1, unitPriceCents: meal.priceCents);

  final Meal meal;
  final int quantity;
  final int unitPriceCents;

  int get totalCents => unitPriceCents * quantity;

  CartItem withQuantity(int quantity) =>
      CartItem(meal: meal, quantity: quantity, unitPriceCents: unitPriceCents);
}
