class Meal {
  const Meal({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.area,
    required this.instructions,
  });

  final String id;
  final String name;
  final String category;
  final String imageUrl;
  final String area;
  final String instructions;

  // TheMealDB has no prices, so each meal gets a stable demo price
  // (4.99 to 11.99) derived from its id.
  int get _demoSeed =>
      int.tryParse(id) ?? id.codeUnits.fold<int>(0, (sum, c) => sum + c);

  int get priceCents => 499 + _demoSeed % 8 * 100;

  // TheMealDB also has no ratings. Keep the demo value stable for each meal.
  double get rating => 4.0 + _demoSeed % 10 / 10;
}
