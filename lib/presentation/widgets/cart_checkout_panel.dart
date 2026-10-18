import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_strings.dart';
import '../../core/formatting/price_formatter.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/payment_type.dart';
import '../blocs/cart_state.dart';
import '../blocs/checkout_cubit.dart';
import '../blocs/checkout_state.dart';

class CartCheckoutPanel extends StatelessWidget {
  const CartCheckoutPanel(this.cart, {super.key});

  final CartState cart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final checkout = context.read<CheckoutCubit>();
    return BlocBuilder<CheckoutCubit, CheckoutState>(
      builder: (context, state) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppStrings.paymentMethod,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<PaymentType>(
                showSelectedIcon: false,
                segments: [
                  for (final type in checkout.paymentTypes)
                    ButtonSegment(
                      value: type,
                      icon: Icon(_icon(type)),
                      label: Text(_label(type)),
                    ),
                ],
                selected: {state.payment},
                onSelectionChanged: state.isPlacing
                    ? null
                    : (selection) => checkout.selectPayment(selection.first),
              ),
              if (state.payment == PaymentType.card) ...[
                const SizedBox(height: 6),
                Text(
                  AppStrings.cardDemoNote,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      AppStrings.total,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  Text(
                    PriceFormatter.format(cart.totalCents),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontFamily: AppTheme.sectionFont,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: state.isPlacing
                      ? null
                      : () => checkout.placeOrder(cart.items),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.green,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                  ),
                  child: state.isPlacing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          AppStrings.placeOrder,
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _icon(PaymentType type) => switch (type) {
    PaymentType.cash => Icons.payments_outlined,
    PaymentType.card => Icons.credit_card,
  };

  String _label(PaymentType type) => switch (type) {
    PaymentType.cash => AppStrings.cashPayment,
    PaymentType.card => AppStrings.cardPayment,
  };
}
