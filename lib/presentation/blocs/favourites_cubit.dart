import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/message.dart';
import '../../domain/entities/favourites_failure.dart';
import '../../domain/entities/meal.dart';
import '../../domain/repositories/favourites_repository.dart';
import 'favourites_state.dart';

class FavouritesCubit extends Cubit<FavouritesState> {
  FavouritesCubit(this._repository, this._userId)
    : super(const FavouritesState());

  final FavouritesRepository _repository;
  final String _userId;
  StreamSubscription<List<Meal>>? _subscription;

  void load() {
    _subscription?.cancel();
    _subscription = _repository
        .watchFavourites(_userId)
        .listen(
          (meals) {
            if (!isClosed) {
              emit(
                FavouritesState(
                  meals: meals,
                  isLoading: false,
                  isSaving: state.isSaving,
                ),
              );
            }
          },
          onError: (Object error) {
            if (!isClosed) {
              emit(
                FavouritesState(
                  meals: state.meals,
                  isLoading: false,
                  message: _errorMessage(error),
                ),
              );
            }
          },
        );
  }

  Future<void> toggle(Meal meal) async {
    if (state.isLoading || state.isSaving) return;
    final wasSaved = state.contains(meal.id);
    emit(FavouritesState(meals: state.meals, isLoading: false, isSaving: true));
    try {
      if (wasSaved) {
        await _repository.removeFavourite(_userId, meal.id);
      } else {
        await _repository.addFavourite(_userId, meal);
      }
      if (isClosed) return;
      emit(
        FavouritesState(
          meals: state.meals,
          isLoading: false,
          message: wasSaved
              ? AppMessage.removedFromFavorites
              : AppMessage.addedToFavorites,
        ),
      );
    } catch (error) {
      if (isClosed) return;
      emit(
        FavouritesState(
          meals: state.meals,
          isLoading: false,
          message: _errorMessage(error),
        ),
      );
    }
  }

  AppMessage _errorMessage(Object error) {
    if (error is FavouritesFailure &&
        error.type == FavouritesFailureType.network) {
      return AppMessage.networkError;
    }
    return AppMessage.favoritesSaveError;
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await super.close();
  }
}
