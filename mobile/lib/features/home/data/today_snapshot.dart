class TodaySnapshot {
  const TodaySnapshot({
    required this.date,
    required this.streak,
    required this.workoutLabel,
    required this.workoutFocus,
    required this.exerciseCount,
    required this.completedExerciseCount,
    required this.isWorkoutComplete,
    required this.caloriesConsumed,
    required this.caloriesGoal,
    required this.mealCount,
    required this.proteinConsumed,
    required this.proteinGoal,
    required this.carbsConsumed,
    required this.carbsGoal,
    required this.fatsConsumed,
    required this.fatsGoal,
  });

  final String date;
  final int streak;
  final String workoutLabel;
  final String workoutFocus;
  final int exerciseCount;
  final int completedExerciseCount;
  final bool isWorkoutComplete;
  final int caloriesConsumed;
  final int caloriesGoal;
  final int mealCount;
  final int proteinConsumed;
  final int proteinGoal;
  final int carbsConsumed;
  final int carbsGoal;
  final int fatsConsumed;
  final int fatsGoal;

  factory TodaySnapshot.fromJson(Map<String, dynamic> json) {
    final workout =
        Map<String, dynamic>.from(json['workout'] as Map? ?? const {});
    final nutrition =
        Map<String, dynamic>.from(json['nutrition'] as Map? ?? const {});
    final macros =
        Map<String, dynamic>.from(nutrition['macros'] as Map? ?? const {});
    final protein =
        Map<String, dynamic>.from(macros['protein'] as Map? ?? const {});
    final carbs =
        Map<String, dynamic>.from(macros['carbs'] as Map? ?? const {});
    final fats = Map<String, dynamic>.from(macros['fats'] as Map? ?? const {});

    return TodaySnapshot(
      date: json['date'] as String? ?? '',
      streak: json['streak'] as int? ?? 0,
      workoutLabel: workout['label'] as String? ?? '',
      workoutFocus: workout['focus'] as String? ?? '',
      exerciseCount: workout['exerciseCount'] as int? ?? 0,
      completedExerciseCount: workout['completedExerciseCount'] as int? ?? 0,
      isWorkoutComplete: workout['isComplete'] as bool? ?? false,
      caloriesConsumed: nutrition['caloriesConsumed'] as int? ?? 0,
      caloriesGoal: nutrition['caloriesGoal'] as int? ?? 0,
      mealCount: nutrition['mealCount'] as int? ?? 0,
      proteinConsumed: protein['consumed'] as int? ?? 0,
      proteinGoal: protein['goal'] as int? ?? 0,
      carbsConsumed: carbs['consumed'] as int? ?? 0,
      carbsGoal: carbs['goal'] as int? ?? 0,
      fatsConsumed: fats['consumed'] as int? ?? 0,
      fatsGoal: fats['goal'] as int? ?? 0,
    );
  }
}
