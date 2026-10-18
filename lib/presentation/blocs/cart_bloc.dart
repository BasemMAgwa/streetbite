import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/cart_item.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    on<AddMealToCart>((event, emit) {
      final items = [...state.items];
      final index = _indexOf(event.meal.id);
      if (index == -1) {
        items.add(CartItem.fromMeal(event.meal));
      } else {
        items[index] = items[index].withQuantity(items[index].quantity + 1);
      }
      emit(CartState(items: items));
    });
    on<DecreaseMealQuantity>((event, emit) {
      final index = _indexOf(event.mealId);
      if (index == -1) return;
      final items = [...state.items];
      final item = items[index];
      if (item.quantity > 1) {
        items[index] = item.withQuantity(item.quantity - 1);
      } else {
        items.removeAt(index);
      }
      emit(CartState(items: items));
    });
    on<RemoveMealFromCart>((event, emit) {
      emit(
        CartState(
          items: state.items
              .where((item) => item.meal.id != event.mealId)
              .toList(),
        ),
      );
    });
    on<ClearCart>((_, emit) => emit(const CartState(checkedOut: true)));
  }

  int _indexOf(String mealId) =>
      state.items.indexWhere((item) => item.meal.id == mealId);
}
