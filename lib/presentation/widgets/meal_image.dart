import 'package:flutter/material.dart';

import '../../domain/entities/meal.dart';

class MealImage extends StatelessWidget {
  const MealImage(this.meal, {super.key, this.fit = BoxFit.cover});

  final Meal meal;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final fallback = ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Center(child: Icon(Icons.restaurant, size: 36)),
    );
    if (meal.imageUrl.isEmpty) return fallback;
    return Image.network(
      meal.imageUrl,
      fit: fit,
      width: double.infinity,
      errorBuilder: (context, error, stackTrace) => fallback,
    );
  }
}
