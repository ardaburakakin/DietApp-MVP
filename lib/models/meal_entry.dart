class MealEntry {
  final String id;
  final DateTime date;
  final String mealType; // Kahvaltı / Öğle / Akşam / Ara öğün vs.
  final String description;
  final int? calories;

  // Makrolar (opsiyonel, istersen doldurursun)
  final double? protein; // gram
  final double? carbs;   // gram
  final double? fat;     // gram

  MealEntry({
    required this.id,
    required this.date,
    required this.mealType,
    required this.description,
    this.calories,
    this.protein,
    this.carbs,
    this.fat,
  });
}
