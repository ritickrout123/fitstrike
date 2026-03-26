class GymPlan {
  const GymPlan({
    required this.date,
    required this.label,
    required this.focus,
    required this.exerciseCount,
    required this.completedExerciseCount,
    required this.isComplete,
    required this.exercises,
  });

  final String date;
  final String label;
  final String focus;
  final int exerciseCount;
  final int completedExerciseCount;
  final bool isComplete;
  final List<GymExercise> exercises;

  factory GymPlan.fromJson(Map<String, dynamic> json) {
    final exercises = (json['exercises'] as List? ?? const [])
        .map((entry) =>
            GymExercise.fromJson(Map<String, dynamic>.from(entry as Map)))
        .toList();

    return GymPlan(
      date: json['date'] as String? ?? '',
      label: json['label'] as String? ?? '',
      focus: json['focus'] as String? ?? '',
      exerciseCount: json['exerciseCount'] as int? ?? exercises.length,
      completedExerciseCount: json['completedExerciseCount'] as int? ?? 0,
      isComplete: json['isComplete'] as bool? ?? false,
      exercises: exercises,
    );
  }
}

class GymExercise {
  const GymExercise({
    required this.id,
    required this.name,
    required this.targetSets,
    required this.repRange,
    required this.loadKg,
    required this.restSeconds,
    required this.isCompleted,
  });

  final String id;
  final String name;
  final int targetSets;
  final String repRange;
  final double loadKg;
  final int restSeconds;
  final bool isCompleted;

  factory GymExercise.fromJson(Map<String, dynamic> json) {
    return GymExercise(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      targetSets: json['targetSets'] as int? ?? 0,
      repRange: json['repRange'] as String? ?? '',
      loadKg: (json['loadKg'] as num?)?.toDouble() ?? 0,
      restSeconds: json['restSeconds'] as int? ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}

class GymCompletionResult {
  const GymCompletionResult({
    required this.exerciseId,
    required this.wasAlreadyCompleted,
    required this.completedExerciseCount,
    required this.exerciseCount,
    required this.isWorkoutComplete,
    required this.workoutsCompleted,
  });

  final String exerciseId;
  final bool wasAlreadyCompleted;
  final int completedExerciseCount;
  final int exerciseCount;
  final bool isWorkoutComplete;
  final int workoutsCompleted;

  factory GymCompletionResult.fromJson(Map<String, dynamic> json) {
    final workout =
        Map<String, dynamic>.from(json['workout'] as Map? ?? const {});

    return GymCompletionResult(
      exerciseId: json['exerciseId'] as String? ?? '',
      wasAlreadyCompleted: json['wasAlreadyCompleted'] as bool? ?? false,
      completedExerciseCount: workout['completedExerciseCount'] as int? ?? 0,
      exerciseCount: workout['exerciseCount'] as int? ?? 0,
      isWorkoutComplete: workout['isComplete'] as bool? ?? false,
      workoutsCompleted: json['workoutsCompleted'] as int? ?? 0,
    );
  }
}
