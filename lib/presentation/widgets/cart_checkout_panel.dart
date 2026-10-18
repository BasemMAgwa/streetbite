import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_strings.dart';
import '../../core/formatting/price_formatter.dart';
import '../../core/theme/app_theme.dart';
import '../../data/datasources/device_location_source.dart';
import '../../domain/entities/order_pricing.dart';
import '../../domain/entities/payment_type.dart';
import '../blocs/cart_state.dart';
import '../blocs/checkout_cubit.dart';
import '../blocs/checkout_state.dart';
import 'checkout_location_map.dart';

class CartCheckoutPanel extends StatelessWidget {
  const CartCheckoutPanel(
    this.cart, {
    super.key,
    this.locationSource = const DeviceLocationSource(),
  });

  final CartState cart;
  final DeviceLocationSource locationSource;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final checkout = context.read<CheckoutCubit>();
    return BlocBuilder<CheckoutCubit, CheckoutState>(
      builder: (context, state) => Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              children: [
                CheckoutLocationMap(locationSource: locationSource),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 19),
                    SizedBox(width: 6),
                    Text(AppStrings.currentLocation),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  AppStrings.paymentMethod,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    for (final type in checkout.paymentTypes) ...[
                      if (type != checkout.paymentTypes.first)
                        const SizedBox(width: 10),
                      Expanded(
                        child: _PaymentOption(
                          type: type,
                          selected: state.payment == type,
                          onTap: state.isPlacing
                              ? null
                              : () => checkout.selectPayment(type),
                        ),
                      ),
                    ],
                  ],
                ),
                if (state.payment == PaymentType.card) ...[
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.cardPaymentNote,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Text(
                  AppStrings.orderSummary,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                _SummaryRow(
                  AppStrings.orderAmount,
                  PriceFormatter.format(cart.totalCents),
                ),
                const SizedBox(height: 12),
                _SummaryRow(
                  AppStrings.deliveryFee,
                  PriceFormatter.format(OrderPricing.deliveryFeeCents),
                ),
                const SizedBox(height: 12),
                _SummaryRow(
                  AppStrings.taxesFee,
                  PriceFormatter.format(OrderPricing.taxesFeeCents),
                ),
                const Divider(height: 24),
                _SummaryRow(
                  AppStrings.total,
                  PriceFormatter.format(cart.checkoutTotalCents),
                  bold: true,
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: state.isPlacing || cart.items.isEmpty
                      ? null
                      : () => checkout.placeOrder(cart.items),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.green,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                  ),
                  child: state.isPlacing
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          AppStrings.placeOrder,
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({
    required this.type,
    required this.selected,
    this.onTap,
  });

  final PaymentType type;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isCash = type == PaymentType.cash;
    final title = isCash ? AppStrings.cashPayment : AppStrings.cardPayment;
    return Semantics(
      button: true,
      selected: selected,
      label: title,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 112,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: selected
                  ? colors.primaryContainer.withValues(alpha: 0.35)
                  : colors.surfaceContainerLow,
              border: Border.all(
                color: selected ? AppTheme.green : colors.outlineVariant,
                width: selected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      isCash
                          ? Icons.payments_outlined
                          : Icons.credit_card_outlined,
                      color: selected
                          ? AppTheme.green
                          : colors.onSurfaceVariant,
                      size: 27,
                    ),
                    Icon(
                      selected
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      size: 21,
                      color: selected ? AppTheme.green : colors.outline,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isCash
                          ? AppStrings.cashPaymentSubtitle
                          : AppStrings.cardPaymentSubtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.amount, {this.bold = false});

  final String label;
  final String amount;
  final bool bold;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          label,
          style: bold
              ? const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)
              : null,
        ),
      ),
      Text(
        amount,
        style: bold
            ? const TextStyle(
                fontFamily: AppTheme.sectionFont,
                fontWeight: FontWeight.w700,
                fontSize: 19,
              )
            : null,
      ),
    ],
  );
}
