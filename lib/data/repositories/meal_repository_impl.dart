import 'package:dio/dio.dart';

import '../../domain/entities/meal.dart';
import '../../domain/entities/meal_failure.dart';
import '../../domain/repositories/meal_repository.dart';
import '../datasources/meal_data_source.dart';
import '../datasources/meal_local_data_source.dart';
import '../datasources/meal_remote_data_source.dart';

class MealRepositoryImpl implements MealRepository {
  const MealRepositoryImpl(this._remote, this._local);

  final MealRemoteDataSource _remote;
  final MealLocalDataSource _local;

  // Factory selection keeps the source choice in the repository.
  MealDataSource _sourceFor({required bool cached}) =>
      cached ? _local : _remote;

  @override
  Future<List<Meal>> getCachedMeals() async {
    try {
      return await _sourceFor(cached: true).loadMeals();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<Meal>> refreshMeals() async {
    try {
      final meals = await _sourceFor(cached: false).loadMeals();
      try {
        await _local.saveMeals(meals);
      } catch (_) {
        // Fresh meals stay available even if local storage is unavailable.
      }
      return meals;
    } on DioException catch (error) {
      final network = switch (error.type) {
        DioExceptionType.connectionError ||
        DioExceptionType.connectionTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.sendTimeout => true,
        _ => false,
      };
      throw MealFailure(
        network ? MealFailureType.network : MealFailureType.service,
      );
    } catch (_) {
      throw const MealFailure(MealFailureType.service);
    }
  }
}
