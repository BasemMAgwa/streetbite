import '../../domain/entities/meal.dart';

sealed class CartEvent {
  const CartEvent();
}

class AddMealToCart extends CartEvent {
  const AddMealToCart(this.meal);

  final Meal meal;
}
