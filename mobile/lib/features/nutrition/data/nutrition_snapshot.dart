class NutritionSnapshot {
  const NutritionSnapshot({
    required this.date,
    required this.caloriesConsumed,
    required this.caloriesGoal,
    required this.mealCount,
    required this.proteinConsumed,
    required this.proteinGoal,
    required this.carbsConsumed,
    required this.carbsGoal,
    required this.fatsConsumed,
    required this.fatsGoal,
    required this.meals,
  });

  final String date;
  final int caloriesConsumed;
  final int caloriesGoal;
  final int mealCount;
  final int proteinConsumed;
  final int proteinGoal;
  final int carbsConsumed;
  final int carbsGoal;
  final int fatsConsumed;
  final int fatsGoal;
  final List<NutritionMeal> meals;

  factory NutritionSnapshot.fromJson(Map<String, dynamic> json) {
    final macros =
        Map<String, dynamic>.from(json['macros'] as Map? ?? const {});
    final protein =
        Map<String, dynamic>.from(macros['protein'] as Map? ?? const {});
    final carbs =
        Map<String, dynamic>.from(macros['carbs'] as Map? ?? const {});
    final fats = Map<String, dynamic>.from(macros['fats'] as Map? ?? const {});
    final meals = (json['meals'] as List? ?? const [])
        .map((entry) =>
            NutritionMeal.fromJson(Map<String, dynamic>.from(entry as Map)))
        .toList();

    return NutritionSnapshot(
      date: json['date'] as String? ?? '',
      caloriesConsumed: json['caloriesConsumed'] as int? ?? 0,
      caloriesGoal: json['caloriesGoal'] as int? ?? 0,
      mealCount: json['mealCount'] as int? ?? meals.length,
      proteinConsumed: protein['consumed'] as int? ?? 0,
      proteinGoal: protein['goal'] as int? ?? 0,
      carbsConsumed: carbs['consumed'] as int? ?? 0,
      carbsGoal: carbs['goal'] as int? ?? 0,
      fatsConsumed: fats['consumed'] as int? ?? 0,
      fatsGoal: fats['goal'] as int? ?? 0,
      meals: meals,
    );
  }
}

class NutritionMeal {
  const NutritionMeal({
    required this.id,
    required this.category,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.timeLabel,
  });

  final String id;
  final String category;
  final String name;
  final int calories;
  final int protein;
  final int carbs;
  final int fats;
  final String timeLabel;

  factory NutritionMeal.fromJson(Map<String, dynamic> json) {
    return NutritionMeal(
      id: json['id'] as String? ?? '',
      category: json['category'] as String? ?? '',
      name: json['name'] as String? ?? '',
      calories: json['calories'] as int? ?? 0,
      protein: json['protein'] as int? ?? 0,
      carbs: json['carbs'] as int? ?? 0,
      fats: json['fats'] as int? ?? 0,
      timeLabel: json['timeLabel'] as String? ?? '',
    );
  }
}

class NutritionLogResult {
  const NutritionLogResult({
    required this.meal,
    required this.snapshot,
  });

  final NutritionMeal meal;
  final NutritionSnapshot snapshot;

  factory NutritionLogResult.fromJson(Map<String, dynamic> json) {
    final meal = NutritionMeal.fromJson(
        Map<String, dynamic>.from(json['meal'] as Map? ?? const {}));
    final snapshot = NutritionSnapshot.fromJson(
        Map<String, dynamic>.from(json['nutrition'] as Map? ?? const {}));

    return NutritionLogResult(
      meal: meal,
      snapshot: snapshot,
    );
  }
}
