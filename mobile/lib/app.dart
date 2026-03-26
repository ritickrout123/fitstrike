import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/routes.dart';
import 'config/theme.dart';
import 'shared/widgets/app_viewport.dart';

class FitStrikeApp extends ConsumerWidget {
  const FitStrikeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'FitStrike',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
      builder: (context, child) {
        return AppViewport(
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
