import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../blocs/orders_cubit.dart';
import '../blocs/orders_state.dart';
import '../widgets/order_tile.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<OrdersCubit, OrdersState>(
    builder: (context, state) {
      Widget content;
      if (state.isLoading) {
        content = const Center(child: CircularProgressIndicator());
      } else if (state.message != null && state.orders.isEmpty) {
        content = Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(state.message!, textAlign: TextAlign.center),
              TextButton(
                onPressed: () => context.read<OrdersCubit>().load(),
                child: const Text(AppStrings.tryAgain),
              ),
            ],
          ),
        );
      } else if (state.orders.isEmpty) {
        content = const Center(child: Text(AppStrings.noOrders));
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
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 18, 20, 10),
            child: Text(
              AppStrings.orders,
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
