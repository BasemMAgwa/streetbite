import '../../domain/entities/meal.dart';

sealed class CartEvent {
  const CartEvent();
}

class RestoreCart extends CartEvent {
  const RestoreCart(this.userId);

  final String userId;
}

class ResetCart extends CartEvent {
  const ResetCart();
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

class EmptyCart extends CartEvent {
  const EmptyCart();
}
