import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import 'channel_message.dart';
import 'social_hub_data.dart';

final socialRepositoryProvider = Provider<SocialRepository>((ref) {
  return SocialRepository(ref.read(apiClientProvider));
});

final socialHubProvider = FutureProvider<SocialHubData?>((ref) async {
  final session = ref.watch(authControllerProvider).session;
  if (session == null) {
    return null;
  }

  return ref
      .read(socialRepositoryProvider)
      .fetchSocialHub(token: session.token);
});

class SocialRepository {
  const SocialRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<SocialHubData> fetchSocialHub({required String token}) async {
    final clanJson = await _apiClient.getJson('/social/clans/me', token: token);
    final channelsJson =
        await _apiClient.getJson('/social/channels', token: token);

    final clanMap = clanJson['clan'] == null
        ? null
        : ClanOverview.fromJson(
            Map<String, dynamic>.from(clanJson['clan'] as Map));
    final channels = (channelsJson['channels'] as List? ?? const [])
        .map((entry) =>
            ChannelPreview.fromJson(Map<String, dynamic>.from(entry as Map)))
        .toList();

    return SocialHubData(
      clan: clanMap,
      channels: channels,
    );
  }

  Future<ChannelMessagesResponse> fetchChannelMessages({
    required String token,
    required String channelId,
  }) async {
    final json = await _apiClient
        .getJson('/social/channels/$channelId/messages', token: token);
    final channel = ChannelPreview.fromJson(
      Map<String, dynamic>.from(json['channel'] as Map? ?? const {}),
    );
    final messages = (json['messages'] as List? ?? const [])
        .map((entry) =>
            ChannelMessage.fromJson(Map<String, dynamic>.from(entry as Map)))
        .toList();

    return ChannelMessagesResponse(channel: channel, messages: messages);
  }

  Future<ChannelMessage> sendMessage({
    required String token,
    required String channelId,
    required String content,
  }) async {
    final json = await _apiClient.postJson(
      '/social/channels/$channelId/messages',
      token: token,
      body: {
        'type': 'text',
        'content': content,
      },
    );

    return ChannelMessage.fromJson(
        Map<String, dynamic>.from(json['message'] as Map));
  }
}
