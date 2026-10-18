import '../../domain/entities/meal.dart';

class MealModel extends Meal {
  const MealModel({
    required super.id,
    required super.name,
    required super.category,
    required super.imageUrl,
    required super.area,
    required super.instructions,
  });

  factory MealModel.fromMeal(Meal meal) => MealModel(
    id: meal.id,
    name: meal.name,
    category: meal.category,
    imageUrl: meal.imageUrl,
    area: meal.area,
    instructions: meal.instructions,
  );

  factory MealModel.fromJson(Map<String, dynamic> json) {
    return MealModel(
      id: json['idMeal'] as String? ?? '',
      name: json['strMeal'] as String? ?? '',
      category: json['strCategory'] as String? ?? '',
      imageUrl: json['strMealThumb'] as String? ?? '',
      area: _area(json),
      instructions: json['strInstructions'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'idMeal': id,
    'strMeal': name,
    'strCategory': category,
    'strMealThumb': imageUrl,
    'strArea': area,
    'strInstructions': instructions,
  };

  static String _area(Map<String, dynamic> json) {
    final area = (json['strArea'] as String? ?? '').trim();
    if (area.isNotEmpty) return area;

    // These TheMealDB records have no strArea; their recipe sources identify
    // the country. Keep unknown records blank rather than guessing an origin.
    return const {
          '53436': 'Armenian',
          '53443': 'Aruban',
          '53450': 'Bahamian',
          '53439': 'Aruban',
          '53399': 'Afghan',
          '53470': 'Botswanan',
        }[json['idMeal']] ??
        '';
  }
}
