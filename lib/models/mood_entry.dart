class MoodEntry {
  final String id;
  final DateTime date;
  final int moodScore; // 1-5 arası
  final String? note;

  MoodEntry({
    required this.id,
    required this.date,
    required this.moodScore,
    this.note,
  });
}
