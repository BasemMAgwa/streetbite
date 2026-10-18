import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/errors/network_error.dart';
import '../../domain/entities/favourites_failure.dart';
import '../../domain/entities/meal.dart';
import '../../domain/repositories/favourites_repository.dart';
import '../models/meal_model.dart';

class FavouritesRepositoryImpl implements FavouritesRepository {
  const FavouritesRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _user(String userId) =>
      _firestore.collection('Users').doc(userId);

  @override
  Stream<List<Meal>> watchFavourites(String userId) =>
      _user(userId)
          .snapshots()
          .map((snapshot) {
            final data = snapshot.data()?['favorites'];
            if (data is! Map) return <Meal>[];
            return data.values.whereType<Map>().map((value) {
              return MealModel.fromJson(Map<String, dynamic>.from(value));
            }).toList();
          })
          .handleError((Object error) => throw _failure(error));

  @override
  Future<void> addFavourite(String userId, Meal meal) async {
    try {
      await _user(userId).set({
        'id': userId,
        'favorites': {meal.id: MealModel.fromMeal(meal).toJson()},
      }, SetOptions(merge: true));
    } catch (error) {
      throw _failure(error);
    }
  }

  @override
  Future<void> removeFavourite(String userId, String mealId) async {
    try {
      await _user(userId).update({'favorites.$mealId': FieldValue.delete()});
    } catch (error) {
      throw _failure(error);
    }
  }

  FavouritesFailure _failure(Object error) {
    if (isNetworkError(error)) {
      return const FavouritesFailure(FavouritesFailureType.network);
    }
    return const FavouritesFailure(FavouritesFailureType.service);
  }
}
