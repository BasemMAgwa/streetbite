import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../l10n/app_localizations.dart';
import '../../core/formatting/price_formatter.dart';
import '../../core/theme/app_theme.dart';
import '../../data/datasources/device_location_source.dart';
import '../../injection.dart';
import '../blocs/auth_cubit.dart';
import '../blocs/cart_bloc.dart';
import '../blocs/cart_event.dart';
import '../blocs/cart_state.dart';
import '../blocs/checkout_cubit.dart';
import '../blocs/checkout_state.dart';
import '../../core/constants/message.dart';
import '../widgets/app_snack_bar.dart';
import '../l10n/message_localizations.dart';
import '../widgets/cart_checkout_panel.dart';
import '../widgets/cart_item_tile.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({
    super.key,
    this.locationSource = const DeviceLocationSource(),
  });

  final DeviceLocationSource locationSource;

  static void open(BuildContext context) {
    final userId = context.read<AuthCubit>().state.user?.id;
    if (userId == null) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.9,
        child: BlocProvider(
          create: (_) => locator<CheckoutCubit>(param1: userId),
          child: const CartScreen(),
        ),
      ),
    );
  }

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _checkout = false;

  @override
  Widget build(BuildContext context) => MultiBlocListener(
    listeners: [
      BlocListener<CartBloc, CartState>(
        listenWhen: (previous, current) =>
            previous.items.isNotEmpty &&
            current.items.isEmpty &&
            !current.checkedOut,
        listener: (context, _) {
          showAppSnackBar(
            context,
            AppMessage.cartEmptied.text(AppLocalizations.of(context)),
          );
          if (_checkout) setState(() => _checkout = false);
        },
      ),
      BlocListener<CheckoutCubit, CheckoutState>(
        listenWhen: (_, current) => current.message != null,
        listener: (context, state) {
          showAppSnackBar(
            context,
            state.message!.text(AppLocalizations.of(context)),
          );
          if (state.orderPlaced) {
            context.read<CartBloc>().add(const ClearCart());
            Navigator.of(context).pop();
          }
        },
      ),
    ],
    child: Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Text(
          _checkout
              ? AppLocalizations.of(context).checkout
              : AppLocalizations.of(context).cart,
          style: const TextStyle(
            fontFamily: AppTheme.sectionFont,
            fontSize: 26,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          tooltip: _checkout
              ? AppLocalizations.of(context).back
              : AppLocalizations.of(context).close,
          icon: Icon(
            Directionality.of(context) == TextDirection.rtl
                ? Icons.chevron_right
                : Icons.chevron_left,
            size: 32,
          ),
          onPressed: () => _checkout
              ? setState(() => _checkout = false)
              : Navigator.of(context).pop(),
        ),
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state.items.isEmpty) {
            return const _EmptyCart();
          }
          if (_checkout) {
            return CartCheckoutPanel(
              state,
              locationSource: widget.locationSource,
            );
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  itemCount: state.items.length,
                  itemBuilder: (context, index) =>
                      CartItemTile(state.items[index]),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context).total,
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          Text(
                            PriceFormatter.format(state.totalCents),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: SizedBox(
                              height: 48,
                              child: FilledButton(
                                onPressed: () =>
                                    setState(() => _checkout = true),
                                child: Text(
                                  AppLocalizations.of(context)
                                      .continueToCheckout,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: SizedBox(
                              height: 48,
                              child: OutlinedButton(
                                onPressed: () => context.read<CartBloc>().add(
                                  const EmptyCart(),
                                ),
                                child: Text(
                                  AppLocalizations.of(context).clearCart,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
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
        Text(AppLocalizations.of(context).emptyCart),
      ],
    ),
  );
}
