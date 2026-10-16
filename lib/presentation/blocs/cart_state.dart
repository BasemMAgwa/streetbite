import '../../domain/entities/meal.dart';

class CartState {
  const CartState({this.items = const [], this.lastAdded});

  final List<Meal> items;
  final Meal? lastAdded;

  int get count => items.length;
}
