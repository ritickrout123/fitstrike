import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/theme.dart';
import '../../../../shared/widgets/feature_placeholder_card.dart';
import '../../data/social_hub_data.dart';
import '../../data/social_repository.dart';

class SocialHubScreen extends ConsumerWidget {
  const SocialHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final socialAsync = ref.watch(socialHubProvider);

    return socialAsync.when(
      data: (social) {
        final clan = social?.clan;
        final channels = social?.channels ?? const <ChannelPreview>[];

        if (clan == null) {
          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              FeaturePlaceholderCard(
                title: 'Clan Hub',
                subtitle:
                    'Clan operations, channel comms, squad boosts, and war tracking unlock after sign in.',
                badge: 'Locked',
              ),
            ],
          );
        }

        return ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            _ClanHero(
              clan: clan,
              onOpenComms: () => context.go('/app/comms'),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
              child: _SectionTitle(
                title: 'War Room',
                actionLabel: clan.warStatus.toUpperCase(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _WarPanel(clan: clan),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: _SectionTitle(
                title: 'Roster',
                actionLabel: '${clan.memberCount}/${clan.maxMembers}',
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                children: [
                  for (final member in clan.roster.take(4)) ...[
                    _RosterCard(member: member),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: _SectionTitle(
                title: 'Channels',
                actionLabel: '${channels.length} LIVE',
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                children: [
                  for (final channel in channels) ...[
                    _ChannelCard(channel: channel),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton(
                    onPressed: () => context.go('/app/comms'),
                    child: const Text('OPEN COMMS'),
                  ),
                  OutlinedButton(
                    onPressed: () => context.go('/app/leaderboard'),
                    child: const Text('VIEW RANKS'),
                  ),
                  OutlinedButton(
                    onPressed: () => context.go('/app/events'),
                    child: const Text('LIVE EVENTS'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
      loading: () => ListView(
        padding: EdgeInsets.all(16),
        children: [
          FeaturePlaceholderCard(
            title: 'Clan Hub',
            subtitle: 'Loading clan status, roster, and channels...',
          ),
        ],
      ),
      error: (error, _) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FeaturePlaceholderCard(
            title: 'Clan Hub',
            subtitle: error.toString(),
            badge: 'Error',
          ),
        ],
      ),
    );
  }
}

class _ClanHero extends StatelessWidget {
  const _ClanHero({
    required this.clan,
    required this.onOpenComms,
  });

  final ClanOverview clan;
  final VoidCallback onOpenComms;

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
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.lime, AppColors.cyan],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
                child: Text(
                  clan.tag.replaceAll('[', '').replaceAll(']', ''),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.black,
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
                      clan.name.toUpperCase(),
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${clan.tag}  •  LVL ${clan.level}  •  #${clan.rank}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Run coordinated territory pushes, keep your clan chat hot, and stack shared boosts.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _StatusBadge(
                label: '${clan.memberCount}/${clan.maxMembers} MEMBERS',
                color: AppColors.lime,
                background: AppColors.limeDim,
              ),
              _StatusBadge(
                label: clan.xpBoost.toUpperCase(),
                color: AppColors.cyan,
                background: AppColors.cyanDim,
              ),
              _StatusBadge(
                label: clan.warStatus.toUpperCase(),
                color: AppColors.amber,
                background: AppColors.amberDim,
              ),
            ],
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: onOpenComms,
            child: const Text('ENTER WAR ROOM'),
          ),
        ],
      ),
    );
  }
}

class _WarPanel extends StatelessWidget {
  const _WarPanel({required this.clan});

  final ClanOverview clan;

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
            clan.warTitle.toUpperCase(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Momentum is building. Keep squad check-ins high and rotate capture windows to stay ahead.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _InfoPill(
                  label: 'War Status',
                  value: clan.warStatus,
                  accent: AppColors.rose,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _InfoPill(
                  label: 'XP Boost',
                  value: clan.xpBoost,
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

class _RosterCard extends StatelessWidget {
  const _RosterCard({required this.member});

  final ClanRosterMember member;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderStrong),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.violetDim,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              _initialsFor(member.displayName),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.violet,
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
                  member.displayName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Lvl ${member.level} • ${member.title} • ${member.role}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                member.contribution,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.lime,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                member.status,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChannelCard extends StatelessWidget {
  const _ChannelCard({required this.channel});

  final ChannelPreview channel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderStrong),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.cyanDim,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(
              _iconForChannel(channel.type),
              color: AppColors.cyan,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        channel.name.toUpperCase(),
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                    ),
                    if (channel.unreadCount > 0)
                      _StatusBadge(
                        label: '${channel.unreadCount} NEW',
                        color: AppColors.lime,
                        background: AppColors.limeDim,
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  channel.preview,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
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

class _InfoPill extends StatelessWidget {
  const _InfoPill({
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
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
                ),
          ),
        ],
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
    return parts.first
        .substring(0, parts.first.length.clamp(0, 2))
        .toUpperCase();
  }

  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}

IconData _iconForChannel(String type) {
  switch (type) {
    case 'clan':
      return Icons.shield_rounded;
    case 'local':
      return Icons.location_on_rounded;
    default:
      return Icons.public_rounded;
  }
}
