import '../../domain/entities/cart_item.dart';
import 'meal_model.dart';

class CartItemModel extends CartItem {
  const CartItemModel({
    required super.meal,
    required super.quantity,
    required super.unitPriceCents,
  });

  factory CartItemModel.fromCartItem(CartItem item) => CartItemModel(
    meal: item.meal,
    quantity: item.quantity,
    unitPriceCents: item.unitPriceCents,
  );

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
    meal: MealModel(
      id: json['mealId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      area: json['area'] as String? ?? '',
      instructions: json['instructions'] as String? ?? '',
    ),
    quantity: json['quantity'] as int? ?? 1,
    unitPriceCents: json['unitPriceCents'] as int? ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'mealId': meal.id,
    'name': meal.name,
    'category': meal.category,
    'imageUrl': meal.imageUrl,
    'area': meal.area,
    'instructions': meal.instructions,
    'quantity': quantity,
    'unitPriceCents': unitPriceCents,
  };
}
