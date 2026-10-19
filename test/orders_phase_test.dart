import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streetbite/core/constants/message.dart';
import 'package:streetbite/l10n/app_localizations.dart';

import 'helpers/l10n.dart';

import 'package:streetbite/core/theme/app_theme.dart';
import 'package:streetbite/domain/entities/cart_item.dart';
import 'package:streetbite/domain/entities/meal.dart';
import 'package:streetbite/domain/entities/order.dart';
import 'package:streetbite/domain/entities/order_failure.dart';
import 'package:streetbite/domain/entities/payment_status.dart';
import 'package:streetbite/domain/entities/payment_type.dart';
import 'package:streetbite/domain/repositories/order_repository.dart';
import 'package:streetbite/presentation/blocs/orders_cubit.dart';
import 'package:streetbite/presentation/screens/orders_screen.dart';

class _OrderRepository implements OrderRepository {
  final controller = StreamController<List<Order>>.broadcast();

  @override
  Future<String> placeOrder(Order order) async => 'saved-order';

  @override
  Stream<List<Order>> watchOrders(String userId) => controller.stream;
}

void main() {
  testWidgets('Orders tab updates when the user order stream changes', (
    tester,
  ) async {
    final repository = _OrderRepository();
    final cubit = OrdersCubit(repository, 'user-1')..load();
    addTearDown(() async {
      await cubit.close();
      await repository.controller.close();
    });

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.light,
          home: const Scaffold(body: OrdersScreen()),
        ),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    repository.controller.add([]);
    await tester.pump();
    expect(find.text(enL10n.noOrders), findsOneWidget);

    repository.controller.add([
      Order(
        id: 'order-1',
        userId: 'user-1',
        items: [
          CartItem.fromMeal(
            const Meal(
              id: '1',
              name: 'Tacos',
              category: 'Main',
              imageUrl: '',
              area: 'Mexican',
              instructions: '',
            ),
          ).withQuantity(2),
        ],
        totalCents: 1299,
        paymentType: PaymentType.cash,
        paymentStatus: PaymentStatus.dueOnDelivery,
        createdAt: DateTime.now(),
      ),
    ]);
    await tester.pump();
    expect(find.text('Tacos'), findsOneWidget);
    expect(find.text('2 items · Today'), findsOneWidget);
    expect(find.text(r'$12.99'), findsOneWidget);
    expect(find.text(enL10n.cashOnDeliveryStatus), findsOneWidget);
    expect(find.text(enL10n.noOrders), findsNothing);
  });

  test('order stream errors show a friendly message', () async {
    final repository = _OrderRepository();
    final cubit = OrdersCubit(repository, 'user-1')..load();
    repository.controller.addError(
      const OrderFailure(OrderFailureType.network),
    );
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.message, AppMessage.networkError);
    expect(cubit.state.isLoading, false);
    await cubit.close();
    await repository.controller.close();
  });
}
