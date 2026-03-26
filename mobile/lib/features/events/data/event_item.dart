class EventItem {
  const EventItem({
    required this.id,
    required this.type,
    required this.status,
    required this.title,
    required this.subtitle,
    required this.rewardTag,
    required this.isRegistered,
  });

  final String id;
  final String type;
  final String status;
  final String title;
  final String subtitle;
  final String rewardTag;
  final bool isRegistered;

  factory EventItem.fromJson(Map<String, dynamic> json) {
    return EventItem(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? '',
      status: json['status'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      rewardTag: json['rewardTag'] as String? ?? '',
      isRegistered: json['isRegistered'] as bool? ?? false,
    );
  }
}
