import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/meal.dart';
import '../screens/meal_details_screen.dart';
import 'cart_toggle_button.dart';
import 'meal_image.dart';

class FavouriteMealTile extends StatelessWidget {
  const FavouriteMealTile(this.meal, {super.key, required this.onRemove});

  final Meal meal;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.cardColor(theme),
        borderRadius: BorderRadius.circular(14),
        border: Border.fromBorderSide(AppTheme.cardBorder(theme)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => MealDetailsScreen.open(context, meal),
                borderRadius: BorderRadius.circular(10),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 64,
                        height: 64,
                        child: MealImage(meal),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meal.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            meal.category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            CartToggleIconButton(meal),
            IconButton(
              tooltip: AppStrings.removeFromFavorites,
              onPressed: onRemove,
              icon: Icon(
                Icons.favorite,
                color: theme.brightness == Brightness.dark
                    ? AppTheme.green
                    : AppTheme.badgeGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
