import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/animations/page_transitions.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/auth/presentation/screens/bootstrap_screen.dart';
import '../features/auth/presentation/screens/auth_screen.dart';
import '../features/events/presentation/screens/events_screen.dart';
import '../features/home/presentation/screens/home_shell.dart';
import '../features/leaderboard/presentation/screens/leaderboard_screen.dart';
import '../features/social/presentation/screens/comms_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ValueNotifier<int>(0);

  ref.listen<AuthState>(authControllerProvider, (_, __) {
    refreshListenable.value++;
  });
  ref.onDispose(refreshListenable.dispose);

  return GoRouter(
    initialLocation: '/bootstrap',
    refreshListenable: refreshListenable,
    redirect: (_, state) {
      final authState = ref.read(authControllerProvider);
      final location = state.matchedLocation;
      final isBootstrap = location == '/bootstrap';
      final isLogin = location == '/login';
      final isProtected = location.startsWith('/app');

      if (!authState.isReady) {
        return isBootstrap ? null : '/bootstrap';
      }

      if (!authState.isAuthenticated) {
        if (isProtected) {
          return '/login';
        }

        return isBootstrap ? '/login' : null;
      }

      if (isBootstrap || isLogin || location == '/') {
        return '/app';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (_, __) => '/bootstrap',
      ),
      GoRoute(
        path: '/bootstrap',
        builder: (_, __) => const BootstrapScreen(),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => AppTransitions.slideUp(
          key: state.pageKey,
          child: const AuthScreen(),
        ),
      ),
      GoRoute(
        path: '/app',
        pageBuilder: (context, state) => AppTransitions.crossFadeScale(
          key: state.pageKey,
          child: const HomeShell(),
        ),
      ),
      GoRoute(
        path: '/app/events',
        pageBuilder: (context, state) => AppTransitions.slideUp(
          key: state.pageKey,
          child: const EventsScreen(),
        ),
      ),
      GoRoute(
        path: '/app/comms',
        pageBuilder: (context, state) => AppTransitions.slideUp(
          key: state.pageKey,
          child: const CommsScreen(),
        ),
      ),
      GoRoute(
        path: '/app/leaderboard',
        pageBuilder: (context, state) => AppTransitions.slideUp(
          key: state.pageKey,
          child: const LeaderboardScreen(),
        ),
      ),
    ],
  );
});
