import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/meal.dart';
import '../screens/meal_details_screen.dart';
import 'cart_toggle_button.dart';
import 'meal_image.dart';

class HotOffers extends StatelessWidget {
  const HotOffers(this.meals, {super.key, required this.horizontalPadding});

  final List<Meal> meals;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final offers = meals.skip(4).take(5).toList();
    final theme = Theme.of(context);
    return SizedBox(
      height: 156,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        scrollDirection: Axis.horizontal,
        itemCount: offers.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final meal = offers[index];
          return SizedBox(
            width: 134,
            child: Card(
              clipBehavior: Clip.antiAlias,
              margin: EdgeInsets.zero,
              elevation: 0,
              color: AppTheme.cardColor(theme),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: AppTheme.cardBorder(theme),
              ),
              child: InkWell(
                onTap: () => MealDetailsScreen.open(context, meal),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          MealImage(meal),
                          Positioned(
                            top: 8,
                            left: 8,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: const Color(0xFFE85D24),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 4,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.local_fire_department,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 2),
                                    Text(
                                      AppStrings.hotFlag,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 5, 4, 2),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              meal.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          CartToggleIconButton(meal),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
