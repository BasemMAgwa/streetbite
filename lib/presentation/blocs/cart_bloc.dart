import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc([this._storage]) : super(const CartState()) {
    // Restore and edits share one queue, so an early tap cannot overwrite
    // a pending restore or save an older cart after a newer edit.
    on<CartEvent>(
      _handleEvent,
      transformer: (events, mapper) => events.asyncExpand(mapper),
    );
  }

  final CartRepository? _storage;
  String? _userId;

  Future<void> _handleEvent(CartEvent event, Emitter<CartState> emit) async {
    switch (event) {
      case RestoreCart(:final userId):
        _userId = userId;
        try {
          emit(CartState(items: await _storage?.load(userId) ?? []));
        } catch (_) {
          emit(const CartState());
        }
        return;
      case ResetCart():
        _userId = null;
        emit(const CartState());
        return;
      case AddMealToCart(:final meal):
        final items = [...state.items];
        final index = items.indexWhere((item) => item.meal.id == meal.id);
        if (index == -1) {
          items.add(CartItem.fromMeal(meal));
        } else {
          items[index] = items[index].withQuantity(items[index].quantity + 1);
        }
        emit(CartState(items: items));
      case DecreaseMealQuantity(:final mealId):
        final items = [...state.items];
        final index = items.indexWhere((item) => item.meal.id == mealId);
        if (index == -1) return;
        final item = items[index];
        if (item.quantity > 1) {
          items[index] = item.withQuantity(item.quantity - 1);
        } else {
          items.removeAt(index);
        }
        emit(CartState(items: items));
      case RemoveMealFromCart(:final mealId):
        emit(
          CartState(
            items: state.items.where((item) => item.meal.id != mealId).toList(),
          ),
        );
      case ClearCart():
        emit(const CartState(checkedOut: true));
      case EmptyCart():
        emit(const CartState());
    }
    final userId = _userId;
    if (userId != null && _storage != null) {
      try {
        await _storage.save(userId, state.items);
      } catch (_) {
        // Keep the working cart in memory if local storage is unavailable.
      }
    }
  }
}
