class RunOverview {
  const RunOverview({
    required this.distanceKm,
    required this.duration,
    required this.calories,
    required this.pace,
    required this.points,
    required this.ownedAreaKm2,
    required this.globalRank,
    required this.missions,
  });

  final double distanceKm;
  final String duration;
  final int calories;
  final String pace;
  final int points;
  final double ownedAreaKm2;
  final int globalRank;
  final List<RunMission> missions;

  factory RunOverview.fromJson(Map<String, dynamic> json) {
    final metrics =
        Map<String, dynamic>.from(json['metrics'] as Map? ?? const {});
    final missions = (json['missions'] as List? ?? const [])
        .map((entry) =>
            RunMission.fromJson(Map<String, dynamic>.from(entry as Map)))
        .toList();

    return RunOverview(
      distanceKm: (metrics['distanceKm'] as num?)?.toDouble() ?? 0,
      duration: metrics['duration'] as String? ?? '',
      calories: metrics['calories'] as int? ?? 0,
      pace: metrics['pace'] as String? ?? '',
      points: metrics['points'] as int? ?? 0,
      ownedAreaKm2: (json['ownedAreaKm2'] as num?)?.toDouble() ?? 0,
      globalRank: json['globalRank'] as int? ?? 0,
      missions: missions,
    );
  }
}

class RunMission {
  const RunMission({
    required this.id,
    required this.label,
    required this.progress,
    required this.reward,
  });

  final String id;
  final String label;
  final double progress;
  final int reward;

  factory RunMission.fromJson(Map<String, dynamic> json) {
    return RunMission(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? '',
      progress: (json['progress'] as num?)?.toDouble() ?? 0,
      reward: json['reward'] as int? ?? 0,
    );
  }
}
