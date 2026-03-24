import '../models/meal_entry.dart';
import '../models/water_entry.dart';
import '../models/message.dart';

class MockDataService {
  List<MealEntry> getTodayMeals() {
    final now = DateTime.now();
    return [
      MealEntry(
        id: '1',
        date: now,
        mealType: 'Kahvaltı',
        description: 'Yulaf + süt + muz',
        calories: 350,
      ),
      MealEntry(
        id: '2',
        date: now,
        mealType: 'Öğle',
        description: 'Izgara tavuk + salata',
        calories: 480,
      ),
    ];
  }

  List<WaterEntry> getTodayWater() {
    final now = DateTime.now();
    return List.generate(
      5,
      (i) => WaterEntry(
        id: '$i',
        date: now,
        amountMl: 250,
      ),
    );
  }

  List<ChatMessage> getMockMessages({
    required String patientId,
    required String dietitianId,
  }) {
    final now = DateTime.now();
    return [
      ChatMessage(
        id: 'm1',
        fromUserId: dietitianId,
        toUserId: patientId,
        text: 'Merhaba, bugün öğünlerini girmeyi unutma 😊',
        timestamp: now.subtract(const Duration(hours: 3)),
        isFromDietitian: true,
      ),
      ChatMessage(
        id: 'm2',
        fromUserId: patientId,
        toUserId: dietitianId,
        text: 'Tamam hocam, teşekkürler.',
        timestamp: now.subtract(const Duration(hours: 2, minutes: 10)),
        isFromDietitian: false,
      ),
    ];
  }
}
