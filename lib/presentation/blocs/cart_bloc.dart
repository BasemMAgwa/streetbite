import 'package:flutter_bloc/flutter_bloc.dart';

import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    on<AddMealToCart>((event, emit) {
      emit(
        CartState(items: [...state.items, event.meal], lastAdded: event.meal),
      );
    });
  }
}
