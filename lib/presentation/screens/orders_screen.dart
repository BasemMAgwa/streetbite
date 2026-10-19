import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../blocs/orders_cubit.dart';
import '../blocs/orders_state.dart';
import '../widgets/order_tile.dart';
import '../l10n/message_localizations.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<OrdersCubit, OrdersState>(
    builder: (context, state) {
      Widget content;
      if (state.isLoading) {
        content = Center(child: CircularProgressIndicator());
      } else if (state.message != null && state.orders.isEmpty) {
        content = Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.message!.text(AppLocalizations.of(context)),
                textAlign: TextAlign.center,
              ),
              TextButton(
                onPressed: () => context.read<OrdersCubit>().load(),
                child: Text(AppLocalizations.of(context).tryAgain),
              ),
            ],
          ),
        );
      } else if (state.orders.isEmpty) {
        content = Center(child: Text(AppLocalizations.of(context).noOrders));
      } else {
        content = ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          itemCount: state.orders.length,
          itemBuilder: (context, index) => OrderTile(state.orders[index]),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 18, 20, 10),
            child: Text(
              AppLocalizations.of(context).orders,
              style: TextStyle(
                fontFamily: AppTheme.sectionFont,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(child: content),
        ],
      );
    },
  );
}
