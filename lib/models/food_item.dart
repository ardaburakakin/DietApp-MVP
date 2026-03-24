class FoodItem {
  final String id;
  final String name;

  /// 100 gramdaki enerji (kcal)
  final double caloriesPer100g;

  /// 100 gramdaki makrolar (gram)
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;

  const FoodItem({
    required this.id,
    required this.name,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
  });
}
