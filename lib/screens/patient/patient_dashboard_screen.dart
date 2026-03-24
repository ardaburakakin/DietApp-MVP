import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/patient_provider.dart';
import 'meal_log_screen.dart';
import 'water_tracker_screen.dart';
import 'chat_with_dietitian_screen.dart';

class PatientDashboardScreen extends StatefulWidget {
  const PatientDashboardScreen({super.key});

  @override
  State<PatientDashboardScreen> createState() =>
      _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  int _index = 0;
  bool _initialized = false;

  // 🔟 Basit “dark mode” sadece bu ekranda
  bool _isDarkMode = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final patient = Provider.of<PatientProvider>(context, listen: false);
      if (auth.currentUser != null) {
        patient.loadInitialData(auth.currentUser!.id, 'dietitian_demo');
      }
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    final pages = [
      _buildOverview(), // GENEL – gelişmiş dashboard
      const MealLogScreen(),
      const WaterTrackerScreen(),
      const ChatWithDietitianScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor:
            _isDarkMode ? const Color(0xFF020617) : const Color(0xFFF7FFF8),
        foregroundColor: _isDarkMode ? Colors.white : Colors.black,
        title: Text('Merhaba, ${auth.currentUser?.name ?? ''}'),
        actions: [
          // 🔟 Dark / Light toggle ikonu
          IconButton(
            tooltip: _isDarkMode ? 'Açık moda geç' : 'Karanlık moda geç',
            onPressed: () {
              setState(() {
                _isDarkMode = !_isDarkMode;
              });
            },
            icon: Icon(
              _isDarkMode
                  ? Icons.wb_sunny_outlined
                  : Icons.dark_mode_outlined,
            ),
          ),
          IconButton(
            onPressed: () {
              auth.logout();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) {
          setState(() {
            _index = i;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Genel'),
          NavigationDestination(icon: Icon(Icons.restaurant), label: 'Öğünler'),
          NavigationDestination(icon: Icon(Icons.water_drop), label: 'Su'),
          NavigationDestination(icon: Icon(Icons.chat), label: 'Mesaj'),
        ],
      ),
    );
  }

  // ===========================
  //         GENEL SAYFA
  // ===========================

  Widget _buildOverview() {
    return Consumer<PatientProvider>(
      builder: (context, patient, _) {
        final today = DateTime.now();
        final todayMeals = patient.mealsForDate(today);
        final totalCalories = patient.totalCaloriesForDate(today);
        final macros = patient.macrosForDate(today);
        final dailyTarget = patient.dailyCalorieTarget;

        final waterL = patient.todayWaterTotalL;
        final waterTarget = patient.dailyWaterTargetL;

        final activities = patient.activitiesForDate(today);
        final activeMinutes = activities.fold<int>(
          0,
          (sum, a) => sum + a.durationMinutes,
        );
        const activityTargetMinutes = 30;

        final weeklyCalories = patient.lastDaysCalories(days: 7);
        final badges = patient.badges;
        final lastBadge = badges.isNotEmpty ? badges.last : null;

        final calorieProgress =
            dailyTarget <= 0 ? 0.0 : (totalCalories / dailyTarget).clamp(0.0, 2.0);
        final waterProgress =
            waterTarget <= 0 ? 0.0 : (waterL / waterTarget).clamp(0.0, 2.0);
        final activityProgress =
            (activeMinutes / activityTargetMinutes).clamp(0.0, 2.0);

        // 1️⃣ Öğün “streak”i – son 7 günde aralıksız kaç gün öğün kaydı var
        int mealStreak = 0;
        for (int i = weeklyCalories.length - 1; i >= 0; i--) {
          if (weeklyCalories[i].calories > 0) {
            mealStreak++;
          } else {
            break;
          }
        }

        // Günlük görevler
        final goalCalories = totalCalories >= dailyTarget * 0.9 &&
            totalCalories <= dailyTarget * 1.1;
        final goalWater = waterL >= waterTarget;
        final goalMeals = todayMeals.length >= 3;
        final goalActivity = activeMinutes >= activityTargetMinutes;

        // Basit koç önerisi
        String coachText;
        if (totalCalories == 0 && todayMeals.isEmpty) {
          coachText =
              'Bugün henüz öğün eklemedin. Kahvaltıdan başlamak için “Bu güne öğün ekle” butonunu kullanabilirsin.';
        } else if (totalCalories > dailyTarget * 1.15) {
          coachText =
              'Bugün kalori hedefinin üzerindesin. Akşam öğününü biraz daha hafif planlamak iyi olabilir.';
        } else if (totalCalories < dailyTarget * 0.7) {
          coachText =
              'Kalori hedefinin biraz altındasın. Ara öğüne protein ağırlıklı küçük bir ekleme yapabilirsin.';
        } else {
          coachText =
              'Kalori açısından gayet dengeli gidiyorsun. Su tüketimini de ihmal etme, hedefin $waterTarget L.';
        }

        final bgGradient = _isDarkMode
            ? const [Color(0xFF020617), Color(0xFF020617)]
            : const [Color(0xFFF7FFF8), Color(0xFFE6FFF0)];

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: bgGradient,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                // Başlık
                Text(
                  'Genel Bakış',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Bugünkü durumun, hedeflerin ve trendlerin',
                  style: TextStyle(
                    fontSize: 13,
                    color: _isDarkMode ? Colors.white70 : Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),

                // GÜNLÜK SNAPSHOT
                _DailySnapshotCard(
                  totalCalories: totalCalories,
                  calorieTarget: dailyTarget,
                  calorieProgress: calorieProgress,
                  waterL: waterL,
                  waterTarget: waterTarget,
                  waterProgress: waterProgress,
                  activeMinutes: activeMinutes,
                  activityTarget: activityTargetMinutes,
                  activityProgress: activityProgress,
                ),
                const SizedBox(height: 16),

                // 1️⃣ STREAK KARTI
                _StreakCard(mealStreak: mealStreak),
                const SizedBox(height: 16),

                // ROZET (varsa)
                if (lastBadge != null) ...[
                  _BadgeHighlightCard(
                    badgeTitle: lastBadge.title,
                    badgeDesc: lastBadge.description,
                  ),
                  const SizedBox(height: 16),
                ],

                // HAFTALIK ÖZET
                _WeeklyCaloriesCard(
                  data: weeklyCalories,
                  target: dailyTarget,
                ),
                const SizedBox(height: 16),

                // GÜNLÜK GÖREVLER
                _DailyGoalsCard(
                  goalCalories: goalCalories,
                  goalWater: goalWater,
                  goalMeals: goalMeals,
                  goalActivity: goalActivity,
                ),
                const SizedBox(height: 16),

                // MAKRO ÖZET
                _MacroOverviewCard(macros: macros),
                const SizedBox(height: 16),

                // KOÇ ÖNERİSİ
                _CoachTipCard(text: coachText),
                const SizedBox(height: 16),

                // HIZLI AKSİYONLAR
                _QuickActionsRow(
                  onGoMeals: () {
                    setState(() => _index = 1);
                  },
                  onGoWater: () {
                    setState(() => _index = 2);
                  },
                  onGoMessages: () {
                    setState(() => _index = 3);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ===========================
//   ALT WIDGET'LAR
// ===========================

class _DailySnapshotCard extends StatelessWidget {
  final int totalCalories;
  final double calorieTarget;
  final double calorieProgress;

  final double waterL;
  final double waterTarget;
  final double waterProgress;

  final int activeMinutes;
  final int activityTarget;
  final double activityProgress;

  const _DailySnapshotCard({
    required this.totalCalories,
    required this.calorieTarget,
    required this.calorieProgress,
    required this.waterL,
    required this.waterTarget,
    required this.waterProgress,
    required this.activeMinutes,
    required this.activityTarget,
    required this.activityProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9EF4C2), Color(0xFF6FE7A9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            offset: const Offset(0, 10),
            color: Colors.black.withValues(alpha: 0.12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bugünkü özet',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SnapshotItem(
                  icon: Icons.local_fire_department_rounded,
                  label: 'Kalori',
                  value: '$totalCalories / ${calorieTarget.toInt()} kcal',
                  progress: calorieProgress,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SnapshotItem(
                  icon: Icons.water_drop_rounded,
                  label: 'Su',
                  value:
                      '${waterL.toStringAsFixed(2)} / ${waterTarget.toStringAsFixed(1)} L',
                  progress: waterProgress,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SnapshotItem(
                  icon: Icons.directions_walk_rounded,
                  label: 'Aktivite',
                  value: '$activeMinutes / $activityTarget dk',
                  progress: activityProgress,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SnapshotItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final double progress;

  const _SnapshotItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: LinearProgressIndicator(
            value: clamped,
            minHeight: 6,
            backgroundColor: Colors.white.withValues(alpha: 0.25),
            valueColor:
                const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        const SizedBox(height: 2),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${(clamped * 100).toInt()}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }
}

// 1️⃣ STREAK KARTI
class _StreakCard extends StatelessWidget {
  final int mealStreak;

  const _StreakCard({required this.mealStreak});

  @override
  Widget build(BuildContext context) {
    final bool hasStreak = mealStreak > 0;
    final title =
        hasStreak ? 'Seri yakaladın!' : 'Bugün yeni bir başlangıç';
    final subtitle = hasStreak
        ? '$mealStreak gündür üst üste öğün kaydediyorsun. Böyle devam!'
        : 'Üst üste günlerce kayıt tutmak hedeflerine daha hızlı ulaşmanı sağlar.';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFC8E2), Color(0xFFFF9FB3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            offset: const Offset(0, 6),
            color: Colors.black.withValues(alpha: 0.10),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_fire_department_rounded,
            color: Colors.white,
            size: 30,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyCaloriesCard extends StatelessWidget {
  final List<DailyCalories> data;
  final double target;

  const _WeeklyCaloriesCard({
    required this.data,
    required this.target,
  });

  String _shortLabel(DateTime date) {
    const days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    return days[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              blurRadius: 16,
              offset: const Offset(0, 6),
              color: Colors.black.withValues(alpha: 0.06),
            ),
          ],
        ),
        child: const Text(
          'Haftalık özet için henüz veri yok. Öğün eklemeye başladığında burada son 7 günü göreceksin.',
          style: TextStyle(fontSize: 13),
        ),
      );
    }

    final maxCalories = [
      ...data.map((e) => e.calories.toDouble()),
      target,
    ].reduce((a, b) => a > b ? a : b);

    final avgCalories =
        data.fold<double>(0, (sum, e) => sum + e.calories) / data.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            offset: const Offset(0, 6),
            color: Colors.black.withValues(alpha: 0.06),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Haftalık kalori özeti',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Hedef: ${target.toInt()} kcal / gün · Ortalama: ${avgCalories.toStringAsFixed(0)} kcal',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          for (final d in data) ...[
            Row(
              children: [
                SizedBox(
                  width: 32,
                  child: Text(
                    _shortLabel(d.date),
                    style:
                        const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: LinearProgressIndicator(
                      value: maxCalories == 0
                          ? 0
                          : (d.calories / maxCalories).clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor:
                          Colors.grey.withValues(alpha: 0.12),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF33A46F),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  d.calories.toString(),
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }
}

class _DailyGoalsCard extends StatelessWidget {
  final bool goalCalories;
  final bool goalWater;
  final bool goalMeals;
  final bool goalActivity;

  const _DailyGoalsCard({
    required this.goalCalories,
    required this.goalWater,
    required this.goalMeals,
    required this.goalActivity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            offset: const Offset(0, 6),
            color: Colors.black.withValues(alpha: 0.06),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Günlük görevler',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          _goalRow(goalCalories, 'Kalori hedefini yakala'),
          _goalRow(goalWater, 'Su hedefini tamamla'),
          _goalRow(goalMeals, 'En az 3 öğün kaydet'),
          _goalRow(goalActivity, 'En az 30 dk hareket et'),
        ],
      ),
    );
  }

  Widget _goalRow(bool done, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            size: 20,
            color: done ? const Color(0xFF33A46F) : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: done ? Colors.black : Colors.grey[700],
              fontWeight: done ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroOverviewCard extends StatelessWidget {
  final DailyMacros macros;

  const _MacroOverviewCard({required this.macros});

  @override
  Widget build(BuildContext context) {
    final total = (macros.protein + macros.carbs + macros.fat);
    double pP = 0, cP = 0, fP = 0;
    if (total > 0) {
      pP = macros.protein / total;
      cP = macros.carbs / total;
      fP = macros.fat / total;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            offset: const Offset(0, 6),
            color: Colors.black.withValues(alpha: 0.06),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Makro besin özeti',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _macroItem('Protein', macros.protein, pP),
              _macroItem('Karb', macros.carbs, cP),
              _macroItem('Yağ', macros.fat, fP),
            ],
          ),
        ],
      ),
    );
  }

  Widget _macroItem(String label, double grams, double percent) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 2),
        Text(
          '${grams.toStringAsFixed(1)} g',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '%${(percent * 100).clamp(0, 100).toStringAsFixed(0)}',
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }
}

class _CoachTipCard extends StatelessWidget {
  final String text;

  const _CoachTipCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEEF3FF), Color(0xFFDCE6FF)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            offset: const Offset(0, 6),
            color: Colors.black.withValues(alpha: 0.08),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_rounded,
            color: Color(0xFF4B6CFF),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Koç önerisi',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeHighlightCard extends StatelessWidget {
  final String badgeTitle;
  final String badgeDesc;

  const _BadgeHighlightCard({
    required this.badgeTitle,
    required this.badgeDesc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF4C2), Color(0xFFFFE08A)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            offset: const Offset(0, 6),
            color: Colors.black.withValues(alpha: 0.08),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.emoji_events_rounded,
            size: 28,
            color: Color(0xFFB8860B),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  badgeTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  badgeDesc,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  final VoidCallback onGoMeals;
  final VoidCallback onGoWater;
  final VoidCallback onGoMessages;

  const _QuickActionsRow({
    required this.onGoMeals,
    required this.onGoWater,
    required this.onGoMessages,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onGoMeals,
            icon: const Icon(Icons.restaurant_rounded),
            label: const Text('Öğün ekle'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF33A46F),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onGoWater,
            icon: const Icon(Icons.water_drop_rounded),
            label: const Text('Su ekle'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF1890FF),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onGoMessages,
            icon: const Icon(Icons.chat_rounded),
            label: const Text('Mesaj yaz'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
