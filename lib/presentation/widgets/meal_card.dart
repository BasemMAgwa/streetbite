import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/meal.dart';
import '../screens/meal_details_screen.dart';
import 'cart_toggle_button.dart';
import 'meal_image.dart';

class MealCard extends StatelessWidget {
  const MealCard(this.meal, {super.key});

  final Meal meal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      elevation: 0,
      color: AppTheme.cardColor(theme),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: AppTheme.cardBorder(theme),
      ),
      child: InkWell(
        onTap: () => MealDetailsScreen.open(context, meal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: MealImage(meal)),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 9, 10, 0),
              child: Text(
                meal.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 2, 10, 0),
              child: Text(
                meal.category,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
              child: CartToggleButton(meal, compact: true),
            ),
          ],
        ),
      ),
    );
  }
}
