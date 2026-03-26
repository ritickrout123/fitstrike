import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import 'event_item.dart';

final eventsRepositoryProvider = Provider<EventsRepository>((ref) {
  return EventsRepository(ref.read(apiClientProvider));
});

final eventsProvider = FutureProvider<List<EventItem>>((ref) async {
  final session = ref.watch(authControllerProvider).session;
  if (session == null) {
    return const [];
  }

  return ref.read(eventsRepositoryProvider).fetchEvents(token: session.token);
});

class EventsRepository {
  const EventsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<EventItem>> fetchEvents({required String token}) async {
    final json = await _apiClient.getJson('/events', token: token);
    final events = (json['events'] as List? ?? const [])
        .map((entry) =>
            EventItem.fromJson(Map<String, dynamic>.from(entry as Map)))
        .toList();

    return events;
  }

  Future<EventItem> registerForEvent({
    required String token,
    required String eventId,
  }) async {
    final json = await _apiClient.postJson(
      '/events/$eventId/register',
      token: token,
      body: const {},
    );

    return EventItem.fromJson(Map<String, dynamic>.from(json['event'] as Map));
  }
}
