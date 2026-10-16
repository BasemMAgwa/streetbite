import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/meal_model.dart';
import 'meal_data_source.dart';

class MealLocalDataSource implements MealDataSource {
  const MealLocalDataSource(this._preferences);

  static const _cacheKey = 'streetbite_meals_v1';
  final SharedPreferencesAsync _preferences;

  @override
  Future<List<MealModel>> loadMeals() async {
    final saved = await _preferences.getString(_cacheKey);
    if (saved == null) return [];
    final values = jsonDecode(saved);
    if (values is! List) return [];
    return values
        .whereType<Map<String, dynamic>>()
        .map(MealModel.fromJson)
        .where((meal) => meal.id.isNotEmpty && meal.name.isNotEmpty)
        .toList();
  }

  Future<void> saveMeals(List<MealModel> meals) => _preferences.setString(
    _cacheKey,
    jsonEncode(meals.map((meal) => meal.toJson()).toList()),
  );
}
