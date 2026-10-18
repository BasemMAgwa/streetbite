import '../../domain/entities/meal.dart';

class FavouritesState {
  const FavouritesState({
    this.meals = const [],
    this.isLoading = true,
    this.isSaving = false,
    this.message,
  });

  final List<Meal> meals;
  final bool isLoading;
  final bool isSaving;
  final String? message;

  int get count => meals.length;

  bool contains(String mealId) => meals.any((meal) => meal.id == mealId);
}
