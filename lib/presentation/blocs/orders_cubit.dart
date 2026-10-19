import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_strings.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_failure.dart';
import '../../domain/repositories/order_repository.dart';
import 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit(this._repository, this._userId) : super(const OrdersState());

  final OrderRepository _repository;
  final String _userId;
  StreamSubscription<List<Order>>? _subscription;

  void load() {
    _subscription?.cancel();
    emit(OrdersState(orders: state.orders));
    _subscription = _repository
        .watchOrders(_userId)
        .listen(
          (orders) {
            if (!isClosed) emit(OrdersState(orders: orders, isLoading: false));
          },
          onError: (Object error) {
            if (isClosed) return;
            final message =
                error is OrderFailure && error.type == OrderFailureType.network
                ? AppStrings.networkError
                : AppStrings.ordersLoadError;
            emit(
              OrdersState(
                orders: state.orders,
                isLoading: false,
                message: message,
              ),
            );
          },
        );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await super.close();
  }
}
