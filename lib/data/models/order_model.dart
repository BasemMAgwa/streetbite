import '../../domain/entities/order.dart';
import '../../domain/entities/payment_status.dart';
import '../../domain/entities/payment_type.dart';
import 'cart_item_model.dart';

class OrderModel extends Order {
  const OrderModel({
    super.id,
    required super.userId,
    required super.items,
    required super.totalCents,
    required super.paymentType,
    required super.paymentStatus,
    required super.createdAt,
  });

  factory OrderModel.fromOrder(Order order) => OrderModel(
    id: order.id,
    userId: order.userId,
    items: order.items,
    totalCents: order.totalCents,
    paymentType: order.paymentType,
    paymentStatus: order.paymentStatus,
    createdAt: order.createdAt,
  );

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    id: json['id'] as String?,
    userId: json['userId'] as String? ?? '',
    items: (json['items'] as List? ?? [])
        .whereType<Map>()
        .map((item) => CartItemModel.fromJson(Map<String, dynamic>.from(item)))
        .toList(),
    totalCents: json['totalCents'] as int? ?? 0,
    paymentType: PaymentType.values.firstWhere(
      (type) => type.name == json['paymentType'],
      orElse: () => PaymentType.cash,
    ),
    paymentStatus: PaymentStatus.values.firstWhere(
      (status) => status.name == json['paymentStatus'],
      orElse: () => PaymentStatus.dueOnDelivery,
    ),
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'items': items
        .map((item) => CartItemModel.fromCartItem(item).toJson())
        .toList(),
    'totalCents': totalCents,
    'paymentType': paymentType.name,
    'paymentStatus': paymentStatus.name,
    'createdAt': createdAt.toIso8601String(),
  };
}
