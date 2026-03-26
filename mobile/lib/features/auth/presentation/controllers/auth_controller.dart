import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/auth_repository.dart';
import '../../data/auth_session.dart';
import '../../data/auth_session_storage.dart';
import '../../../profile/data/app_user.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(
    ref.read(authRepositoryProvider),
    ref.read(authSessionStorageProvider),
  );
});

final currentUserProvider = Provider<AppUser?>((ref) {
  return ref.watch(authControllerProvider).session?.user;
});

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repository, this._storage)
      : super(const AuthState(isRestoringSession: true)) {
    unawaited(restoreSession());
  }

  final AuthRepository _repository;
  final AuthSessionStorage _storage;

  Future<void> restoreSession() async {
    state = state.copyWith(
      isRestoringSession: true,
      errorMessage: null,
    );

    try {
      final storedSession = await _storage.readSession();

      if (storedSession == null || storedSession.isExpired) {
        await _storage.clearSession();
        state = state.copyWith(
          isRestoringSession: false,
          errorMessage: null,
          session: null,
        );
        return;
      }

      final refreshedSession =
          await _repository.fetchSession(token: storedSession.token);
      await _storage.saveSession(refreshedSession);

      state = state.copyWith(
        isRestoringSession: false,
        isLoading: false,
        errorMessage: null,
        session: refreshedSession,
      );
    } catch (_) {
      await _storage.clearSession();
      state = state.copyWith(
        isRestoringSession: false,
        isLoading: false,
        errorMessage: null,
        session: null,
      );
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      session: null,
    );

    try {
      final session = await _repository.login(email: email, password: password);
      await _storage.saveSession(session);
      state = state.copyWith(
        isLoading: false,
        isRestoringSession: false,
        session: session,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        isRestoringSession: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> signOut() async {
    await _storage.clearSession();
    state = const AuthState(
      isRestoringSession: false,
    );
  }
}

class AuthState {
  const AuthState({
    this.isLoading = false,
    this.isRestoringSession = false,
    this.errorMessage,
    this.session,
  });

  final bool isLoading;
  final bool isRestoringSession;
  final String? errorMessage;
  final AuthSession? session;

  bool get isAuthenticated => session != null;
  bool get isReady => !isRestoringSession;

  AuthState copyWith({
    bool? isLoading,
    bool? isRestoringSession,
    Object? errorMessage = _sentinel,
    Object? session = _sentinel,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isRestoringSession: isRestoringSession ?? this.isRestoringSession,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
      session: identical(session, _sentinel)
          ? this.session
          : session as AuthSession?,
    );
  }
}

const _sentinel = Object();
