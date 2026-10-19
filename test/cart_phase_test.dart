import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streetbite/core/constants/message.dart';
import 'package:streetbite/l10n/app_localizations.dart';

import 'helpers/l10n.dart';

import 'package:streetbite/core/formatting/price_formatter.dart';
import 'package:streetbite/core/theme/app_theme.dart';
import 'package:streetbite/data/datasources/card_payment_method.dart';
import 'package:streetbite/data/datasources/cart_local_data_source.dart';
import 'package:streetbite/data/datasources/device_location_source.dart';
import 'package:streetbite/data/datasources/cash_payment_method.dart';
import 'package:streetbite/data/models/order_model.dart';
import 'package:streetbite/domain/entities/cart_item.dart';
import 'package:streetbite/domain/entities/meal.dart';
import 'package:streetbite/domain/entities/order.dart';
import 'package:streetbite/domain/entities/order_failure.dart';
import 'package:streetbite/domain/entities/order_pricing.dart';
import 'package:streetbite/domain/entities/payment_status.dart';
import 'package:streetbite/domain/entities/payment_type.dart';
import 'package:streetbite/domain/repositories/order_repository.dart';
import 'package:streetbite/domain/usecases/place_order.dart';
import 'package:streetbite/presentation/blocs/cart_bloc.dart';
import 'package:streetbite/presentation/blocs/cart_event.dart';
import 'package:streetbite/presentation/blocs/cart_state.dart';
import 'package:streetbite/presentation/blocs/checkout_cubit.dart';
import 'package:streetbite/presentation/blocs/theme_bloc.dart';
import 'package:streetbite/presentation/screens/cart_screen.dart';

import 'automation/base_automation.dart';
import 'automation/cart_automation.dart';

const burger = Meal(
  id: '52772',
  name: 'Burger',
  category: 'Beef',
  imageUrl: '',
  area: 'American',
  instructions: '',
);

const soup = Meal(
  id: '52773',
  name: 'Soup',
  category: 'Starter',
  imageUrl: '',
  area: 'French',
  instructions: '',
);

class FakeOrderRepository implements OrderRepository {
  FakeOrderRepository({this.failure});

  final OrderFailure? failure;
  final orders = <Order>[];

  @override
  Future<String> placeOrder(Order order) async {
    if (failure != null) throw failure!;
    orders.add(order);
    return 'order-${orders.length}';
  }

  @override
  Stream<List<Order>> watchOrders(String userId) => Stream.value(orders);
}

class UnavailableLocationSource extends DeviceLocationSource {
  @override
  Future<Position?> currentPosition() async => null;
}

Future<CartState> send(CartBloc cart, CartEvent event) {
  final next = cart.stream.first;
  cart.add(event);
  return next;
}

CheckoutCubit checkout(FakeOrderRepository repository) => CheckoutCubit(
  PlaceOrder(repository),
  'user-1',
  const [CashPaymentMethod(), CardPaymentMethod()],
);

void main() {
  test('cart restores quantities per user and clears the saved cart', () async {
    BaseTest.resetPreferences();
    final storage = CartLocalDataSource(SharedPreferencesAsync());
    final first = CartBloc(storage);
    await send(first, const RestoreCart('user-1'));
    await send(first, const AddMealToCart(burger));
    await send(first, const AddMealToCart(burger));
    await first.close();

    final restored = CartBloc(storage);
    var state = await send(restored, const RestoreCart('user-1'));
    expect(state.items.single.quantity, 2);
    expect(state.items.single.meal.area, burger.area);
    await send(restored, DecreaseMealQuantity(burger.id));
    state = await send(restored, const RestoreCart('user-2'));
    expect(state.items, isEmpty);
    state = await send(restored, const RestoreCart('user-1'));
    expect(state.items.single.quantity, 1);
    await send(restored, const EmptyCart());
    await restored.close();

    final afterClear = CartBloc(storage);
    state = await send(afterClear, const RestoreCart('user-1'));
    expect(state.items, isEmpty);
    await afterClear.close();
  });

  test('cart groups quantities and updates the total', () async {
    final cart = CartBloc();
    await send(cart, const AddMealToCart(burger));
    var state = await send(cart, const AddMealToCart(burger));
    expect(state.items.single.quantity, 2);
    expect(state.count, 2);
    expect(state.totalCents, burger.priceCents * 2);

    state = await send(cart, const AddMealToCart(soup));
    expect(state.totalCents, burger.priceCents * 2 + soup.priceCents);

    state = await send(cart, DecreaseMealQuantity(burger.id));
    expect(state.items.first.quantity, 1);

    state = await send(cart, RemoveMealFromCart(soup.id));
    expect(state.items.single.meal.id, burger.id);

    state = await send(cart, DecreaseMealQuantity(burger.id));
    expect(state.items, isEmpty);
    expect(state.checkedOut, false);

    await send(cart, const AddMealToCart(burger));
    state = await send(cart, const ClearCart());
    expect(state.items, isEmpty);
    expect(state.checkedOut, true);
    await cart.close();
  });

  test('cash order is saved with total and due-on-delivery status', () async {
    final repository = FakeOrderRepository();
    final order = await PlaceOrder(repository)(
      userId: 'user-1',
      items: [CartItem.fromMeal(burger).withQuantity(3)],
      payment: const CashPaymentMethod(),
    );

    expect(order.id, 'order-1');
    expect(
      repository.orders.single.totalCents,
      burger.priceCents * 3 +
          OrderPricing.deliveryFeeCents +
          OrderPricing.taxesFeeCents,
    );
    expect(repository.orders.single.paymentType, PaymentType.cash);
    expect(repository.orders.single.paymentStatus, PaymentStatus.dueOnDelivery);
  });

  test('empty cart cannot be ordered', () {
    expect(
      PlaceOrder(FakeOrderRepository())(
        userId: 'user-1',
        items: const [],
        payment: const CashPaymentMethod(),
      ),
      throwsA(isA<OrderFailure>()),
    );
  });

  test('card order remains pending without a payment gateway', () async {
    final repository = FakeOrderRepository();
    final cubit = checkout(repository)..selectPayment(PaymentType.card);
    await cubit.placeOrder([CartItem.fromMeal(soup)]);

    expect(cubit.state.orderPlaced, true);
    expect(cubit.state.message, AppMessage.orderPlacedCardPending);
    expect(repository.orders.single.paymentStatus, PaymentStatus.pending);
    await cubit.close();
  });

  test('checkout shows a friendly message when offline', () async {
    final cubit = checkout(
      FakeOrderRepository(
        failure: const OrderFailure(OrderFailureType.network),
      ),
    );
    await cubit.placeOrder([CartItem.fromMeal(soup)]);

    expect(cubit.state.orderPlaced, false);
    expect(cubit.state.isPlacing, false);
    expect(cubit.state.message, AppMessage.networkError);
    await cubit.close();
  });

  test('order model round-trips through JSON', () {
    final order = OrderModel(
      id: 'order-1',
      userId: 'user-1',
      items: [CartItem.fromMeal(burger).withQuantity(2)],
      totalCents: burger.priceCents * 2,
      paymentType: PaymentType.card,
      paymentStatus: PaymentStatus.paid,
      createdAt: DateTime.utc(2026, 1, 2),
    );

    final restored = OrderModel.fromJson(order.toJson());
    expect(restored.id, order.id);
    expect(restored.items.single.meal.name, burger.name);
    expect(restored.items.single.quantity, 2);
    expect(restored.totalCents, order.totalCents);
    expect(restored.paymentType, PaymentType.card);
    expect(restored.createdAt, order.createdAt);
  });

  testWidgets('removing the last item shows the empty cart snackbar', (
    tester,
  ) async {
    BaseTest.resetPreferences();
    final cart = CartBloc()..add(const AddMealToCart(burger));
    addTearDown(cart.close);
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: cart),
          BlocProvider(create: (_) => ThemeBloc(SharedPreferencesAsync())),
          BlocProvider(create: (_) => checkout(FakeOrderRepository())),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.light,
          home: const CartScreen(),
        ),
      ),
    );
    await tester.pump();
    expect(find.text(enL10n.total), findsOneWidget);
    expect(find.text(enL10n.continueToCheckout), findsOneWidget);

    await tester.tap(find.byTooltip(enL10n.removeFromCart));
    await tester.pump();
    await tester.pump();

    expect(find.text(enL10n.cartEmptied), findsOneWidget);
    expect(find.text(enL10n.emptyCart), findsOneWidget);
  });

  testWidgets('cart continues to checkout inside the same drawer layout', (
    tester,
  ) async {
    BaseTest.resetPreferences();
    final cart = CartBloc()..add(const AddMealToCart(burger));
    addTearDown(cart.close);
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: cart),
          BlocProvider(create: (_) => ThemeBloc(SharedPreferencesAsync())),
          BlocProvider(create: (_) => checkout(FakeOrderRepository())),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.light,
          home: CartScreen(locationSource: UnavailableLocationSource()),
        ),
      ),
    );
    await tester.pump();
    expect(find.text(enL10n.clearCart), findsOneWidget);
    expect(
      tester.getTopLeft(find.text(enL10n.clearCart)).dy,
      tester.getTopLeft(find.text(enL10n.continueToCheckout)).dy,
    );
    await CartAutomation(tester).increaseQuantity(enL10n);
    expect(cart.state.items.single.quantity, 2);
    await CartAutomation(tester).decreaseQuantity(enL10n);
    expect(cart.state.items.single.quantity, 1);
    await CartAutomation(tester).continueToCheckout(enL10n);
    expect(find.text(enL10n.checkout), findsOneWidget);
    expect(find.text(enL10n.paymentMethod), findsOneWidget);
    expect(
      tester.getTopLeft(find.text(enL10n.cashPayment)).dy,
      closeTo(tester.getTopLeft(find.text(enL10n.cardPayment)).dy, 2),
    );
    expect(
      tester.getTopLeft(find.text(enL10n.cashPayment)).dx,
      lessThan(tester.getTopLeft(find.text(enL10n.cardPayment)).dx),
    );
    await tester.tap(find.text(enL10n.cardPayment));
    await tester.pump();
    expect(find.text(enL10n.cardPaymentNote), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text(enL10n.deliveryFee),
      180,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    expect(find.text(enL10n.orderSummary), findsOneWidget);
    expect(find.text(enL10n.deliveryFee), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text(enL10n.taxesFee),
      180,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    expect(find.text(enL10n.taxesFee), findsOneWidget);
    expect(
      find.text(
        PriceFormatter.format(OrderPricing.totalCents(cart.state.items)),
      ),
      findsOneWidget,
    );
    expect(find.text(enL10n.placeOrder), findsOneWidget);
  });
}
