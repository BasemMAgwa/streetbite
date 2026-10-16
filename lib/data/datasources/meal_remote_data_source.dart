import 'package:dio/dio.dart';

import '../models/meal_model.dart';
import 'meal_data_source.dart';

class MealRemoteDataSource implements MealDataSource {
  const MealRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<List<MealModel>> loadMeals() async {
    final response = await _dio.get<Map<String, dynamic>>(
      'search.php',
      queryParameters: {'s': ''},
    );
    final rawMeals = response.data?['meals'];
    if (rawMeals is! List) throw const FormatException('Invalid meal response');
    final meals = rawMeals
        .whereType<Map<String, dynamic>>()
        .map(MealModel.fromJson)
        .where((meal) => meal.id.isNotEmpty && meal.name.isNotEmpty)
        .toList();
    if (meals.isEmpty) throw const FormatException('No meals returned');
    return meals;
  }
}
