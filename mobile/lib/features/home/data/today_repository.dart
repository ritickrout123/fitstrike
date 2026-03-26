import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import 'today_snapshot.dart';

final todayRepositoryProvider = Provider<TodayRepository>((ref) {
  return TodayRepository(ref.read(apiClientProvider));
});

final todaySnapshotProvider = FutureProvider<TodaySnapshot?>((ref) async {
  final session = ref.watch(authControllerProvider).session;

  if (session == null) {
    return null;
  }

  return ref.read(todayRepositoryProvider).fetchToday(token: session.token);
});

class TodayRepository {
  const TodayRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<TodaySnapshot> fetchToday({required String token}) async {
    final json = await _apiClient.getJson('/users/me/today', token: token);
    return TodaySnapshot.fromJson(json);
  }
}
