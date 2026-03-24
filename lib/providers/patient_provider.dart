import 'package:flutter/foundation.dart';

import '../models/meal_entry.dart';
import '../models/water_entry.dart';
import '../models/message.dart';
import '../models/activity_entry.dart';
import '../models/mood_entry.dart';
import '../models/body_stats_entry.dart';
import '../models/badge.dart';
import '../models/food_item.dart';
import '../services/mock_data_service.dart';
import '../services/chat_service.dart';
import '../services/nutrition_service.dart';

/// Haftalık özet için
class DailyCalories {
  final DateTime date;
  final int calories;

  DailyCalories({
    required this.date,
    required this.calories,
  });
}

/// Günlük makro toplamları
class DailyMacros {
  final DateTime date;
  final double protein;
  final double carbs;
  final double fat;

  DailyMacros({
    required this.date,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}

class PatientProvider extends ChangeNotifier {
  final _mockService = MockDataService();
  final _chatService = ChatService();
  final _nutritionService = NutritionService();

  // === ÖĞÜNLER ===
  final List<MealEntry> _meals = [];

  // === SU ===
  List<WaterEntry> todayWater = [];

  // === AKTİVİTE, MOOD, VÜCUT, ROZET ===
  final List<ActivityEntry> _activities = [];
  final List<MoodEntry> _moods = [];
  final List<BodyStatsEntry> _bodyStats = [];
  final List<AppBadge> _badges = [];

  // === MESAJLAŞMA ===
  List<ChatMessage> conversation = [];
  String? dietitianId;

  // Günlük su hedefi (L)
  double _dailyWaterTargetL = 3.0;

  // Günlük kalori hedefi (kcal)
  double _dailyCalorieTarget = 1800;

  double get dailyWaterTargetL => _dailyWaterTargetL;
  double get dailyCalorieTarget => _dailyCalorieTarget;

  List<AppBadge> get badges => List.unmodifiable(_badges);

  /// Bugünkü toplam su (ml)
  double get todayWaterTotalMl =>
      todayWater.fold<double>(0, (sum, w) => sum + w.amountMl);

  /// Bugünkü toplam su (L)
  double get todayWaterTotalL => todayWaterTotalMl / 1000;

  void setDailyWaterTarget(double liters) {
    _dailyWaterTargetL = liters.clamp(0.5, 10.0);
    notifyListeners();
  }

  void setDailyCalorieTarget(double kcal) {
    _dailyCalorieTarget = kcal.clamp(800, 4000);
    notifyListeners();
  }

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // === ÖĞÜN ERİŞİMİ ===

  List<MealEntry> mealsForDate(DateTime date) {
    return _meals.where((m) => _isSameDate(m.date, date)).toList();
  }

  List<MealEntry> get todayMeals => mealsForDate(DateTime.now());

  int totalCaloriesForDate(DateTime date) {
    final meals = mealsForDate(date);
    return meals.fold<int>(0, (sum, m) => sum + (m.calories ?? 0));
  }

  DailyMacros macrosForDate(DateTime date) {
    final meals = mealsForDate(date);
    double p = 0, c = 0, f = 0;
    for (final m in meals) {
      p += m.protein ?? 0;
      c += m.carbs ?? 0;
      f += m.fat ?? 0;
    }
    return DailyMacros(date: date, protein: p, carbs: c, fat: f);
  }

  List<DailyCalories> lastDaysCalories({int days = 7}) {
    final List<DailyCalories> result = [];
    final today = DateTime.now();
    final baseToday = DateTime(today.year, today.month, today.day);

    for (int i = days - 1; i >= 0; i--) {
      final date = baseToday.subtract(Duration(days: i));
      final total = totalCaloriesForDate(date);
      result.add(DailyCalories(date: date, calories: total));
    }
    return result;
  }

  // === AKTİVİTE / MOOD / BODY ===

  List<ActivityEntry> activitiesForDate(DateTime date) {
    return _activities.where((a) => _isSameDate(a.date, date)).toList();
  }

  List<MoodEntry> moodsForDate(DateTime date) {
    return _moods.where((m) => _isSameDate(m.date, date)).toList();
  }

  BodyStatsEntry? bodyStatsForDate(DateTime date) {
    try {
      return _bodyStats.firstWhere((b) => _isSameDate(b.date, date));
    } catch (_) {
      return null;
    }
  }

  // === INTERNETTEN YEMEK ARAMA ===

  Future<FoodItem?> searchFood(String query) {
    return _nutritionService.searchFood(query);
  }

  // === LOAD MOCK DATA ===

void loadInitialData(String patientId, String dietitianId) {
  this.dietitianId = dietitianId;

  // Başlangıçta hiçbir öğün olmasın
  _meals.clear();

  // Su geçmişini sıfırla
  todayWater = [];

  // Mesajlaşmayı istersen mock bırakabilirsin
  conversation = _mockService.getMockMessages(
    patientId: patientId,
    dietitianId: dietitianId,
  );

  notifyListeners();
}

  // === SU ===

  void _addWater(double amountMl) {
    if (amountMl == 0) return;

    final newTotal = todayWaterTotalMl + amountMl;
    if (newTotal < 0) return;

    todayWater.add(
      WaterEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.now(),
        amountMl: amountMl,
      ),
    );
    _checkWaterBadges();
    notifyListeners();
  }

  void addWater250() => _addWater(250);
  void removeWater250() => _addWater(-250);
  void addWater() => addWater250();

  // === ÖĞÜN EKLEME & ROZET ===

  void addMeal(MealEntry entry) {
    _meals.add(entry);
    _checkCalorieBadges(entry.date);
    notifyListeners();
  }

  // === AKTİVİTE / MOOD / BODY EKLEME ===

  void addActivity(ActivityEntry entry) {
    _activities.add(entry);
    _checkActivityBadges(entry.date);
    notifyListeners();
  }

  void addMood(MoodEntry entry) {
    _moods.add(entry);
    notifyListeners();
  }

  void addBodyStats(BodyStatsEntry entry) {
    _bodyStats.add(entry);
    notifyListeners();
  }

  // === ROZETLER ===

  void _unlockBadgeOnce({
    required String type,
    required String title,
    required String description,
  }) {
    final exists = _badges.any((b) => b.type == type);
    if (exists) return;

    _badges.add(
      AppBadge(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
        type: type,
        unlockedAt: DateTime.now(),
      ),
    );
  }

  void _checkWaterBadges() {
    if (todayWaterTotalL >= dailyWaterTargetL) {
      _unlockBadgeOnce(
        type: 'water_target_once',
        title: 'Su Kahramanı',
        description: 'Günlük su hedefini tutturdun!',
      );
    }
  }

  void _checkCalorieBadges(DateTime date) {
    final total = totalCaloriesForDate(date);
    if (total <= dailyCalorieTarget + 100 &&
        total >= dailyCalorieTarget - 200) {
      _unlockBadgeOnce(
        type: 'calorie_target_day',
        title: 'Denge Ustası',
        description: 'Kalori hedefini tam isabet tutturdun!',
      );
    }

    final today = DateTime(date.year, date.month, date.day);
    bool streak3 = true;
    for (int i = 0; i < 3; i++) {
      final d = today.subtract(Duration(days: i));
      final t = totalCaloriesForDate(d);
      if (t == 0 ||
          t < dailyCalorieTarget - 300 ||
          t > dailyCalorieTarget + 300) {
        streak3 = false;
        break;
      }
    }
    if (streak3) {
      _unlockBadgeOnce(
        type: 'calorie_streak_3',
        title: 'Seri Başarı',
        description: '3 gün üst üste kalori hedefini yakaladın.',
      );
    }
  }

  void _checkActivityBadges(DateTime date) {
    final activities = activitiesForDate(date);
    final totalMinutes = activities.fold<int>(
      0,
      (sum, a) => sum + a.durationMinutes,
    );

    if (totalMinutes >= 30) {
      _unlockBadgeOnce(
        type: 'activity_30min',
        title: 'Aktif Gün',
        description: 'Bugün en az 30 dakika hareket ettin.',
      );
    }
  }

  // === MESAJ ===

  Future<void> sendMessageFromPatient({
    required String patientId,
    required String text,
  }) async {
    if (dietitianId == null) return;

    final msg = await _chatService.sendMessage(
      fromUserId: patientId,
      toUserId: dietitianId!,
      isFromDietitian: false,
      text: text,
    );

    conversation.add(msg);
    notifyListeners();
  }
}
