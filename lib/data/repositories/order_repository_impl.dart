import 'package:cloud_firestore/cloud_firestore.dart' hide Order;

import '../../core/errors/network_error.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_failure.dart';
import '../../domain/repositories/order_repository.dart';
import '../models/order_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  const OrderRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<String> placeOrder(Order order) async {
    try {
      final document = _firestore
          .collection('Users')
          .doc(order.userId)
          .collection('Orders')
          .doc();
      final data = OrderModel.fromOrder(order).toJson()..['id'] = document.id;
      // Firestore waits indefinitely for the server while offline.
      await document.set(data).timeout(const Duration(seconds: 15));
      return document.id;
    } catch (error) {
      throw OrderFailure(
        isNetworkError(error)
            ? OrderFailureType.network
            : OrderFailureType.service,
      );
    }
  }
}
