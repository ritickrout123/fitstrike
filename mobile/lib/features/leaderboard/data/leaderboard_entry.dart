class LeaderboardEntry {
  const LeaderboardEntry({
    required this.userId,
    required this.rank,
    required this.displayName,
    required this.level,
    required this.title,
    required this.scoreKm2,
    required this.isCurrentUser,
  });

  final String userId;
  final int rank;
  final String displayName;
  final int level;
  final String title;
  final int scoreKm2;
  final bool isCurrentUser;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      userId: json['userId'] as String? ?? '',
      rank: json['rank'] as int? ?? 0,
      displayName: json['displayName'] as String? ?? '',
      level: json['level'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      scoreKm2: json['scoreKm2'] as int? ?? 0,
      isCurrentUser: json['isCurrentUser'] as bool? ?? false,
    );
  }
}
