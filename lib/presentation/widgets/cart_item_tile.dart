import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_strings.dart';
import '../../core/formatting/price_formatter.dart';
import '../../domain/entities/cart_item.dart';
import '../blocs/cart_bloc.dart';
import '../blocs/cart_event.dart';
import 'meal_image.dart';

class CartItemTile extends StatelessWidget {
  const CartItemTile(this.item, {super.key});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cart = context.read<CartBloc>();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(width: 66, height: 66, child: MealImage(item.meal)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.meal.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  PriceFormatter.format(item.unitPriceCents),
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: AppStrings.decreaseQuantity,
                  onPressed: () => cart.add(DecreaseMealQuantity(item.meal.id)),
                  icon: Icon(
                    Icons.remove,
                    size: 19,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text('${item.quantity}'),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: AppStrings.increaseQuantity,
                  onPressed: () => cart.add(AddMealToCart(item.meal)),
                  icon: Icon(
                    Icons.add,
                    size: 19,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: AppStrings.removeFromCart,
            onPressed: () => cart.add(RemoveMealFromCart(item.meal.id)),
            icon: Icon(
              Icons.delete_outline,
              size: 20,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
