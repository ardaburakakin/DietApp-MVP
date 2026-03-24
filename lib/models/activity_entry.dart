class ActivityEntry {
  final String id;
  final DateTime date;
  final String type; // Koşu, Yürüyüş, Fitness ...
  final int durationMinutes;
  final int? caloriesBurned;

  ActivityEntry({
    required this.id,
    required this.date,
    required this.type,
    required this.durationMinutes,
    this.caloriesBurned,
  });
}
