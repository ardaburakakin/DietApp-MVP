// screens/mood/mood_log_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/patient_provider.dart';
import '../../models/mood_entry.dart';

class MoodLogScreen extends StatelessWidget {
  const MoodLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PatientProvider>(context);
    final today = DateTime.now();
    final moods = provider.moodsForDate(today);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ruh Hali Günlüğü'),
      ),
      body: ListView.builder(
        itemCount: moods.length,
        itemBuilder: (context, i) {
          final m = moods[i];
          return ListTile(
            leading: Icon(
              Icons.circle,
              color: Colors.primaries[m.moodScore % Colors.primaries.length],
            ),
            title: Text('Mood: ${m.moodScore}/5'),
            subtitle: m.note != null ? Text(m.note!) : null,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddMood(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _openAddMood(BuildContext context) {
    int selectedScore = 3;
    final noteCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            title: const Text('Ruh hali ekle'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Slider(
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: '$selectedScore',
                  value: selectedScore.toDouble(),
                  onChanged: (v) {
                    setState(() => selectedScore = v.toInt());
                  },
                ),
                TextField(
                  controller: noteCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Not (opsiyonel)',
                  ),
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
                  p.addMood(
                    MoodEntry(
                      id: DateTime.now()
                          .millisecondsSinceEpoch
                          .toString(),
                      date: DateTime.now(),
                      moodScore: selectedScore,
                      note: noteCtrl.text.isEmpty
                          ? null
                          : noteCtrl.text,
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Kaydet'),
              ),
            ],
          );
        },
      ),
    );
  }
}
