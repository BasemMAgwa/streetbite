import 'package:flutter/material.dart';

import '../../domain/entities/meal.dart';
import 'meal_card.dart';

class MenuGrid extends StatelessWidget {
  const MenuGrid(this.meals, {super.key});

  final List<Meal> meals;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: meals.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: width < 360 ? 228 : 244,
      ),
      itemBuilder: (context, index) => MealCard(meals[index]),
    );
  }
}
