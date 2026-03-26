import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/theme.dart';
import '../../../../shared/widgets/feature_placeholder_card.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/event_item.dart';
import '../../data/events_repository.dart';

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsProvider);
    final session = ref.watch(authControllerProvider).session;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: eventsAsync.when(
          data: (events) => ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
            children: [
              _RouteHeader(
                title: 'Live Events',
                subtitle:
                    'Join drops, squad tournaments, and community activations.',
                onBack: () => context.go('/app'),
              ),
              const SizedBox(height: 16),
              _EventsHero(events: events),
              const SizedBox(height: 20),
              _SectionTitle(
                title: 'Event Queue',
                actionLabel: '${events.length} LIVE',
              ),
              const SizedBox(height: 12),
              for (final event in events) ...[
                _EventCard(
                  event: event,
                  onRegister: event.isRegistered || session == null
                      ? null
                      : () async {
                          try {
                            await ref
                                .read(eventsRepositoryProvider)
                                .registerForEvent(
                                  token: session.token,
                                  eventId: event.id,
                                );
                            ref.invalidate(eventsProvider);

                            if (!context.mounted) {
                              return;
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Registered for ${event.title}.'),
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
                const SizedBox(height: 12),
              ],
            ],
          ),
          loading: () => const Center(
            child: FeaturePlaceholderCard(
              title: 'Live Events',
              subtitle: 'Loading upcoming live events...',
            ),
          ),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FeaturePlaceholderCard(
                title: 'Live Events',
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

class _EventsHero extends StatelessWidget {
  const _EventsHero({required this.events});

  final List<EventItem> events;

  @override
  Widget build(BuildContext context) {
    final registeredCount = events.where((event) => event.isRegistered).length;

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
            'Drop into limited-time challenges and keep your account progression moving.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _HeroMetric(
                  label: 'Active',
                  value: '${events.length}',
                  accent: AppColors.lime,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeroMetric(
                  label: 'Registered',
                  value: '$registeredCount',
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

class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.event,
    required this.onRegister,
  });

  final EventItem event;
  final VoidCallback? onRegister;

  @override
  Widget build(BuildContext context) {
    final accent = _accentForType(event.type);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: event.isRegistered ? AppColors.lime : AppColors.borderStrong,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _StatusBadge(
                label: event.type.toUpperCase(),
                color: accent,
                background: accent.withValues(alpha: 0.12),
              ),
              const SizedBox(width: 8),
              _StatusBadge(
                label: event.status.toUpperCase(),
                color: AppColors.textSecondary,
                background: AppColors.surfaceMuted,
              ),
              const Spacer(),
              Text(
                event.rewardTag,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.lime,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            event.title.toUpperCase(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            event.subtitle,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onRegister,
              child: Text(event.isRegistered ? 'REGISTERED' : 'REGISTER NOW'),
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
        border: Border.all(color: color.withValues(alpha: 0.2)),
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

Color _accentForType(String type) {
  switch (type) {
    case 'squad':
      return AppColors.cyan;
    case 'clan':
      return AppColors.violet;
    default:
      return AppColors.amber;
  }
}
