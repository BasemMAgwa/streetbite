import '../../domain/entities/meal.dart';

sealed class CartEvent {
  const CartEvent();
}

class AddMealToCart extends CartEvent {
  const AddMealToCart(this.meal);

  final Meal meal;
}

class DecreaseMealQuantity extends CartEvent {
  const DecreaseMealQuantity(this.mealId);

  final String mealId;
}

class RemoveMealFromCart extends CartEvent {
  const RemoveMealFromCart(this.mealId);

  final String mealId;
}

class ClearCart extends CartEvent {
  const ClearCart();
}
