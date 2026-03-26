class SocialHubData {
  const SocialHubData({
    required this.clan,
    required this.channels,
  });

  final ClanOverview? clan;
  final List<ChannelPreview> channels;
}

class ClanOverview {
  const ClanOverview({
    required this.name,
    required this.tag,
    required this.level,
    required this.rank,
    required this.memberCount,
    required this.maxMembers,
    required this.warTitle,
    required this.warStatus,
    required this.xpBoost,
    required this.roster,
  });

  final String name;
  final String tag;
  final int level;
  final int rank;
  final int memberCount;
  final int maxMembers;
  final String warTitle;
  final String warStatus;
  final String xpBoost;
  final List<ClanRosterMember> roster;

  factory ClanOverview.fromJson(Map<String, dynamic> json) {
    final war = Map<String, dynamic>.from(json['war'] as Map? ?? const {});
    final roster = (json['roster'] as List? ?? const [])
        .map((entry) =>
            ClanRosterMember.fromJson(Map<String, dynamic>.from(entry as Map)))
        .toList();

    return ClanOverview(
      name: json['name'] as String? ?? '',
      tag: json['tag'] as String? ?? '',
      level: json['level'] as int? ?? 0,
      rank: json['rank'] as int? ?? 0,
      memberCount: json['memberCount'] as int? ?? 0,
      maxMembers: json['maxMembers'] as int? ?? 0,
      warTitle: war['title'] as String? ?? '',
      warStatus: war['status'] as String? ?? '',
      xpBoost: war['xpBoost'] as String? ?? '',
      roster: roster,
    );
  }
}

class ClanRosterMember {
  const ClanRosterMember({
    required this.displayName,
    required this.level,
    required this.title,
    required this.role,
    required this.contribution,
    required this.status,
  });

  final String displayName;
  final int level;
  final String title;
  final String role;
  final String contribution;
  final String status;

  factory ClanRosterMember.fromJson(Map<String, dynamic> json) {
    return ClanRosterMember(
      displayName: json['displayName'] as String? ?? '',
      level: json['level'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      role: json['role'] as String? ?? '',
      contribution: json['contribution'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }
}

class ChannelPreview {
  const ChannelPreview({
    required this.id,
    required this.type,
    required this.name,
    required this.unreadCount,
    required this.preview,
  });

  final String id;
  final String type;
  final String name;
  final int unreadCount;
  final String preview;

  factory ChannelPreview.fromJson(Map<String, dynamic> json) {
    return ChannelPreview(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? '',
      name: json['name'] as String? ?? '',
      unreadCount: json['unreadCount'] as int? ?? 0,
      preview: json['preview'] as String? ?? '',
    );
  }
}
