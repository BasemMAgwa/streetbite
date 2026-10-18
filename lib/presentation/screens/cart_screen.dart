import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_strings.dart';
import '../../injection.dart';
import '../blocs/auth_cubit.dart';
import '../blocs/cart_bloc.dart';
import '../blocs/cart_event.dart';
import '../blocs/cart_state.dart';
import '../blocs/checkout_cubit.dart';
import '../blocs/checkout_state.dart';
import '../widgets/app_header_actions.dart';
import '../widgets/app_snack_bar.dart';
import '../widgets/cart_checkout_panel.dart';
import '../widgets/cart_item_tile.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  static void open(BuildContext context) {
    final userId = context.read<AuthCubit>().state.user?.id;
    if (userId == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => locator<CheckoutCubit>(param1: userId),
          child: const CartScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => MultiBlocListener(
    listeners: [
      BlocListener<CartBloc, CartState>(
        listenWhen: (previous, current) =>
            previous.items.isNotEmpty &&
            current.items.isEmpty &&
            !current.checkedOut,
        listener: (context, _) =>
            showAppSnackBar(context, AppStrings.cartEmptied),
      ),
      BlocListener<CheckoutCubit, CheckoutState>(
        listenWhen: (_, current) => current.message != null,
        listener: (context, state) {
          showAppSnackBar(context, state.message!);
          if (state.orderPlaced) {
            context.read<CartBloc>().add(const ClearCart());
            Navigator.of(context).pop();
          }
        },
      ),
    ],
    child: Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.cart),
        actions: const [ThemeToggleButton(), SizedBox(width: 8)],
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state.items.isEmpty) return const _EmptyCart();
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, index) => CartItemTile(state.items[index]),
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) => state.items.isEmpty
            ? const SizedBox.shrink()
            : CartCheckoutPanel(state),
      ),
    ),
  );
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.shopping_cart_outlined,
          size: 52,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 12),
        const Text(AppStrings.emptyCart),
      ],
    ),
  );
}
