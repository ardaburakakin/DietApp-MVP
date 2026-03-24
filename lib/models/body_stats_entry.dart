class BodyStatsEntry {
  final String id;
  final DateTime date;
  final double weightKg;
  final double? bodyFatPercent;

  BodyStatsEntry({
    required this.id,
    required this.date,
    required this.weightKg,
    this.bodyFatPercent,
  });
}
