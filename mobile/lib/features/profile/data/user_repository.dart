import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import 'app_user.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.read(apiClientProvider));
});

final currentAppUserProvider = FutureProvider<AppUser?>((ref) async {
  final session = ref.watch(authControllerProvider).session;
  if (session == null) {
    return null;
  }

  return ref
      .read(userRepositoryProvider)
      .fetchCurrentUser(token: session.token);
});

class UserRepository {
  const UserRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<AppUser> fetchCurrentUser({required String token}) async {
    final json = await _apiClient.getJson('/users/me', token: token);
    return AppUser.fromJson(json);
  }
}
