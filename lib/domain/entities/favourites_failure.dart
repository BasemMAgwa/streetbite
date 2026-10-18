enum FavouritesFailureType { network, service }

class FavouritesFailure implements Exception {
  const FavouritesFailure(this.type);

  final FavouritesFailureType type;
}
