import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/patient_provider.dart';
import '../../models/meal_entry.dart';
import '../../models/badge.dart';
import '../../models/food_item.dart';

bool _isSameDate(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

class MealLogScreen extends StatefulWidget {
  const MealLogScreen({super.key});

  @override
  State<MealLogScreen> createState() => _MealLogScreenState();
}

class _MealLogScreenState extends State<MealLogScreen> {
  final int _daysBefore = 7;
  final int _daysAfter = 0;

  late final PageController _pageController;
  late int _currentPage;

  int get _totalPages => _daysBefore + _daysAfter + 1;

  @override
  void initState() {
    super.initState();
    _currentPage = _daysBefore;
    _pageController = PageController(
      initialPage: _currentPage,
      viewportFraction: 0.94,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime _dateForPage(int index) {
    final diff = index - _daysBefore;
    final today = DateTime.now();
    return DateTime(today.year, today.month, today.day)
        .add(Duration(days: diff));
  }

  String _formatDate(DateTime date) {
    final months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];
    final day = date.day.toString().padLeft(2, '0');
    final monthName = months[date.month - 1];
    return '$day $monthName ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PatientProvider>(
      builder: (context, patient, _) {
        final today = DateTime.now();
        final weeklyData = patient.lastDaysCalories(days: 7);
        final badges = patient.badges;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF5FFF8), Color(0xFFE5FFE9)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // ÜST BAR
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Diyet Günlüğü',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Öğünler, hedefler, makrolar',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () =>
                              _openCalorieTargetDialog(context, patient),
                          icon: const Icon(Icons.flag_rounded),
                          tooltip: 'Kalori hedefini ayarla',
                        ),
                      ],
                    ),
                  ),

                  // ROZET BANNER (varsa son rozet)
                  if (badges.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: _BadgeBanner(badge: badges.last),
                    ),

                  // HAFTALIK ÖZET
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: WeeklySummaryCard(
                      data: weeklyData,
                      target: patient.dailyCalorieTarget,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // GÜNLÜK SAYFALAR
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _totalPages,
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                      },
                      itemBuilder: (context, index) {
                        final date = _dateForPage(index);
                        final meals = patient.mealsForDate(date);
                        final totalCalories =
                            patient.totalCaloriesForDate(date);
                        final macros = patient.macrosForDate(date);

                        return _buildDayPage(
                          context: context,
                          date: date,
                          meals: meals,
                          totalCalories: totalCalories,
                          isToday: _isSameDate(date, today),
                          target: patient.dailyCalorieTarget,
                          macros: macros,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: SizedBox(
              width: double.infinity,
              child: FloatingActionButton.extended(
                elevation: 8,
                onPressed: () {
                  final date = _dateForPage(_currentPage);
                  _openAddMealDialog(context, date);
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text(
                  'Bu güne öğün ekle',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDayPage({
    required BuildContext context,
    required DateTime date,
    required List<MealEntry> meals,
    required int totalCalories,
    required bool isToday,
    required double target,
    required DailyMacros macros,
  }) {
    final progress =
        (target <= 0) ? 0.0 : (totalCalories / target).clamp(0.0, 2.0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        children: [
          // Tarih + kalori hedef kartı
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isToday
                    ? const [Color(0xFF9EF4C2), Color(0xFF6FE7A9)]
                    : const [Color(0xFFEFFBF4), Color(0xFFD7F5E3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                  color: Colors.black.withValues(alpha: 0.1),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isToday ? 'Bugün' : _formatDate(date),
                          style: TextStyle(
                            fontSize: isToday ? 20 : 18,
                            fontWeight: FontWeight.bold,
                            color: isToday ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.local_fire_department_rounded,
                              size: 18,
                              color: isToday
                                  ? Colors.white.withValues(alpha: 0.9)
                                  : const Color(0xFF33A46F),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$totalCalories / ${target.toInt()} kcal',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isToday
                                    ? Colors.white
                                    : const Color(0xFF2C7A57),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          meals.isEmpty
                              ? 'Henüz öğün eklenmemiş'
                              : '${meals.length} öğün kaydedildi',
                          style: TextStyle(
                            fontSize: 12,
                            color: isToday
                                ? Colors.white.withValues(alpha: 0.9)
                                : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: isToday
                            ? Colors.white.withValues(alpha: 0.2)
                            : Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.restaurant_menu_rounded,
                        color:
                            isToday ? Colors.white : const Color(0xFF33A46F),
                        size: 28,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: progress > 1 ? 1 : progress,
                    minHeight: 10,
                    backgroundColor:
                        Colors.white.withValues(alpha: 0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isToday ? Colors.white : const Color(0xFF33A46F),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    progress < 1
                        ? '%${(progress * 100).clamp(0, 100).toInt()} tamamlandı'
                        : 'Hedefe ulaşıldı',
                    style: TextStyle(
                      fontSize: 11,
                      color: isToday
                          ? Colors.white.withValues(alpha: 0.9)
                          : Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Makro kartı
          _MacroSummaryCard(macros: macros),

          const SizedBox(height: 12),

          Expanded(
            child: meals.isEmpty
                ? Center(
                    child: Text(
                      'Bu gün için öğün eklenmemiş.\nAlttan ekleyebilirsin.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: 16, top: 4),
                    itemCount: meals.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final m = meals[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                              color: Colors.black.withValues(alpha: 0.05),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          leading: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFFBF4),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.fastfood_rounded,
                              size: 24,
                              color: Color(0xFF33A46F),
                            ),
                          ),
                          title: Text(
                            '${m.mealType} - ${m.calories ?? 0} kcal',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            m.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// 🔥 ÖNEMLİ: Burada yiyecek adı serbest metin, API'den (şu an mock) aranıyor
  void _openAddMealDialog(BuildContext context, DateTime date) {
    final descriptionCtrl = TextEditingController();
    final gramsCtrl = TextEditingController();
    final foodNameCtrl = TextEditingController();

    String? selectedMealType = 'Kahvaltı';
    double calculatedCalories = 0;
    double p = 0, c = 0, f = 0;
    bool isSearching = false;
    String? errorText;

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            Future<void> recalc() async {
              final grams = double.tryParse(gramsCtrl.text) ?? 0;
              if (grams <= 0 || foodNameCtrl.text.trim().isEmpty) {
                setState(() {
                  calculatedCalories = 0;
                  p = c = f = 0;
                  errorText = null;
                });
                return;
              }

              setState(() {
                isSearching = true;
                errorText = null;
              });

              final patient =
                  Provider.of<PatientProvider>(context, listen: false);
              final FoodItem? food =
                  await patient.searchFood(foodNameCtrl.text.trim());

              if (!ctx.mounted) return;

              if (food == null) {
                setState(() {
                  isSearching = false;
                  calculatedCalories = 0;
                  p = c = f = 0;
                  errorText =
                      '"${foodNameCtrl.text}" için besin bilgisi bulunamadı.';
                });
                return;
              }

              final factor = grams / 100.0;
              setState(() {
                calculatedCalories = food.caloriesPer100g * factor;
                p = food.proteinPer100g * factor;
                c = food.carbsPer100g * factor;
                f = food.fatPer100g * factor;
                descriptionCtrl.text =
                    '${food.name} - ${grams.toStringAsFixed(0)} g';
                isSearching = false;
                errorText = null;
              });
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: const Text('Öğün Ekle'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedMealType,
                      decoration: const InputDecoration(
                        labelText: 'Öğün tipi',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Kahvaltı',
                          child: Text('Kahvaltı'),
                        ),
                        DropdownMenuItem(
                          value: 'Öğle',
                          child: Text('Öğle'),
                        ),
                        DropdownMenuItem(
                          value: 'Akşam',
                          child: Text('Akşam'),
                        ),
                        DropdownMenuItem(
                          value: 'Ara öğün',
                          child: Text('Ara öğün'),
                        ),
                      ],
                      onChanged: (val) {
                        setState(() => selectedMealType = val);
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: foodNameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Yiyecek adı',
                        hintText: 'Örn: muz, yulaf, pilav...',
                      ),
                      onChanged: (_) {
                        setState(() {
                          calculatedCalories = 0;
                          p = c = f = 0;
                          errorText = null;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: gramsCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Miktar (gram)',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: isSearching ? null : recalc,
                        icon: isSearching
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.search),
                        label: const Text('Hesapla'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descriptionCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Açıklama',
                        hintText: 'Örn: Yulaf + süt + muz',
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    if (errorText != null)
                      Text(
                        errorText!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kalori: ${calculatedCalories.toStringAsFixed(0)} kcal',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Protein: ${p.toStringAsFixed(1)} g, Karb: ${c.toStringAsFixed(1)} g, Yağ: ${f.toStringAsFixed(1)} g',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('İptal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (calculatedCalories <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Önce yiyecek adı, gram ve Hesapla\'ya basman gerekiyor.',
                          ),
                        ),
                      );
                      return;
                    }

                    final entry = MealEntry(
                      id: DateTime.now()
                          .millisecondsSinceEpoch
                          .toString(),
                      date: date,
                      mealType: selectedMealType ?? 'Öğün',
                      description: descriptionCtrl.text,
                      calories: calculatedCalories.round(),
                      protein: p,
                      carbs: c,
                      fat: f,
                    );

                    Provider.of<PatientProvider>(context, listen: false)
                        .addMeal(entry);

                    Navigator.of(context).pop();
                  },
                  child: const Text('Kaydet'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openCalorieTargetDialog(
      BuildContext context, PatientProvider patient) {
    final ctrl = TextEditingController(
      text: patient.dailyCalorieTarget.toInt().toString(),
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text('Günlük kalori hedefi'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Hedef (kcal)',
            helperText: 'Örn: 1800',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              final v = double.tryParse(ctrl.text);
              if (v != null) {
                patient.setDailyCalorieTarget(v);
              }
              Navigator.of(context).pop();
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }
}

// Makro kartı
class _MacroSummaryCard extends StatelessWidget {
  final DailyMacros macros;

  const _MacroSummaryCard({required this.macros});

  @override
  Widget build(BuildContext context) {
    final total = macros.protein + macros.carbs + macros.fat;
    double pPercent = 0, cPercent = 0, fPercent = 0;
    if (total > 0) {
      pPercent = macros.protein / total;
      cPercent = macros.carbs / total;
      fPercent = macros.fat / total;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            offset: const Offset(0, 6),
            color: Colors.black.withValues(alpha: 0.05),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Makro Özeti',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _macroChip(
                label: 'Protein',
                grams: macros.protein,
                percent: pPercent,
              ),
              _macroChip(
                label: 'Karb',
                grams: macros.carbs,
                percent: cPercent,
              ),
              _macroChip(
                label: 'Yağ',
                grams: macros.fat,
                percent: fPercent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _macroChip({
    required String label,
    required double grams,
    required double percent,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${grams.toStringAsFixed(1)} g',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '%${(percent * 100).clamp(0, 100).toStringAsFixed(0)}',
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

// Haftalık özet kartı – basit progress bar listesi
class WeeklySummaryCard extends StatelessWidget {
  final List<DailyCalories> data;
  final double target;

  const WeeklySummaryCard({
    super.key,
    required this.data,
    required this.target,
  });

  String _shortLabel(DateTime date) {
    const days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    return days[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    final maxCalories = [
      ...data.map((e) => e.calories.toDouble()),
      target,
    ].reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 8),
            color: Colors.black.withValues(alpha: 0.07),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Haftalık özet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Hedef: ${target.toInt()} kcal / gün',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          for (final d in data) ...[
            Row(
              children: [
                SizedBox(
                  width: 36,
                  child: Text(
                    _shortLabel(d.date),
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
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
                      minHeight: 8,
                      backgroundColor:
                          Colors.grey.withValues(alpha: 0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF33A46F),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${d.calories}',
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

// Rozet banner – AppBadge modeli kullanıyor
class _BadgeBanner extends StatelessWidget {
  final AppBadge badge;

  const _BadgeBanner({required this.badge});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF4C2), Color(0xFFFFE08A)],
        ),
        borderRadius: BorderRadius.circular(18),
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
                  badge.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  badge.description,
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
