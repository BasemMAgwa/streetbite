import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:streetbite/core/constants/app_strings.dart';
import 'package:streetbite/core/theme/app_theme.dart';
import 'package:streetbite/data/datasources/card_payment_method.dart';
import 'package:streetbite/data/datasources/cash_payment_method.dart';
import 'package:streetbite/data/models/order_model.dart';
import 'package:streetbite/domain/entities/cart_item.dart';
import 'package:streetbite/domain/entities/meal.dart';
import 'package:streetbite/domain/entities/order.dart';
import 'package:streetbite/domain/entities/order_failure.dart';
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
}

Future<CartState> send(CartBloc cart, CartEvent event) {
  final next = cart.stream.first;
  cart.add(event);
  return next;
}

CheckoutCubit checkout(FakeOrderRepository repository) => CheckoutCubit(
  PlaceOrder(repository),
  'user-1',
  const [CashPaymentMethod(), CardPaymentMethod(delay: Duration.zero)],
);

void main() {
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
    expect(repository.orders.single.totalCents, burger.priceCents * 3);
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

  test('checkout pays by simulated card and reports success', () async {
    final repository = FakeOrderRepository();
    final cubit = checkout(repository)..selectPayment(PaymentType.card);
    await cubit.placeOrder([CartItem.fromMeal(soup)]);

    expect(cubit.state.orderPlaced, true);
    expect(cubit.state.message, AppStrings.orderPlacedPaid);
    expect(repository.orders.single.paymentStatus, PaymentStatus.paid);
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
    expect(cubit.state.message, AppStrings.networkError);
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
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    final cart = CartBloc()..add(const AddMealToCart(burger));
    addTearDown(cart.close);
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: cart),
          BlocProvider(create: (_) => ThemeBloc(SharedPreferencesAsync())),
          BlocProvider(create: (_) => checkout(FakeOrderRepository())),
        ],
        child: MaterialApp(theme: AppTheme.light, home: const CartScreen()),
      ),
    );
    await tester.pump();
    expect(find.text(AppStrings.total), findsOneWidget);
    expect(find.text(AppStrings.placeOrder), findsOneWidget);

    await tester.tap(find.byTooltip(AppStrings.removeFromCart));
    await tester.pump();
    await tester.pump();

    expect(find.text(AppStrings.cartEmptied), findsOneWidget);
    expect(find.text(AppStrings.emptyCart), findsOneWidget);
  });
}
