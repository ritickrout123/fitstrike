import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import 'leaderboard_entry.dart';

final leaderboardRepositoryProvider = Provider<LeaderboardRepository>((ref) {
  return LeaderboardRepository(ref.read(apiClientProvider));
});

final globalLeaderboardProvider =
    FutureProvider<List<LeaderboardEntry>>((ref) async {
  final session = ref.watch(authControllerProvider).session;
  if (session == null) {
    return const [];
  }

  return ref
      .read(leaderboardRepositoryProvider)
      .fetchGlobalLeaderboard(token: session.token);
});

class LeaderboardRepository {
  const LeaderboardRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<LeaderboardEntry>> fetchGlobalLeaderboard(
      {required String token}) async {
    final json = await _apiClient.getJson('/territories/leaderboards/global',
        token: token);
    return (json['rankings'] as List? ?? const [])
        .map((entry) =>
            LeaderboardEntry.fromJson(Map<String, dynamic>.from(entry as Map)))
        .toList();
  }
}
