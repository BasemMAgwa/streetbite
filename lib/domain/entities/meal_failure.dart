enum MealFailureType { network, service }

class MealFailure implements Exception {
  const MealFailure(this.type);

  final MealFailureType type;
}
