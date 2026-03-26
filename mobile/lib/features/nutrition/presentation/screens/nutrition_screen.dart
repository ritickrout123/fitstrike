import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/theme.dart';
import '../../../../shared/widgets/feature_placeholder_card.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../home/data/today_repository.dart';
import '../../data/nutrition_repository.dart';
import '../../data/nutrition_snapshot.dart';

class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nutritionAsync = ref.watch(nutritionProvider);
    final session = ref.watch(authControllerProvider).session;

    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        nutritionAsync.when(
          data: (snapshot) {
            if (snapshot == null) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: FeaturePlaceholderCard(
                  title: 'Calorie Tracker',
                  subtitle:
                      'Log in to load calorie targets, meal groups, and macro summaries.',
                  badge: 'Locked',
                ),
              );
            }

            return _NutritionHero(snapshot: snapshot);
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: FeaturePlaceholderCard(
              title: 'Calorie Tracker',
              subtitle: 'Loading your nutrition summary...',
            ),
          ),
          error: (error, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: FeaturePlaceholderCard(
              title: 'Calorie Tracker',
              subtitle: error.toString(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Use the quick-add buttons below to log a meal.'),
                  ),
                );
              },
              child: const Text('+ ADD MEAL / SNACK'),
            ),
          ),
        ),
        nutritionAsync.when(
          data: (snapshot) {
            if (snapshot == null) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final meal in _quickAddMeals)
                    _QuickAddButton(
                      meal: meal,
                      onPressed: session == null
                          ? null
                          : () async {
                              try {
                                final result = await ref
                                    .read(nutritionRepositoryProvider)
                                    .addMeal(
                                      token: session.token,
                                      name: meal.name,
                                      category: meal.category,
                                      calories: meal.calories,
                                      protein: meal.protein,
                                      carbs: meal.carbs,
                                      fats: meal.fats,
                                    );
                                ref.invalidate(nutritionProvider);
                                ref.invalidate(todaySnapshotProvider);

                                if (!context.mounted) {
                                  return;
                                }

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Logged ${result.meal.name} for ${result.meal.calories} kcal.'),
                                  ),
                                );
                              } catch (error) {
                                if (!context.mounted) {
                                  return;
                                }

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(error.toString())),
                                );
                              }
                            },
                    ),
                ],
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        nutritionAsync.when(
          data: (snapshot) {
            if (snapshot == null) {
              return const SizedBox.shrink();
            }

            final groupedMeals = <String, List<NutritionMeal>>{};
            for (final meal in snapshot.meals) {
              groupedMeals.putIfAbsent(meal.category, () => []).add(meal);
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final entry in groupedMeals.entries) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 22, 16, 10),
                    child: Text(
                      entry.key.toUpperCase(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 15,
                          ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        for (var index = 0; index < entry.value.length; index++)
                          Padding(
                            padding: EdgeInsets.only(
                                bottom:
                                    index == entry.value.length - 1 ? 0 : 10),
                            child: _MealCard(meal: entry.value[index]),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _NutritionHero extends StatelessWidget {
  const _NutritionHero({required this.snapshot});

  final NutritionSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final remaining = (snapshot.caloriesGoal - snapshot.caloriesConsumed)
        .clamp(0, snapshot.caloriesGoal);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0A1210),
            Color(0xFF08100E),
          ],
        ),
        border: Border.all(color: AppColors.borderStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatNutritionDate(snapshot.date),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 1,
                ),
          ),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.displaySmall,
              children: const [
                TextSpan(text: 'CALORIE '),
                TextSpan(
                  text: 'TRACKER',
                  style: TextStyle(color: AppColors.lime),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: 6,
            children: [
              Text(
                '${snapshot.caloriesConsumed}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                    ),
              ),
              Text(
                '/',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 28,
                      color: AppColors.textSecondary,
                    ),
              ),
              Text(
                '${snapshot.caloriesGoal}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 28,
                      color: AppColors.textSecondary,
                    ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'kcal',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              minHeight: 6,
              value:
                  _progress(snapshot.caloriesConsumed, snapshot.caloriesGoal),
              backgroundColor: AppColors.borderStrong,
              valueColor: const AlwaysStoppedAnimation(AppColors.lime),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$remaining kcal remaining today',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MacroSummaryCard(
                  color: AppColors.cyan,
                  label: 'Protein',
                  value: '${snapshot.proteinConsumed}g',
                  progress:
                      _progress(snapshot.proteinConsumed, snapshot.proteinGoal),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MacroSummaryCard(
                  color: AppColors.amber,
                  label: 'Carbs',
                  value: '${snapshot.carbsConsumed}g',
                  progress:
                      _progress(snapshot.carbsConsumed, snapshot.carbsGoal),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MacroSummaryCard(
                  color: AppColors.violet,
                  label: 'Fats',
                  value: '${snapshot.fatsConsumed}g',
                  progress: _progress(snapshot.fatsConsumed, snapshot.fatsGoal),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroSummaryCard extends StatelessWidget {
  const _MacroSummaryCard({
    required this.color,
    required this.label,
    required this.value,
    required this.progress,
  });

  final Color color;
  final String label;
  final String value;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 16,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              minHeight: 4,
              value: progress,
              backgroundColor: AppColors.borderStrong,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAddButton extends StatelessWidget {
  const _QuickAddButton({
    required this.meal,
    required this.onPressed,
  });

  final _QuickMealTemplate meal;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.borderStrong),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      child: Text(meal.label.toUpperCase()),
    );
  }
}

class _MealCard extends StatelessWidget {
  const _MealCard({required this.meal});

  final NutritionMeal meal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _MacroInline(label: 'P', value: '${meal.protein}g'),
                    _MacroInline(label: 'C', value: '${meal.carbs}g'),
                    _MacroInline(label: 'F', value: '${meal.fats}g'),
                    Text(
                      meal.timeLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${meal.calories}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 20,
                    ),
              ),
              Text(
                'kcal',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroInline extends StatelessWidget {
  const _MacroInline({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
        children: [
          TextSpan(text: '$label: '),
          TextSpan(
            text: value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

double _progress(int value, int goal) {
  if (goal <= 0) {
    return 0;
  }

  return (value / goal).clamp(0, 1).toDouble();
}

String _formatNutritionDate(String value) {
  final date = DateTime.tryParse(value);
  if (date == null) {
    return value;
  }

  const weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
}

class _QuickMealTemplate {
  const _QuickMealTemplate({
    required this.label,
    required this.category,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
  });

  final String label;
  final String category;
  final String name;
  final int calories;
  final int protein;
  final int carbs;
  final int fats;
}

const _quickAddMeals = [
  _QuickMealTemplate(
    label: 'Protein Shake',
    category: 'Post Lift',
    name: 'Protein Shake',
    calories: 220,
    protein: 32,
    carbs: 12,
    fats: 4,
  ),
  _QuickMealTemplate(
    label: 'Chicken Bowl',
    category: 'Lunch',
    name: 'Chicken Burrito Bowl',
    calories: 640,
    protein: 46,
    carbs: 62,
    fats: 18,
  ),
  _QuickMealTemplate(
    label: 'Yogurt Snack',
    category: 'Snack',
    name: 'Greek Yogurt Snack',
    calories: 180,
    protein: 16,
    carbs: 18,
    fats: 5,
  ),
];
