import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/theme.dart';
import '../../../../shared/widgets/feature_placeholder_card.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../home/data/today_repository.dart';
import '../../../profile/data/user_repository.dart';
import '../../../../shared/animations/fade_slide_in.dart';
import '../../../../shared/animations/screen_shake.dart';
import '../../../../shared/animations/capture_result_overlay.dart';
import '../../../../shared/animations/level_up_overlay.dart';
import '../../../../shared/animations/floating_label_service.dart';
import '../../../../core/animations/animation_constants.dart';
import '../../data/run_overview.dart';
import '../../data/run_repository.dart';
import '../../../home/data/today_repository.dart';
class TerritoryRunScreen extends ConsumerWidget {
  const TerritoryRunScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runAsync = ref.watch(runOverviewProvider);
    final session = ref.watch(authControllerProvider).session;
    final shakeKey = GlobalKey<ScreenShakeState>();

    return runAsync.when(
      data: (overview) {
        if (overview == null) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              FadeSlideIn(
                child: FeaturePlaceholderCard(
                  title: 'Territory Run',
                  subtitle:
                      'Run missions, live map metrics, and capture controls unlock after sign in.',
                  badge: 'Locked',
                ),
              ),
            ],
          );
        }

        return ScreenShake(
          key: shakeKey,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              FadeSlideIn(
                duration: AppAnimations.slow,
                child: _RunHero(
                  overview: overview,
                  onCapture: session == null
                      ? null
                      : () async {
                          try {
                            final result = await ref
                                .read(runRepositoryProvider)
                                .simulateCapture(token: session.token);
                            
                            // Trigger Effects
                            shakeKey.currentState?.shake();
                            
                            ref.invalidate(runOverviewProvider);
                            ref.invalidate(todaySnapshotProvider);
                            ref.invalidate(currentAppUserProvider);

                            if (!context.mounted) return;

                            // Show Floating Labels
                            final rb = context.findRenderObject() as RenderBox?;
                            final center = rb != null 
                                ? rb.localToGlobal(Offset(rb.size.width / 2, rb.size.height / 2))
                                : const Offset(200, 400);

                            ref.read(floatingLabelProvider.notifier).show(
                              '+${result.capturedArea} m²', 
                              AppColors.lime, 
                              center.translate(0, -40),
                            );

                            // Show Result Overlay
                            showDialog(
                              context: context,
                              barrierColor: Colors.black87,
                              builder: (context) => CaptureResultOverlay(
                                area: result.capturedArea.toDouble(),
                                xp: (result.capturedArea * 2).toInt(),
                                coins: (result.capturedArea / 10).toInt(),
                                onDismiss: () {
                                  Navigator.pop(context);
                                  // Mock Level Up Chance
                                  if (result.capturedArea > 80) {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) => LevelUpOverlay(
                                        level: 12,
                                        onDismiss: () => Navigator.pop(context),
                                      ),
                                    );
                                  }
                                },
                              ),
                            );
                          } catch (error) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(error.toString())),
                            );
                          }
                        },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                child: FadeSlideIn(
                  delay: const Duration(milliseconds: 100),
                  child: _SectionTitle(
                    title: 'Live Metrics',
                    actionLabel: '#${overview.globalRank} Global',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: FadeSlideIn(
                  delay: const Duration(milliseconds: 200),
                  child: _RunMetricGrid(overview: overview),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: FadeSlideIn(
                  delay: const Duration(milliseconds: 300),
                  child: _SectionTitle(
                    title: 'Map Overlay',
                    actionLabel: 'SIM LIVE',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: FadeSlideIn(
                  delay: const Duration(milliseconds: 400),
                  child: _MapPanel(overview: overview),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: FadeSlideIn(
                  delay: const Duration(milliseconds: 500),
                  child: _SectionTitle(
                    title: 'Daily Missions',
                    actionLabel: '+${overview.points} PTS',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  children: [
                    for (int i = 0; i < overview.missions.length; i++) ...[
                      FadeSlideIn(
                        delay: Duration(milliseconds: 600 + (i * 100)),
                        child: _MissionCard(mission: overview.missions[i]),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          FeaturePlaceholderCard(
            title: 'Territory Run',
            subtitle: 'Loading live run metrics and mission progress...',
            badge: 'Loading',
          ),
        ],
      ),
      error: (error, _) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FeaturePlaceholderCard(
            title: 'Territory Run',
            subtitle: error.toString(),
            badge: 'Error',
          ),
        ],
      ),
    );
  }
}

class _RunHero extends StatelessWidget {
  const _RunHero({
    required this.overview,
    required this.onCapture,
  });

  final RunOverview overview;
  final VoidCallback? onCapture;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.backgroundAlt2,
            AppColors.backgroundAlt,
            Color(0xFF0B0E16),
          ],
        ),
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -24,
            top: -32,
            child: Container(
              width: 170,
              height: 170,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0x22C8FF00),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.4,
                            ),
                        children: const [
                          TextSpan(text: 'TERRITORY '),
                          TextSpan(
                            text: 'RUN',
                            style: TextStyle(color: AppColors.lime),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _StatusBadge(
                    label: 'FIELD ACTIVE',
                    color: AppColors.lime,
                    background: AppColors.limeDim,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Conquer routes, lock your trail, and keep your squad ahead on the city board.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _HeroStat(
                    label: 'Distance',
                    value: '${overview.distanceKm.toStringAsFixed(1)} km',
                    accent: AppColors.lime,
                  ),
                  _HeroStat(
                    label: 'Pace',
                    value: overview.pace,
                    accent: AppColors.cyan,
                  ),
                  _HeroStat(
                    label: 'Calories',
                    value: '${overview.calories}',
                    accent: AppColors.amber,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onCapture,
                  child: const Text('SIMULATE CAPTURE'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RunMetricGrid extends StatelessWidget {
  const _RunMetricGrid({required this.overview});

  final RunOverview overview;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _MetricTile(
          label: 'Owned Area',
          value: '${overview.ownedAreaKm2.toStringAsFixed(1)} km²',
          accent: AppColors.lime,
        ),
        _MetricTile(
          label: 'Session Time',
          value: overview.duration,
          accent: AppColors.cyan,
        ),
        _MetricTile(
          label: 'Points Banked',
          value: '${overview.points}',
          accent: AppColors.violet,
        ),
        _MetricTile(
          label: 'Global Rank',
          value: '#${overview.globalRank}',
          accent: AppColors.rose,
        ),
      ],
    );
  }
}

class _MapPanel extends StatelessWidget {
  const _MapPanel({required this.overview});

  final RunOverview overview;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF151A27),
            Color(0xFF0A0E16),
          ],
        ),
        border: Border.all(color: AppColors.borderStrong),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const RadialGradient(
                  center: Alignment.topRight,
                  radius: 1.4,
                  colors: [
                    Color(0x1500E5FF),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 18,
            top: 30,
            child: _MapNode(
              color: AppColors.lime,
              label: 'YOU',
              size: 62,
            ),
          ),
          Positioned(
            right: 34,
            top: 52,
            child: _MapNode(
              color: AppColors.cyan,
              label: 'ZONE',
              size: 42,
            ),
          ),
          Positioned(
            left: 120,
            bottom: 52,
            child: _MapNode(
              color: AppColors.violet,
              label: 'BOOST',
              size: 48,
            ),
          ),
          const Positioned(
            left: 72,
            top: 72,
            child: _MapLine(
              width: 140,
              angle: 0.24,
            ),
          ),
          const Positioned(
            left: 136,
            top: 118,
            child: _MapLine(
              width: 96,
              angle: -0.58,
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LIVE TERRITORY FEED',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sweep loops to expand ${overview.ownedAreaKm2.toStringAsFixed(1)} km² of controlled ground.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _LegendItem(color: AppColors.lime, label: 'Owned'),
                    const SizedBox(width: 12),
                    _LegendItem(color: AppColors.cyan, label: 'Target'),
                    const SizedBox(width: 12),
                    _LegendItem(color: AppColors.violet, label: 'Boost'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({required this.mission});

  final RunMission mission;

  @override
  Widget build(BuildContext context) {
    final progress = mission.progress.clamp(0, 1).toDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  mission.label.toUpperCase(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        letterSpacing: 1.1,
                      ),
                ),
              ),
              _StatusBadge(
                label: '+${mission.reward} XP',
                color: AppColors.amber,
                background: AppColors.amberDim,
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.surfaceMuted,
              color: AppColors.lime,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).round()}% complete',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    this.actionLabel,
  });

  final String title;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  letterSpacing: 1.2,
                ),
          ),
        ),
        if (actionLabel != null)
          Text(
            actionLabel!,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.lime,
                ),
          ),
      ],
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 98),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 187,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderStrong),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.color,
    required this.background,
  });

  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
            ),
      ),
    );
  }
}

class _MapNode extends StatelessWidget {
  const _MapNode({
    required this.color,
    required this.label,
    required this.size,
  });

  final Color color;
  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.18),
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.18),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _MapLine extends StatelessWidget {
  const _MapLine({
    required this.width,
    required this.angle,
  });

  final double width;
  final double angle;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: width,
        height: 3,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: const LinearGradient(
            colors: [
              AppColors.lime,
              AppColors.cyan,
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
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
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }
}
