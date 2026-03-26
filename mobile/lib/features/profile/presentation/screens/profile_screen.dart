import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/theme.dart';
import '../../../../shared/widgets/feature_placeholder_card.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/app_user.dart';
import '../../data/user_repository.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionUser = ref.watch(currentUserProvider);
    final user = ref.watch(currentAppUserProvider).valueOrNull ?? sessionUser;

    if (user == null) {
      return ListView(
        padding: EdgeInsets.all(16),
        children: [
          FeaturePlaceholderCard(
            title: 'Profile',
            subtitle: 'Sign in to load your striker identity and progression.',
            badge: 'Guest',
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _ProfileHero(user: user),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
          child: _SectionTitle(
            title: 'Power Stats',
            actionLabel: 'LVL ${user.level}',
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: _StatsGrid(user: user),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: _SectionTitle(
            title: 'Lifetime Progress',
            actionLabel: user.title.toUpperCase(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: _LifetimePanel(user: user),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: _SectionTitle(
            title: 'Settings',
            actionLabel: 'ACCOUNT',
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: _SettingsPanel(),
        ),
      ],
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.user});

  final AppUser user;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.violet, AppColors.cyan],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: Text(
                  _initialsFor(user.displayName),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName.toUpperCase(),
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${user.title}  •  ${user.username}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _StatusBadge(
                label: 'LEVEL ${user.level}',
                color: AppColors.lime,
                background: AppColors.limeDim,
              ),
              _StatusBadge(
                label: '${user.streak} DAY STREAK',
                color: AppColors.amber,
                background: AppColors.amberDim,
              ),
              _StatusBadge(
                label: '${user.territoryCaptures} CAPTURES',
                color: AppColors.cyan,
                background: AppColors.cyanDim,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _StatTile(
          label: 'Workouts',
          value: '${user.workoutsCompleted}',
          accent: AppColors.lime,
        ),
        _StatTile(
          label: 'Captures',
          value: '${user.territoryCaptures}',
          accent: AppColors.cyan,
        ),
        _StatTile(
          label: 'Distance',
          value: '${(user.totalDistance / 1000).toStringAsFixed(1)} km',
          accent: AppColors.violet,
        ),
        _StatTile(
          label: 'Area',
          value: '${(user.totalArea / 1000000).toStringAsFixed(1)} km²',
          accent: AppColors.amber,
        ),
      ],
    );
  }
}

class _LifetimePanel extends StatelessWidget {
  const _LifetimePanel({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You are building a hybrid fitness profile: consistent gym work, logged nutrition, and expanding territory control.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          _ProgressRow(
            label: 'Territory Dominance',
            value: '${(user.totalArea / 1000000).toStringAsFixed(1)} km²',
            progress: _progress(user.totalArea.toDouble(), 6000000),
            color: AppColors.lime,
          ),
          const SizedBox(height: 12),
          _ProgressRow(
            label: 'Distance Logged',
            value: '${(user.totalDistance / 1000).toStringAsFixed(1)} km',
            progress: _progress(user.totalDistance.toDouble(), 100000),
            color: AppColors.cyan,
          ),
          const SizedBox(height: 12),
          _ProgressRow(
            label: 'Workout Mastery',
            value: '${user.workoutsCompleted}',
            progress: _progress(user.workoutsCompleted.toDouble(), 120),
            color: AppColors.amber,
          ),
        ],
      ),
    );
  }
}

class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderStrong),
      ),
      child: const Column(
        children: [
          _SettingRow(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Goals, clan alerts, and event reminders',
          ),
          _SettingRow(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy',
            subtitle: 'Map visibility and public leaderboard controls',
          ),
          _SettingRow(
            icon: Icons.workspace_premium_outlined,
            title: 'Membership',
            subtitle: 'Battle pass and premium account perks',
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

class _StatTile extends StatelessWidget {
  const _StatTile({
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

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.label,
    required this.value,
    required this.progress,
    required this.color,
  });

  final String label;
  final String value;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label.toUpperCase(),
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: AppColors.surfaceMuted,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: AppColors.lime, size: 20),
      ),
      title: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textSecondary,
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

String _initialsFor(String value) {
  final parts = value
      .split(' ')
      .where((part) => part.trim().isNotEmpty)
      .map((part) => part.trim())
      .toList();

  if (parts.isEmpty) {
    return 'FS';
  }

  if (parts.length == 1) {
    final end = parts.first.length >= 2 ? 2 : parts.first.length;
    return parts.first.substring(0, end).toUpperCase();
  }

  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}

double _progress(double current, double goal) {
  if (goal <= 0) {
    return 0;
  }

  return (current / goal).clamp(0, 1).toDouble();
}
