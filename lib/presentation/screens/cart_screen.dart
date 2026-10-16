import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_strings.dart';
import '../blocs/cart_bloc.dart';
import '../blocs/cart_state.dart';
import '../widgets/meal_image.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text(AppStrings.cart)),
    body: BlocBuilder<CartBloc, CartState>(
      builder: (context, state) => state.items.isEmpty
          ? const Center(child: Text(AppStrings.emptyCart))
          : ListView.builder(
              itemCount: state.items.length,
              itemBuilder: (context, index) {
                final meal = state.items[index];
                return ListTile(
                  leading: SizedBox(
                    width: 54,
                    height: 54,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: MealImage(meal),
                    ),
                  ),
                  title: Text(meal.name),
                  subtitle: Text(meal.category),
                );
              },
            ),
    ),
  );
}
