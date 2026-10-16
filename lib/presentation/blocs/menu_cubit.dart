import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_strings.dart';
import '../../domain/entities/meal.dart';
import '../../domain/entities/meal_failure.dart';
import '../../domain/repositories/meal_repository.dart';
import 'menu_state.dart';

class MenuCubit extends Cubit<MenuState> {
  MenuCubit(this._repository) : super(const MenuState());

  final MealRepository _repository;

  Future<void> loadMeals() async {
    if (state.isRefreshing) return;
    List<Meal> cached = [];
    try {
      cached = await _repository.getCachedMeals();
    } catch (_) {
      // A broken cache should not prevent the live menu from loading.
    }
    if (isClosed) return;
    emit(
      MenuState(
        status: cached.isEmpty ? MenuStatus.loading : MenuStatus.ready,
        meals: cached,
        isCached: cached.isNotEmpty,
        isRefreshing: true,
      ),
    );
    try {
      final fresh = await _repository.refreshMeals();
      if (isClosed) return;
      emit(MenuState(status: MenuStatus.ready, meals: fresh));
    } on MealFailure catch (failure) {
      if (isClosed) return;
      emit(
        MenuState(
          status: cached.isEmpty ? MenuStatus.error : MenuStatus.ready,
          meals: cached,
          isCached: cached.isNotEmpty,
          message: failure.type == MealFailureType.network
              ? AppStrings.networkError
              : AppStrings.menuUnavailable,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        MenuState(
          status: cached.isEmpty ? MenuStatus.error : MenuStatus.ready,
          meals: cached,
          isCached: cached.isNotEmpty,
          message: AppStrings.menuUnavailable,
        ),
      );
    }
  }
}
