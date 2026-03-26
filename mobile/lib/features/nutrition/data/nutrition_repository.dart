import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import 'nutrition_snapshot.dart';

final nutritionRepositoryProvider = Provider<NutritionRepository>((ref) {
  return NutritionRepository(ref.read(apiClientProvider));
});

final nutritionProvider = FutureProvider<NutritionSnapshot?>((ref) async {
  final session = ref.watch(authControllerProvider).session;
  if (session == null) {
    return null;
  }

  return ref
      .read(nutritionRepositoryProvider)
      .fetchNutrition(token: session.token);
});

class NutritionRepository {
  const NutritionRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<NutritionSnapshot> fetchNutrition({required String token}) async {
    final json = await _apiClient.getJson('/users/me/nutrition', token: token);
    return NutritionSnapshot.fromJson(json);
  }

  Future<NutritionLogResult> addMeal({
    required String token,
    required String name,
    required String category,
    required int calories,
    required int protein,
    required int carbs,
    required int fats,
    String? timeLabel,
  }) async {
    final json = await _apiClient.postJson(
      '/users/me/nutrition/meals',
      token: token,
      body: {
        'name': name,
        'category': category,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fats': fats,
        if (timeLabel != null) 'timeLabel': timeLabel,
      },
    );

    return NutritionLogResult.fromJson(json);
  }
}
