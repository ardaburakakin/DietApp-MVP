class AppBadge {
  final String id;
  final String title;
  final String description;
  final String type; // 'water_target_once', 'calorie_streak_3' gibi
  final DateTime unlockedAt;

  AppBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.unlockedAt,
  });
}
