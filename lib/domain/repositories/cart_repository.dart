import '../entities/cart_item.dart';

abstract class CartRepository {
  Future<List<CartItem>> load(String userId);

  Future<void> save(String userId, List<CartItem> items);
}
