import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import 'gym_plan.dart';

final gymRepositoryProvider = Provider<GymRepository>((ref) {
  return GymRepository(ref.read(apiClientProvider));
});

final gymPlanProvider = FutureProvider<GymPlan?>((ref) async {
  final session = ref.watch(authControllerProvider).session;
  if (session == null) {
    return null;
  }

  return ref.read(gymRepositoryProvider).fetchGymPlan(token: session.token);
});

class GymRepository {
  const GymRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<GymPlan> fetchGymPlan({required String token}) async {
    final json = await _apiClient.getJson('/users/me/gym-plan', token: token);
    return GymPlan.fromJson(json);
  }

  Future<GymCompletionResult> completeExercise({
    required String token,
    required String exerciseId,
  }) async {
    final json = await _apiClient.postJson(
      '/users/me/gym-plan/exercises/$exerciseId/complete',
      token: token,
      body: const {},
    );

    return GymCompletionResult.fromJson(json);
  }
}
