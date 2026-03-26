import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import 'auth_session.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(apiClientProvider));
});

class AuthRepository {
  const AuthRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final json = await _apiClient.postJson(
      '/auth/login',
      body: {
        'email': email,
        'password': password,
      },
    );

    return AuthSession.fromJson(json);
  }

  Future<AuthSession> fetchSession({required String token}) async {
    final json = await _apiClient.getJson('/auth/session', token: token);
    return AuthSession.fromJson(json);
  }
}
