import '../models/food_item.dart';

class NutritionService {
  /// Şimdilik sadece mock üzerinden çalışıyoruz.
  /// İleride gerçek API bağlayınca HTTP isteğini burada yaparsın.
  Future<FoodItem?> searchFood(String query) async {
    final mock = _mockFoodFromQuery(query);
    return mock; // mock yoksa null döner
  }

  /// Backend olmadan da deneme yapabilmek için basit eşleştirme
  FoodItem? _mockFoodFromQuery(String query) {
    final q = query.toLowerCase();

    if (q.contains('yulaf')) {
      return const FoodItem(
        id: 'oat_mock',
        name: 'Yulaf',
        caloriesPer100g: 389,
        proteinPer100g: 17,
        carbsPer100g: 66,
        fatPer100g: 7,
      );
    }
    if (q.contains('muz')) {
      return const FoodItem(
        id: 'banana_mock',
        name: 'Muz',
        caloriesPer100g: 89,
        proteinPer100g: 1.1,
        carbsPer100g: 23,
        fatPer100g: 0.3,
      );
    }
    if (q.contains('tavuk')) {
      return const FoodItem(
        id: 'chicken_mock',
        name: 'Izgara tavuk',
        caloriesPer100g: 165,
        proteinPer100g: 31,
        carbsPer100g: 0,
        fatPer100g: 3.6,
      );
    }

    // eşleşme yoksa null
    return null;
  }
}
