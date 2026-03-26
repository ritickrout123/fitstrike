import 'social_hub_data.dart';

class ChannelMessagesResponse {
  const ChannelMessagesResponse({
    required this.channel,
    required this.messages,
  });

  final ChannelPreview channel;
  final List<ChannelMessage> messages;
}

class ChannelMessage {
  const ChannelMessage({
    required this.id,
    required this.type,
    required this.content,
    required this.timestamp,
    required this.sender,
    required this.isCurrentUser,
  });

  final String id;
  final String type;
  final String content;
  final String timestamp;
  final ChannelMessageSender? sender;
  final bool isCurrentUser;

  factory ChannelMessage.fromJson(Map<String, dynamic> json) {
    return ChannelMessage(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? '',
      content: json['content'] as String? ?? '',
      timestamp: json['timestamp'] as String? ?? '',
      sender: json['sender'] == null
          ? null
          : ChannelMessageSender.fromJson(
              Map<String, dynamic>.from(json['sender'] as Map),
            ),
      isCurrentUser: json['isCurrentUser'] as bool? ?? false,
    );
  }
}

class ChannelMessageSender {
  const ChannelMessageSender({
    required this.id,
    required this.displayName,
    required this.level,
    required this.title,
  });

  final String id;
  final String displayName;
  final int level;
  final String title;

  factory ChannelMessageSender.fromJson(Map<String, dynamic> json) {
    return ChannelMessageSender(
      id: json['id'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      level: json['level'] as int? ?? 0,
      title: json['title'] as String? ?? '',
    );
  }
}
