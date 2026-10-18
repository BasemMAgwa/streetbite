import 'cart_item.dart';
import 'payment_status.dart';
import 'payment_type.dart';

class Order {
  const Order({
    this.id,
    required this.userId,
    required this.items,
    required this.totalCents,
    required this.paymentType,
    required this.paymentStatus,
    required this.createdAt,
  });

  final String? id;
  final String userId;
  final List<CartItem> items;
  final int totalCents;
  final PaymentType paymentType;
  final PaymentStatus paymentStatus;
  final DateTime createdAt;
}
