import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../models/cart_item_model.dart';

class CartLocalDataSource implements CartRepository {
  const CartLocalDataSource(this._preferences);

  final SharedPreferencesAsync _preferences;

  String _key(String userId) => 'streetbite_cart_v1_$userId';

  @override
  Future<List<CartItem>> load(String userId) async {
    final saved = await _preferences.getString(_key(userId));
    if (saved == null) return [];
    final values = jsonDecode(saved);
    if (values is! List) return [];
    return values
        .whereType<Map>()
        .map(
          (value) => CartItemModel.fromJson(Map<String, dynamic>.from(value)),
        )
        .where(
          (item) =>
              item.meal.id.isNotEmpty &&
              item.quantity > 0 &&
              item.unitPriceCents >= 0,
        )
        .toList();
  }

  @override
  Future<void> save(String userId, List<CartItem> items) =>
      _preferences.setString(
        _key(userId),
        jsonEncode(
          items
              .map((item) => CartItemModel.fromCartItem(item).toJson())
              .toList(),
        ),
      );
}
