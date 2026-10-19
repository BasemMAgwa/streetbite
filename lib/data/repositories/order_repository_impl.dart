import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' hide Order;

import '../../core/errors/network_error.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_failure.dart';
import '../../domain/repositories/order_repository.dart';
import '../models/order_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  const OrderRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _user(String userId) =>
      _firestore.collection('Users').doc(userId);

  @override
  Stream<List<Order>> watchOrders(String userId) {
    late StreamController<List<Order>> controller;
    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
    userSubscription;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? legacySubscription;
    List<Order>? documentOrders;
    List<Order>? legacyOrders;

    void publish() {
      if (documentOrders == null || legacyOrders == null) return;
      final byId = <String, Order>{};
      for (final order in legacyOrders!) {
        if (order.id != null) byId[order.id!] = order;
      }
      for (final order in documentOrders!) {
        if (order.id != null) byId[order.id!] = order;
      }
      final orders = byId.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      controller.add(orders);
    }

    void reportError(Object error, StackTrace stackTrace) =>
        controller.addError(
          OrderFailure(
            isNetworkError(error)
                ? OrderFailureType.network
                : OrderFailureType.service,
          ),
          stackTrace,
        );

    controller = StreamController<List<Order>>(
      onListen: () {
        userSubscription = _user(userId).snapshots().listen((snapshot) {
          try {
            final raw = snapshot.data()?['orders'];
            if (raw is! Map) {
              documentOrders = [];
            } else {
              documentOrders = raw.entries
                  .where((entry) => entry.value is Map)
                  .map((entry) {
                    final data = Map<String, dynamic>.from(entry.value as Map);
                    data['id'] = entry.key.toString();
                    return OrderModel.fromJson(data);
                  })
                  .toList();
            }
            publish();
          } catch (error, stackTrace) {
            reportError(error, stackTrace);
          }
        }, onError: reportError);
        legacySubscription = _user(userId)
            .collection('Orders')
            .snapshots()
            .listen((snapshot) {
              try {
                legacyOrders = snapshot.docs.map((document) {
                  final data = document.data()..['id'] = document.id;
                  return OrderModel.fromJson(data);
                }).toList();
                publish();
              } catch (error, stackTrace) {
                reportError(error, stackTrace);
              }
            }, onError: reportError);
      },
      onCancel: () async {
        await userSubscription?.cancel();
        await legacySubscription?.cancel();
      },
    );
    return controller.stream;
  }

  @override
  Future<String> placeOrder(Order order) async {
    try {
      final id = _user(order.userId).collection('Orders').doc().id;
      final data = OrderModel.fromOrder(order).toJson()..['id'] = id;
      // Merge keeps the write working for accounts whose profile document is
      // missing; the rules require the document id field on every write.
      await _user(order.userId)
          .set({
            'id': order.userId,
            'orders': {id: data},
          }, SetOptions(merge: true))
          .timeout(const Duration(seconds: 15));
      return id;
    } catch (error) {
      throw OrderFailure(
        isNetworkError(error)
            ? OrderFailureType.network
            : OrderFailureType.service,
      );
    }
  }
}
