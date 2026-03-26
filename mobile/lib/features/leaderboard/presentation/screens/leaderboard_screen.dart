import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/theme.dart';
import '../../../../shared/widgets/feature_placeholder_card.dart';
import '../../data/leaderboard_entry.dart';
import '../../data/leaderboard_repository.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(globalLeaderboardProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: leaderboardAsync.when(
          data: (entries) => ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
            children: [
              _RouteHeader(
                title: 'Global Ranks',
                subtitle:
                    'See who owns the most ground and where your run stack lands today.',
                onBack: () => context.go('/app'),
              ),
              const SizedBox(height: 16),
              _LeaderboardHero(entries: entries),
              const SizedBox(height: 20),
              _SectionTitle(
                title: 'Live Board',
                actionLabel: '${entries.length} STRIKERS',
              ),
              const SizedBox(height: 12),
              for (final entry in entries) ...[
                _LeaderboardRow(entry: entry),
                const SizedBox(height: 10),
              ],
            ],
          ),
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: FeaturePlaceholderCard(
                title: 'Global Ranks',
                subtitle: 'Loading the live territory leaderboard...',
              ),
            ),
          ),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FeaturePlaceholderCard(
                title: 'Global Ranks',
                subtitle: error.toString(),
                badge: 'Error',
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RouteHeader extends StatelessWidget {
  const _RouteHeader({
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

  final String title;
  final String subtitle;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onBack,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderStrong),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LeaderboardHero extends StatelessWidget {
  const _LeaderboardHero({required this.entries});

  final List<LeaderboardEntry> entries;

  @override
  Widget build(BuildContext context) {
    LeaderboardEntry? currentUser;
    for (final entry in entries) {
      if (entry.isCurrentUser) {
        currentUser = entry;
        break;
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.backgroundAlt2,
            AppColors.backgroundAlt,
          ],
        ),
        border: Border.all(color: AppColors.borderStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Push territory totals higher and climb the board with every logged route.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _HeroMetric(
                  label: 'Your Rank',
                  value: currentUser == null ? '--' : '#${currentUser.rank}',
                  accent: AppColors.lime,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeroMetric(
                  label: 'Owned Area',
                  value: currentUser == null
                      ? '--'
                      : '${currentUser.scoreKm2} km²',
                  accent: AppColors.cyan,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({required this.entry});

  final LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    final accent = _accentForRank(entry.rank);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: entry.isCurrentUser ? AppColors.limeDim : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: entry.isCurrentUser ? AppColors.lime : AppColors.borderStrong,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              '${entry.rank}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.displayName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Lvl ${entry.level} • ${entry.title}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Text(
            '${entry.scoreKm2} km²',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: entry.isCurrentUser
                      ? AppColors.lime
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
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

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
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
    );
  }
}

Color _accentForRank(int rank) {
  switch (rank) {
    case 1:
      return AppColors.lime;
    case 2:
      return AppColors.cyan;
    case 3:
      return AppColors.amber;
    default:
      return AppColors.violet;
  }
}
