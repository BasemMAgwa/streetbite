import '../../core/constants/message.dart';
import '../../domain/entities/meal.dart';

enum MenuStatus { loading, ready, error }

class MenuState {
  const MenuState({
    this.status = MenuStatus.loading,
    this.meals = const [],
    this.isRefreshing = false,
    this.isCached = false,
    this.message,
  });

  final MenuStatus status;
  final List<Meal> meals;
  final bool isRefreshing;
  final bool isCached;
  final AppMessage? message;
}
