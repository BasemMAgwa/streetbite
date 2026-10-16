import '../models/meal_model.dart';

abstract class MealDataSource {
  Future<List<MealModel>> loadMeals();
}
