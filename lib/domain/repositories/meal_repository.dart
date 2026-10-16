import '../entities/meal.dart';

abstract class MealRepository {
  Future<List<Meal>> getCachedMeals();
  Future<List<Meal>> refreshMeals();
}
