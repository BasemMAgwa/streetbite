import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/meal.dart';
import '../blocs/cart_bloc.dart';
import '../blocs/cart_event.dart';
import '../blocs/cart_state.dart';

void _toggleCartMeal(BuildContext context, Meal meal, bool isInCart) {
  context.read<CartBloc>().add(
    isInCart ? RemoveMealFromCart(meal.id) : AddMealToCart(meal),
  );
}

class CartToggleButton extends StatelessWidget {
  const CartToggleButton(this.meal, {super.key, this.compact = false});

  final Meal meal;
  final bool compact;

  @override
  Widget build(BuildContext context) => BlocBuilder<CartBloc, CartState>(
    builder: (context, state) {
      final isInCart = state.containsMeal(meal.id);
      final theme = Theme.of(context);
      final foreground = isInCart
          ? theme.colorScheme.error
          : theme.brightness == Brightness.dark
          ? AppTheme.green
          : const Color(0xFF007D49);
      return FilledButton.icon(
        onPressed: () => _toggleCartMeal(context, meal, isInCart),
        icon: Icon(
          isInCart
              ? Icons.remove_shopping_cart_outlined
              : Icons.add_shopping_cart_outlined,
          size: compact ? 18 : 22,
        ),
        label: Text(
          isInCart ? AppStrings.removeFromCart : AppStrings.addToCart,
          maxLines: 1,
        ),
        style: FilledButton.styleFrom(
          backgroundColor: compact
              ? foreground.withValues(alpha: 0.18)
              : isInCart
              ? theme.colorScheme.errorContainer
              : null,
          foregroundColor: compact || isInCart ? foreground : null,
          minimumSize: compact ? const Size.fromHeight(34) : null,
          padding: compact ? const EdgeInsets.symmetric(horizontal: 6) : null,
          visualDensity: compact ? VisualDensity.compact : null,
          textStyle: compact
              ? const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)
              : null,
        ),
      );
    },
  );
}

class CartToggleIconButton extends StatelessWidget {
  const CartToggleIconButton(this.meal, {super.key});

  final Meal meal;

  @override
  Widget build(BuildContext context) => BlocBuilder<CartBloc, CartState>(
    builder: (context, state) {
      final isInCart = state.containsMeal(meal.id);
      return IconButton(
        visualDensity: VisualDensity.compact,
        iconSize: 18,
        tooltip: isInCart ? AppStrings.removeFromCart : AppStrings.addToCart,
        onPressed: () => _toggleCartMeal(context, meal, isInCart),
        icon: Icon(
          isInCart
              ? Icons.remove_shopping_cart_outlined
              : Icons.add_shopping_cart_outlined,
        ),
      );
    },
  );
}
