import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import 'run_overview.dart';

final runRepositoryProvider = Provider<RunRepository>((ref) {
  return RunRepository(ref.read(apiClientProvider));
});

final runOverviewProvider = FutureProvider<RunOverview?>((ref) async {
  final session = ref.watch(authControllerProvider).session;
  if (session == null) {
    return null;
  }

  return ref.read(runRepositoryProvider).fetchRunOverview(token: session.token);
});

class RunRepository {
  const RunRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<RunOverview> fetchRunOverview({required String token}) async {
    final json =
        await _apiClient.getJson('/territories/run-overview', token: token);
    return RunOverview.fromJson(json);
  }

  Future<RunCaptureResult> simulateCapture({required String token}) async {
    final json = await _apiClient.postJson(
      '/territories/capture',
      token: token,
      body: {
        'sessionId': 'foundation-session',
        'path': const [
          {'lat': 30.9001, 'lng': 75.8511},
          {'lat': 30.9014, 'lng': 75.8528},
          {'lat': 30.9028, 'lng': 75.8540},
          {'lat': 30.9040, 'lng': 75.8553},
        ],
      },
    );

    return RunCaptureResult.fromJson(json);
  }
}

class RunCaptureResult {
  const RunCaptureResult({
    required this.pointCount,
    required this.capturedArea,
    required this.territoryCaptures,
  });

  final int pointCount;
  final int capturedArea;
  final int territoryCaptures;

  factory RunCaptureResult.fromJson(Map<String, dynamic> json) {
    return RunCaptureResult(
      pointCount: json['pointCount'] as int? ?? 0,
      capturedArea: json['capturedArea'] as int? ?? 0,
      territoryCaptures: json['territoryCaptures'] as int? ?? 0,
    );
  }
}
