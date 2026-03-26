import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/theme.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../gym/data/gym_plan.dart';
import '../../../gym/data/gym_repository.dart';
import '../../../profile/data/user_repository.dart';
import '../../data/today_snapshot.dart';
import '../../data/today_repository.dart';
import '../../../../shared/animations/fade_slide_in.dart';
import '../../../../shared/widgets/feature_placeholder_card.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class TodayOverviewScreen extends ConsumerWidget {
  const TodayOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayAsync = ref.watch(todaySnapshotProvider);
    final gymAsync = ref.watch(gymPlanProvider);
    final session = ref.watch(authControllerProvider).session;

    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        todayAsync.when(
          data: (snapshot) {
            if (snapshot == null) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: FeaturePlaceholderCard(
                  title: 'Today',
                  subtitle:
                      'Log in to load your personalized workout and nutrition snapshot.',
                  badge: 'Locked',
                ),
              );
            }

            return FadeSlideIn(
              child: _TodayHero(
                snapshot: snapshot,
                onQuickLog: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Open the Nutrition tab to log a meal.'),
                    ),
                  );
                },
              ),
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: FeaturePlaceholderCard(
              title: 'Loading Today',
              subtitle: 'Fetching your home dashboard from the backend.',
            ),
          ),
          error: (error, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: FeaturePlaceholderCard(
              title: 'Today Unavailable',
              subtitle: error.toString(),
            ),
          ),
        ),
        const FadeSlideIn(
          delay: Duration(milliseconds: 100),
          child: _SectionHeader(
            title: 'Today\'s Workout',
            actionLabel: 'Full Plan',
          ),
        ),
        todayAsync.maybeWhen(
          data: (snapshot) => snapshot == null
              ? const SizedBox.shrink()
              : FadeSlideIn(
                  delay: const Duration(milliseconds: 200),
                  child: _WorkoutWeekRow(
                    currentDate:
                        DateTime.tryParse(snapshot.date) ?? DateTime.now(),
                  ),
                ),
          orElse: () => const SizedBox.shrink(),
        ),
        const SizedBox(height: 6),
        gymAsync.when(
          data: (plan) {
            if (plan == null) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: FadeSlideIn(
                  delay: Duration(milliseconds: 300),
                  child: FeaturePlaceholderCard(
                    title: 'Workout Queue',
                    subtitle:
                        'Exercise cards, form cues, set targets, and completion state will live here.',
                  ),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  for (var index = 0;
                      index < plan.exercises.length && index < 4;
                      index++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: FadeSlideIn(
                        delay: Duration(milliseconds: 300 + (index * 100)),
                        child: _TodayExerciseCard(
                          exercise: plan.exercises[index],
                          accent:
                              _accentForExercise(plan.exercises[index], index),
                          label: _labelForExercise(plan.exercises[index]),
                          onComplete: session == null ||
                                  plan.exercises[index].isCompleted
                              ? null
                              : () async {
                                  // Logic
                                },
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (error, _) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _TodayHero extends StatelessWidget {
  const _TodayHero({
    required this.snapshot,
    required this.onQuickLog,
  });

  final TodaySnapshot snapshot;
  final VoidCallback onQuickLog;

  @override
  Widget build(BuildContext context) {
    final calorieProgress =
        _safeProgress(snapshot.caloriesConsumed, snapshot.caloriesGoal);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.backgroundAlt2,
            AppColors.backgroundAlt,
            Color(0xFF0D1020),
          ],
        ),
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 180,
              height: 180,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0x1AC8FF00),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatLongDate(snapshot.date),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 1,
                    ),
              ),
              const SizedBox(height: 6),
              _WorkoutTitle(label: snapshot.workoutLabel),
              const SizedBox(height: 4),
              Text(
                '${snapshot.workoutFocus}  •  ${snapshot.exerciseCount} exercises',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _CalorieRing(
                    consumed: snapshot.caloriesConsumed,
                    progress: calorieProgress,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      children: [
                        _MacroBar(
                          label: 'Protein',
                          current: snapshot.proteinConsumed,
                          goal: snapshot.proteinGoal,
                          color: AppColors.cyan,
                        ),
                        const SizedBox(height: 8),
                        _MacroBar(
                          label: 'Carbs',
                          current: snapshot.carbsConsumed,
                          goal: snapshot.carbsGoal,
                          color: AppColors.amber,
                        ),
                        const SizedBox(height: 8),
                        _MacroBar(
                          label: 'Fats',
                          current: snapshot.fatsConsumed,
                          goal: snapshot.fatsGoal,
                          color: AppColors.violet,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onQuickLog,
                  icon: const Icon(Icons.add_rounded, color: Colors.black),
                  label: const Text('LOG A MEAL'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WorkoutTitle extends StatelessWidget {
  const _WorkoutTitle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final parts = label.trim().split(RegExp(r'\s+'));
    if (parts.length < 2) {
      return Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.displaySmall,
      );
    }

    final lead = parts.take(parts.length - 1).join(' ').toUpperCase();
    final accent = parts.last.toUpperCase();

    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.displaySmall,
        children: [
          TextSpan(text: '$lead '),
          TextSpan(
            text: accent,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.lime,
                ),
          ),
        ],
      ),
    );
  }
}

class _CalorieRing extends StatelessWidget {
  const _CalorieRing({
    required this.consumed,
    required this.progress,
  });

  final int consumed;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 86,
      height: 86,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 7,
              backgroundColor: AppColors.borderStrong,
              valueColor: const AlwaysStoppedAnimation(AppColors.lime),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$consumed',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
              ),
              Text(
                'KCAL',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroBar extends StatelessWidget {
  const _MacroBar({
    required this.label,
    required this.current,
    required this.goal,
    required this.color,
  });

  final String label;
  final int current;
  final int goal;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label.toUpperCase(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ),
            Text(
              '$current / ${goal}g',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            minHeight: 4,
            value: _safeProgress(current, goal),
            backgroundColor: AppColors.borderStrong,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
  });

  final String title;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontSize: 16),
            ),
          ),
          Text(
            '$actionLabel ›',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.lime,
                ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutWeekRow extends StatelessWidget {
  const _WorkoutWeekRow({required this.currentDate});

  final DateTime currentDate;

  @override
  Widget build(BuildContext context) {
    const plan = [
      ('MON', 'Pull'),
      ('TUE', 'Legs'),
      ('WED', 'Push'),
      ('THU', 'Rest'),
      ('FRI', 'Pull'),
      ('SAT', 'Rest'),
      ('SUN', 'Legs'),
    ];

    final currentIndex = currentDate.weekday - 1;

    return SizedBox(
      height: 62,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemBuilder: (context, index) {
          final item = plan[index];
          final isToday = index == currentIndex;
          final isRest = item.$2 == 'Rest';

          return Container(
            width: 72,
            decoration: BoxDecoration(
              color: isToday ? AppColors.lime : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isToday ? AppColors.lime : AppColors.border,
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.$1,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: isToday ? Colors.black : AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.$2,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isToday
                            ? Colors.black.withOpacity(0.62)
                            : isRest
                                ? AppColors.textTertiary
                                : AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: plan.length,
      ),
    );
  }
}

class _TodayExerciseCard extends StatelessWidget {
  const _TodayExerciseCard({
    required this.exercise,
    required this.accent,
    required this.label,
    required this.onComplete,
  });

  final GymExercise exercise;
  final Color accent;
  final String label;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 17,
                            letterSpacing: 0.2,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _exerciseSubtitle(exercise),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: accent,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatChip(value: '${exercise.targetSets}', label: 'Sets'),
              _StatChip(value: exercise.repRange, label: 'Reps'),
              _StatChip(value: _formatLoad(exercise.loadKg), label: 'Weight'),
              _StatChip(value: '${exercise.restSeconds}s', label: 'Rest'),
            ],
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.tonal(
              onPressed: onComplete,
              style: FilledButton.styleFrom(
                backgroundColor: exercise.isCompleted
                    ? AppColors.limeDim
                    : AppColors.surfaceAlt,
                foregroundColor: exercise.isCompleted
                    ? AppColors.lime
                    : AppColors.textPrimary,
                side: BorderSide(
                  color: exercise.isCompleted
                      ? AppColors.lime.withOpacity(0.22)
                      : AppColors.border,
                ),
              ),
              child: Text(
                  exercise.isCompleted ? 'Marked Complete' : 'Mark Complete'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

String _formatLongDate(String value) {
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

  return '${weekdays[date.weekday - 1]} · ${months[date.month - 1]} ${date.day}, ${date.year}';
}

double _safeProgress(int current, int goal) {
  if (goal <= 0) {
    return 0;
  }

  return (current / goal).clamp(0, 1).toDouble();
}

Color _accentForExercise(GymExercise exercise, int index) {
  final label = _labelForExercise(exercise);
  if (label == 'Compound') {
    return index.isEven ? AppColors.cyan : AppColors.violet;
  }

  return switch (index % 3) {
    0 => AppColors.lime,
    1 => AppColors.amber,
    _ => AppColors.rose,
  };
}

String _labelForExercise(GymExercise exercise) {
  final name = exercise.name.toLowerCase();
  const compoundKeywords = ['press', 'squat', 'deadlift', 'row', 'pull-up'];
  return compoundKeywords.any(name.contains) ? 'Compound' : 'Isolation';
}

String _exerciseSubtitle(GymExercise exercise) {
  final label = _labelForExercise(exercise);
  return label == 'Compound' ? 'Primary movement' : 'Accessory finisher';
}

String _formatLoad(double loadKg) {
  if (loadKg <= 0) {
    return 'Body';
  }

  return loadKg.truncateToDouble() == loadKg
      ? '${loadKg.toInt()} kg'
      : '${loadKg.toStringAsFixed(1)} kg';
}
