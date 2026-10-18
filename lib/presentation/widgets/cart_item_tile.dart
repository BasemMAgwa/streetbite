import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_strings.dart';
import '../../core/formatting/price_formatter.dart';
import '../../core/theme/app_theme.dart';
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
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: AppTheme.cardColor(theme),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: AppTheme.cardBorder(theme),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 4, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 72,
                height: 72,
                child: MealImage(item.meal),
              ),
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
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    PriceFormatter.format(item.unitPriceCents),
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          PriceFormatter.format(item.totalCents),
                          style: const TextStyle(
                            color: AppTheme.green,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        tooltip: AppStrings.decreaseQuantity,
                        onPressed: () =>
                            cart.add(DecreaseMealQuantity(item.meal.id)),
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text(
                        '${item.quantity}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        tooltip: AppStrings.increaseQuantity,
                        onPressed: () => cart.add(AddMealToCart(item.meal)),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: AppStrings.removeFromCart,
              onPressed: () => cart.add(RemoveMealFromCart(item.meal.id)),
              icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
            ),
          ],
        ),
      ),
    );
  }
}
