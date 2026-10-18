import '../entities/meal.dart';

abstract class FavouritesRepository {
  Stream<List<Meal>> watchFavourites(String userId);

  Future<void> addFavourite(String userId, Meal meal);

  Future<void> removeFavourite(String userId, String mealId);
}
