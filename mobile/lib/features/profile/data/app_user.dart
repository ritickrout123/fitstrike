class AppUser {
  const AppUser({
    required this.id,
    required this.username,
    required this.displayName,
    required this.level,
    required this.title,
    required this.totalDistance,
    required this.totalArea,
    required this.workoutsCompleted,
    required this.territoryCaptures,
    required this.streak,
  });

  final String id;
  final String username;
  final String displayName;
  final int level;
  final String title;
  final int totalDistance;
  final int totalArea;
  final int workoutsCompleted;
  final int territoryCaptures;
  final int streak;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final profile =
        Map<String, dynamic>.from(json['profile'] as Map? ?? const {});
    final stats = Map<String, dynamic>.from(json['stats'] as Map? ?? const {});

    return AppUser(
      id: json['id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      displayName: profile['displayName'] as String? ?? '',
      level: profile['level'] as int? ?? 0,
      title: profile['title'] as String? ?? '',
      totalDistance: stats['totalDistance'] as int? ?? 0,
      totalArea: stats['totalArea'] as int? ?? 0,
      workoutsCompleted: stats['workoutsCompleted'] as int? ?? 0,
      territoryCaptures: stats['territoryCaptures'] as int? ?? 0,
      streak: json['streak'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'profile': {
        'displayName': displayName,
        'level': level,
        'title': title,
      },
      'stats': {
        'totalDistance': totalDistance,
        'totalArea': totalArea,
        'workoutsCompleted': workoutsCompleted,
        'territoryCaptures': territoryCaptures,
      },
      'streak': streak,
    };
  }
}
