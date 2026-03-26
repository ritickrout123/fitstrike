import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/theme.dart';
import '../../../../shared/widgets/feature_placeholder_card.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../home/data/today_repository.dart';
import '../../../profile/data/user_repository.dart';
import '../../data/gym_plan.dart';
import '../../data/gym_repository.dart';

class GymPlanScreen extends ConsumerWidget {
  const GymPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gymAsync = ref.watch(gymPlanProvider);
    final session = ref.watch(authControllerProvider).session;

    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        gymAsync.when(
          data: (plan) {
            if (plan == null) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: FeaturePlaceholderCard(
                  title: 'Program Split',
                  subtitle:
                      'Log in to load today\'s workout and progression state.',
                  badge: 'Locked',
                ),
              );
            }

            return _GymHero(plan: plan);
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: FeaturePlaceholderCard(
              title: 'Program Split',
              subtitle: 'Loading your workout plan...',
            ),
          ),
          error: (error, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: FeaturePlaceholderCard(
              title: 'Program Split',
              subtitle: error.toString(),
            ),
          ),
        ),
        const SizedBox(height: 14),
        const _WeekGrid(),
        const SizedBox(height: 14),
        const _SplitTabs(),
        const SizedBox(height: 14),
        gymAsync.when(
          data: (plan) {
            if (plan == null) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  for (var index = 0; index < plan.exercises.length; index++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ExercisePlanCard(
                        exercise: plan.exercises[index],
                        accent: _exerciseAccent(plan.exercises[index], index),
                        label: _exerciseLabel(plan.exercises[index]),
                        onComplete: session == null ||
                                plan.exercises[index].isCompleted
                            ? null
                            : () async {
                                try {
                                  final result = await ref
                                      .read(gymRepositoryProvider)
                                      .completeExercise(
                                        token: session.token,
                                        exerciseId: plan.exercises[index].id,
                                      );
                                  ref.invalidate(gymPlanProvider);
                                  ref.invalidate(todaySnapshotProvider);
                                  ref.invalidate(currentAppUserProvider);

                                  if (!context.mounted) {
                                    return;
                                  }

                                  final message = result.isWorkoutComplete
                                      ? '${plan.exercises[index].name} complete. Session cleared.'
                                      : '${plan.exercises[index].name} complete. ${result.completedExerciseCount}/${result.exerciseCount} done.';

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(message)),
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
                    ),
                ],
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _GymHero extends StatelessWidget {
  const _GymHero({required this.plan});

  final GymPlan plan;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF110D19),
            Color(0xFF0A0A14),
          ],
        ),
        border: Border.all(color: AppColors.borderStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Week 8 of 12',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 1.2,
                ),
          ),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.displaySmall,
              children: const [
                TextSpan(text: 'PPL '),
                TextSpan(
                  text: 'SPLIT',
                  style: TextStyle(color: AppColors.lime),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _PlanMeta(
                color: AppColors.lime,
                label: 'Push · Pull · Legs',
              ),
              _PlanMeta(
                color: AppColors.cyan,
                label: '${plan.exerciseCount} exercises',
              ),
              const _PlanMeta(
                color: AppColors.amber,
                label: 'Hypertrophy',
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '${plan.label} · ${plan.focus}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _PlanMeta extends StatelessWidget {
  const _PlanMeta({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
              ),
        ),
      ],
    );
  }
}

class _WeekGrid extends StatelessWidget {
  const _WeekGrid();

  @override
  Widget build(BuildContext context) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (var index = 0; index < days.length; index++)
            Expanded(
              child: Container(
                margin:
                    EdgeInsets.only(right: index == days.length - 1 ? 0 : 8),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: index == 2
                      ? AppColors.lime
                      : index == 0 || index == 1
                          ? AppColors.surfaceAlt
                          : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: index == 2 ? AppColors.lime : AppColors.border,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      days[index],
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: index == 2
                                ? Colors.black
                                : AppColors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: index == 2
                            ? Colors.black
                            : index == 0 || index == 1
                                ? AppColors.lime
                                : AppColors.textTertiary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SplitTabs extends StatelessWidget {
  const _SplitTabs();

  @override
  Widget build(BuildContext context) {
    const tabs = ['PUSH — WED', 'PULL — FRI', 'LEGS — SUN'];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final active = index == 0;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: active ? AppColors.lime : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: active ? AppColors.lime : AppColors.border,
              ),
            ),
            child: Text(
              tabs[index],
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: active ? Colors.black : AppColors.textSecondary,
                  ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: tabs.length,
      ),
    );
  }
}

class _ExercisePlanCard extends StatelessWidget {
  const _ExercisePlanCard({
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
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
                            letterSpacing: 0.3,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _exerciseDescription(exercise),
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
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: accent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetricChip(value: '${exercise.targetSets}', label: 'Sets'),
              _MetricChip(value: exercise.repRange, label: 'Reps'),
              _MetricChip(value: _formatLoad(exercise.loadKg), label: 'Weight'),
              _MetricChip(value: '${exercise.restSeconds}s', label: 'Rest'),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _formCue(exercise),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
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
                      ? AppColors.lime.withOpacity(0.24)
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

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 74,
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

Color _exerciseAccent(GymExercise exercise, int index) {
  final label = _exerciseLabel(exercise);
  if (label == 'Compound') {
    return index.isEven ? AppColors.cyan : AppColors.violet;
  }

  return switch (index % 3) {
    0 => AppColors.lime,
    1 => AppColors.amber,
    _ => AppColors.rose,
  };
}

String _exerciseLabel(GymExercise exercise) {
  final name = exercise.name.toLowerCase();
  const compoundKeywords = ['press', 'squat', 'deadlift', 'row', 'pull-up'];
  return compoundKeywords.any(name.contains) ? 'Compound' : 'Isolation';
}

String _exerciseDescription(GymExercise exercise) {
  return _exerciseLabel(exercise) == 'Compound'
      ? 'Primary movement · progression lift'
      : 'Accessory movement · controlled volume';
}

String _formCue(GymExercise exercise) {
  final name = exercise.name.toLowerCase();

  if (name.contains('press')) {
    return 'Form cue: Brace hard, keep the path controlled, and drive through a full lockout without flaring early.';
  }

  if (name.contains('raise')) {
    return 'Form cue: Lead with elbows, stay smooth on the lowering phase, and stop when tension drops.';
  }

  return 'Form cue: Stay controlled, keep constant tension, and make each rep look the same from start to finish.';
}

String _formatLoad(double loadKg) {
  if (loadKg <= 0) {
    return 'Body';
  }

  return loadKg.truncateToDouble() == loadKg
      ? '${loadKg.toInt()} kg'
      : '${loadKg.toStringAsFixed(1)} kg';
}
