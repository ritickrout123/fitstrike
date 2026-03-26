import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/theme.dart';
import '../../../../shared/widgets/feature_placeholder_card.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/channel_message.dart';
import '../../data/social_hub_data.dart';
import '../../data/social_repository.dart';

final channelMessagesProvider =
    FutureProvider.family<ChannelMessagesResponse?, String>(
        (ref, channelId) async {
  final session = ref.watch(authControllerProvider).session;
  if (session == null) {
    return null;
  }

  return ref.read(socialRepositoryProvider).fetchChannelMessages(
        token: session.token,
        channelId: channelId,
      );
});

class CommsScreen extends ConsumerStatefulWidget {
  const CommsScreen({super.key});

  @override
  ConsumerState<CommsScreen> createState() => _CommsScreenState();
}

class _CommsScreenState extends ConsumerState<CommsScreen> {
  String? _selectedChannelId;
  late final TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authControllerProvider).session;
    final socialAsync = ref.watch(socialHubProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: socialAsync.when(
          data: (social) {
            final channels = social?.channels ?? const <ChannelPreview>[];
            if (_selectedChannelId == null && channels.isNotEmpty) {
              _selectedChannelId = channels.first.id;
            }

            final selectedChannelId = _selectedChannelId;
            final channelMessagesAsync =
                selectedChannelId == null || session == null
                    ? const AsyncValue<ChannelMessagesResponse?>.data(null)
                    : ref.watch(channelMessagesProvider(selectedChannelId));

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                  child: _RouteHeader(
                    title: 'Clan Comms',
                    subtitle:
                        'Coordinate runs, react fast, and keep every squad thread alive.',
                    onBack: () => context.go('/app'),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 48,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: channels.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final channel = channels[index];
                      final isSelected = channel.id == selectedChannelId;

                      return _ChannelTab(
                        channel: channel,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            _selectedChannelId = channel.id;
                          });
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.borderStrong),
                      ),
                      child: channelMessagesAsync.when(
                        data: (data) {
                          final messages =
                              data?.messages ?? const <ChannelMessage>[];
                          if (messages.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: FeaturePlaceholderCard(
                                  title: 'No Messages',
                                  subtitle:
                                      'Jump into a live channel to start the conversation.',
                                ),
                              ),
                            );
                          }

                          return ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: messages.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final message = messages[index];

                              if (message.type == 'system') {
                                return Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.roseDim,
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(color: AppColors.rose),
                                    ),
                                    child: Text(
                                      message.content,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(
                                            color: AppColors.rose,
                                          ),
                                    ),
                                  ),
                                );
                              }

                              return Align(
                                alignment: message.isCurrentUser
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: _MessageBubble(message: message),
                              );
                            },
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (error, _) => Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              error.toString(),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: const InputDecoration(
                              hintText: 'Transmit to squad...',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        FilledButton(
                          onPressed: selectedChannelId == null ||
                                  session == null
                              ? null
                              : () async {
                                  final text = _messageController.text.trim();
                                  if (text.isEmpty) {
                                    return;
                                  }

                                  try {
                                    await ref
                                        .read(socialRepositoryProvider)
                                        .sendMessage(
                                          token: session.token,
                                          channelId: selectedChannelId,
                                          content: text,
                                        );
                                    _messageController.clear();
                                    ref.invalidate(socialHubProvider);
                                    ref.invalidate(channelMessagesProvider(
                                        selectedChannelId));
                                  } catch (error) {
                                    if (!context.mounted) {
                                      return;
                                    }

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(error.toString())),
                                    );
                                  }
                                },
                          child: const Text('SEND'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: FeaturePlaceholderCard(
                title: 'Clan Comms',
                subtitle: 'Loading active channels and messages...',
              ),
            ),
          ),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FeaturePlaceholderCard(
                title: 'Clan Comms',
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

class _ChannelTab extends StatelessWidget {
  const _ChannelTab({
    required this.channel,
    required this.isSelected,
    required this.onTap,
  });

  final ChannelPreview channel;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.lime : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.lime : AppColors.borderStrong,
          ),
        ),
        child: Row(
          children: [
            Text(
              channel.name.toUpperCase(),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: isSelected ? Colors.black : AppColors.textPrimary,
                  ),
            ),
            if (channel.unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black : AppColors.limeDim,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${channel.unreadCount}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isSelected ? AppColors.lime : AppColors.lime,
                      ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChannelMessage message;

  @override
  Widget build(BuildContext context) {
    final background =
        message.isCurrentUser ? AppColors.limeDim : AppColors.surfaceMuted;
    final border =
        message.isCurrentUser ? AppColors.lime : AppColors.borderStrong;

    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.sender != null) ...[
            Text(
              '${message.sender!.displayName} • Lvl ${message.sender!.level}',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color:
                        message.isCurrentUser ? AppColors.lime : AppColors.cyan,
                  ),
            ),
            const SizedBox(height: 6),
          ],
          Text(
            message.content,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textPrimary,
                ),
          ),
        ],
      ),
    );
  }
}
