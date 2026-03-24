import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/patient_provider.dart';

class WaterTrackerScreen extends StatelessWidget {
  const WaterTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PatientProvider>(
      builder: (context, patient, _) {
        final totalMl = patient.todayWaterTotalMl;
        final totalL = patient.todayWaterTotalL;
        final targetL = patient.dailyWaterTargetL;

        final percentage = targetL == 0
            ? 0.0
            : (totalL / targetL).clamp(0.0, 1.0);

        final remainingL = (targetL - totalL).clamp(0.0, 100.0);

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Su Takibi',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // === ANA KART: ŞİŞE + İSTATİSTİKLER ===
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blue.shade50,
                        Colors.blue.shade100.withOpacity(0.8),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: Column(
                    children: [
                      // --- ŞİŞE ---
                      SizedBox(
                        height: 240,
                        child: Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Glow efekti
                              Container(
                                width: 140,
                                height: 230,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(60),
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 25,
                                      spreadRadius: 5,
                                      offset: const Offset(0, 12),
                                      color: Colors.blue.withOpacity(0.35),
                                    ),
                                  ],
                                ),
                              ),
                              // Şişe & su
                              _BottleWidget(percentage: percentage),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // --- RAKAMLAR ---
                      Text(
                        '${totalL.toStringAsFixed(2)} / ${targetL.toStringAsFixed(1)} L',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),

                      LinearProgressIndicator(
                        value: percentage,
                        minHeight: 8,
                        backgroundColor: Colors.blue.shade50,
                        valueColor: AlwaysStoppedAnimation(
                          Colors.blue.shade500,
                        ),
                      ),
                      const SizedBox(height: 6),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '%${(percentage * 100).toStringAsFixed(0)} tamamlandı',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'Kalan: ${remainingL.toStringAsFixed(2)} L',
                            style: TextStyle(
                              color: remainingL == 0
                                  ? Colors.green.shade700
                                  : Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // --- Hedef ayarlama ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () => patient
                                .setDailyWaterTarget(targetL - 0.5),
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text(
                            'Günlük hedef: ${targetL.toStringAsFixed(1)} L',
                            style: const TextStyle(fontSize: 14),
                          ),
                          IconButton(
                            onPressed: () =>
                                patient.setDailyWaterTarget(targetL + 0.5),
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // === +250 / -250 BUTONLARI ===
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        side: BorderSide(color: Colors.blue.shade300, width: 1),
                      ),
                      onPressed: totalMl <= 0
                          ? null
                          : () => patient.removeWater250(),
                      icon: const Icon(Icons.remove),
                      label: const Text('- 250 ml'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade500,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => patient.addWater250(),
                      icon: const Icon(Icons.add),
                      label: const Text('+ 250 ml'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // === GÜN İÇİ SU KAYITLARI ===
              Expanded(
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: patient.todayWater.isEmpty
                      ? Center(
                          child: Text(
                            'Bugün henüz su eklemedin.\nBaşlamak için +250 ml’ye dokun.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: patient.todayWater.length,
                          itemBuilder: (context, index) {
                            final w = patient.todayWater[index];
                            final isNegative = w.amountMl < 0;
                            final timeText = TimeOfDay.fromDateTime(
                                    w.date.toLocal())
                                .format(context);

                            return ListTile(
                              leading: Icon(
                                Icons.water_drop_rounded,
                                color: isNegative
                                    ? Colors.redAccent
                                    : Colors.blue.shade400,
                              ),
                              title: Text(
                                '${w.amountMl.toInt()} ml',
                                style: TextStyle(
                                  color: isNegative
                                      ? Colors.redAccent
                                      : Colors.black87,
                                ),
                              ),
                              subtitle: Text(
                                timeText,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Şişe widget'ı – daha şık görünüm
class _BottleWidget extends StatelessWidget {
  final double percentage; // 0–1

  const _BottleWidget({required this.percentage});

  @override
  Widget build(BuildContext context) {
    final fill = percentage.clamp(0.0, 1.0);

    return SizedBox(
      width: 120,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Şişe gövdesi
          Container(
            width: 110,
            height: 210,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: Colors.blue.shade300,
                width: 3,
              ),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Color(0xFFE3F2FD),
                ],
              ),
            ),
          ),

          // Kapağı
          Positioned(
            top: -16,
            child: Container(
              width: 40,
              height: 22,
              decoration: BoxDecoration(
                color: Colors.blue.shade500,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),

          // Kulplu görünüm
          Positioned(
            top: 6,
            child: Container(
              width: 72,
              height: 14,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.shade200,
                  width: 2,
                ),
              ),
            ),
          ),

          // Su seviyesi (animasyonlu dolum)
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: fill),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(36),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  heightFactor: value <= 0 ? 0.02 : value,
                  child: Container(
                    width: 104,
                    height: 204,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.lightBlue.shade200,
                          Colors.blue.shade700,
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Ortadaki yuvarlak damla
          Positioned(
            bottom: 36,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                    color: Colors.black.withOpacity(0.18),
                  ),
                ],
              ),
              child: Icon(
                Icons.water_drop_rounded,
                color: Colors.blue.shade500,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
