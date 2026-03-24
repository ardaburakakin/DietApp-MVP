// screens/activity/activity_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/patient_provider.dart';
import '../../models/activity_entry.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PatientProvider>(context);
    final today = DateTime.now();
    final activities = provider.activitiesForDate(today);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aktivite Günlüğü'),
      ),
      body: ListView.builder(
        itemCount: activities.length,
        itemBuilder: (context, i) {
          final a = activities[i];
          return ListTile(
            leading: const Icon(Icons.directions_run_rounded),
            title: Text('${a.type} - ${a.durationMinutes} dk'),
            subtitle: Text(
              a.caloriesBurned != null
                  ? '${a.caloriesBurned} kcal'
                  : 'Kalori belirtilmemiş',
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddActivity(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _openAddActivity(BuildContext context) {
    final typeCtrl = TextEditingController();
    final durationCtrl = TextEditingController();
    final caloriesCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Aktivite ekle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: typeCtrl,
              decoration: const InputDecoration(labelText: 'Tür'),
            ),
            TextField(
              controller: durationCtrl,
              decoration:
                  const InputDecoration(labelText: 'Süre (dk)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: caloriesCtrl,
              decoration:
                  const InputDecoration(labelText: 'Yakılan kalori (opsiyonel)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              final p = Provider.of<PatientProvider>(context,
                  listen: false);
              final duration =
                  int.tryParse(durationCtrl.text.trim()) ?? 0;
              final cal =
                  int.tryParse(caloriesCtrl.text.trim());

              final entry = ActivityEntry(
                id: DateTime.now()
                    .millisecondsSinceEpoch
                    .toString(),
                date: DateTime.now(),
                type: typeCtrl.text.isEmpty
                    ? 'Aktivite'
                    : typeCtrl.text,
                durationMinutes: duration,
                caloriesBurned: cal,
              );

              p.addActivity(entry);
              Navigator.pop(context);
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }
}
